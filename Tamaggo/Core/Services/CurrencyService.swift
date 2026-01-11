import Foundation

protocol CurrencyService {
    func fetchBalance() async throws -> CurrencyBalance
    func updateBalance(_ balance: CurrencyBalance) async throws
}

final class StubCurrencyService: CurrencyService {
    func fetchBalance() async throws -> CurrencyBalance {
        try await Task.sleep(nanoseconds: 120_000_000)
        return CurrencyBalance(softCurrency: 100, premiumCurrency: 5)
    }

    func updateBalance(_ balance: CurrencyBalance) async throws {
        try await Task.sleep(nanoseconds: 120_000_000)
    }
}
