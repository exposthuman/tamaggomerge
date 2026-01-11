import Foundation

public struct CurrencyBalance: Codable, Equatable {
    public var soft: Int
    public var hard: Int

    public init(soft: Int = 0, hard: Int = 0) {
        self.soft = max(0, soft)
        self.hard = max(0, hard)
    }

    public mutating func addSoft(_ amount: Int) {
        soft = max(0, soft + amount)
    }

    public mutating func addHard(_ amount: Int) {
        hard = max(0, hard + amount)
    }

    public mutating func spendSoft(_ amount: Int) -> Bool {
        guard amount >= 0, soft >= amount else { return false }
        soft -= amount
        return true
    }

    public mutating func spendHard(_ amount: Int) -> Bool {
        guard amount >= 0, hard >= amount else { return false }
        hard -= amount
        return true
    }
}
