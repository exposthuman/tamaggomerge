import Foundation

final class EconomyViewModel {
    private let currencyService: CurrencyService

    init(currencyService: CurrencyService) {
        self.currencyService = currencyService
    }

    func loadBalance() async throws -> CurrencyBalance {
        try await currencyService.fetchBalance()
    }
}
