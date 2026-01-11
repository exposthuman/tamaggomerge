//
//  tamaggomergeTests.swift
//  tamaggomergeTests
//
//  Created by admin on 11.01.2026.
//

import Testing
@testable import tamaggomerge

struct tamaggomergeTests {

    @Test func economyPurchaseAndSpend() async throws {
        var economy = EconomyState(coins: 10, cookies: 0)
        #expect(economy.purchase(cost: 4))
        #expect(economy.coins == 6)
        #expect(!economy.spendCoins(10))
        #expect(economy.spendCoins(2))
        #expect(economy.coins == 4)
    }

    @Test func buyItemUpdatesInventory() async throws {
        var economy = EconomyState(coins: 8, cookies: 0)
        #expect(economy.buyItem(id: "Hat", cost: 3))
        #expect(economy.inventory["Hat"] == 1)
        #expect(economy.coins == 5)
    }

    @Test func convertCookiesToCoinsUsesRate() async throws {
        var economy = EconomyState(coins: 1, cookies: 27)
        let gained = economy.convertCookiesToCoins(rate: 10)
        #expect(gained == 2)
        #expect(economy.coins == 3)
        #expect(economy.cookies == 7)
    }
}
