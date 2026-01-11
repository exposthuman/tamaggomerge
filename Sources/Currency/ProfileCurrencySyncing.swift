import Foundation

public protocol ProfileCurrencySyncing {
    func fetchRemoteBalance() async throws -> CurrencyBalance
    func updateRemoteBalance(_ balance: CurrencyBalance) async throws
}
