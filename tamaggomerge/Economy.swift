//
//  Economy.swift
//  tamaggomerge
//
//  Created by admin on 11.01.2026.
//

import Foundation

struct EconomyState: Equatable {
    static let defaultCookieToCoinRate = 10

    private(set) var coins: Int
    private(set) var cookies: Int
    private(set) var inventory: [String: Int]

    init(coins: Int = 0, cookies: Int = 0, inventory: [String: Int] = [:]) {
        self.coins = max(0, coins)
        self.cookies = max(0, cookies)
        self.inventory = inventory
    }

    mutating func grantCookies(_ amount: Int) {
        guard amount > 0 else { return }
        cookies += amount
    }

    mutating func grantCoins(_ amount: Int) {
        guard amount > 0 else { return }
        coins += amount
    }

    mutating func spendCoins(_ amount: Int) -> Bool {
        guard amount > 0, coins >= amount else { return false }
        coins -= amount
        return true
    }

    mutating func purchase(cost: Int) -> Bool {
        spendCoins(cost)
    }

    mutating func buyItem(id: String, cost: Int) -> Bool {
        guard spendCoins(cost) else { return false }
        inventory[id, default: 0] += 1
        return true
    }

    @discardableResult
    mutating func convertCookiesToCoins(rate: Int = EconomyState.defaultCookieToCoinRate) -> Int {
        guard rate > 0 else { return 0 }
        let gainedCoins = cookies / rate
        if gainedCoins > 0 {
            cookies -= gainedCoins * rate
            coins += gainedCoins
        }
        return gainedCoins
    }
}
