import Foundation
import StoreKit

@MainActor
public final class StoreKitManager: ObservableObject {
    public enum StoreError: Error {
        case productNotFound
        case purchaseCancelled
        case invalidTransaction
    }

    public struct ProductConfig {
        public let id: String
        public let hardCurrencyAmount: Int

        public init(id: String, hardCurrencyAmount: Int) {
            self.id = id
            self.hardCurrencyAmount = hardCurrencyAmount
        }
    }

    public static let defaultConfigs: [ProductConfig] = [
        .init(id: "hard.small", hardCurrencyAmount: 50),
        .init(id: "hard.medium", hardCurrencyAmount: 120),
        .init(id: "hard.large", hardCurrencyAmount: 300)
    ]

    @Published public private(set) var products: [Product] = []

    private let currencyService: CurrencyService
    private let configs: [ProductConfig]

    public init(currencyService: CurrencyService, configs: [ProductConfig] = StoreKitManager.defaultConfigs) {
        self.currencyService = currencyService
        self.configs = configs
    }

    public func loadProducts() async throws {
        let ids = configs.map { $0.id }
        let storeProducts = try await Product.products(for: ids)
        products = storeProducts.sorted { $0.price < $1.price }
    }

    public func purchase(productId: String) async throws {
        guard let product = products.first(where: { $0.id == productId }) else {
            throw StoreError.productNotFound
        }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await handleTransaction(transaction)
        case .userCancelled:
            throw StoreError.purchaseCancelled
        case .pending:
            return
        @unknown default:
            return
        }
    }

    public func restorePurchases() async throws {
        for await result in Transaction.currentEntitlements {
            let transaction = try checkVerified(result)
            await handleTransaction(transaction)
        }
    }

    public func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            await handleTransaction(transaction)
        }
    }

    private func handleTransaction(_ transaction: Transaction) async {
        guard let config = configs.first(where: { $0.id == transaction.productID }) else {
            await transaction.finish()
            return
        }
        currencyService.addHard(config.hardCurrencyAmount)
        await transaction.finish()
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.invalidTransaction
        case .verified(let safe):
            return safe
        }
    }
}
