import Combine
import Foundation

public final class CurrencyService: ObservableObject {
    private enum StorageKeys {
        static let balance = "currency.balance"
    }

    @Published public private(set) var balance: CurrencyBalance
    private let storage: UserDefaults
    private let profileSyncer: ProfileCurrencySyncing?

    public init(
        storage: UserDefaults = .standard,
        profileSyncer: ProfileCurrencySyncing? = nil
    ) {
        self.storage = storage
        self.profileSyncer = profileSyncer
        self.balance = CurrencyService.loadBalance(from: storage)
    }

    public func addSoft(_ amount: Int) {
        balance.addSoft(amount)
        persistBalance()
    }

    public func addHard(_ amount: Int) {
        balance.addHard(amount)
        persistBalance()
    }

    public func spendSoft(_ amount: Int) -> Bool {
        let result = balance.spendSoft(amount)
        if result {
            persistBalance()
        }
        return result
    }

    public func spendHard(_ amount: Int) -> Bool {
        let result = balance.spendHard(amount)
        if result {
            persistBalance()
        }
        return result
    }

    public func syncFromProfile() async {
        guard let profileSyncer else { return }
        do {
            let remote = try await profileSyncer.fetchRemoteBalance()
            await MainActor.run {
                self.balance = remote
                self.persistBalance()
            }
        } catch {
            return
        }
    }

    public func syncToProfile() async {
        guard let profileSyncer else { return }
        do {
            try await profileSyncer.updateRemoteBalance(balance)
        } catch {
            return
        }
    }

    private func persistBalance() {
        if let data = try? JSONEncoder().encode(balance) {
            storage.set(data, forKey: StorageKeys.balance)
        }
    }

    private static func loadBalance(from storage: UserDefaults) -> CurrencyBalance {
        guard let data = storage.data(forKey: StorageKeys.balance),
              let balance = try? JSONDecoder().decode(CurrencyBalance.self, from: data) else {
            return CurrencyBalance()
        }
        return balance
    }
}
