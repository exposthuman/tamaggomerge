import Foundation

final class GameState {
    static let shared = GameState()

    private(set) var balances: [Currency: Int] = [
        .soft: 300,
        .hard: 5
    ]

    private(set) var petStats = PetStats(happiness: 10, energy: 10)
    private(set) var ownedItems: Set<String> = []
    private(set) var placedItemsByRoom: [String: [String: String]] = [:]

    private init() {}

    func canAfford(item: Item) -> Bool {
        (balances[item.currency] ?? 0) >= item.price
    }

    func deduct(item: Item) {
        let current = balances[item.currency] ?? 0
        balances[item.currency] = max(current - item.price, 0)
    }

    func addOwned(itemId: String) {
        ownedItems.insert(itemId)
    }

    func place(item: Item, in roomId: String, slotId: String) {
        var roomSlots = placedItemsByRoom[roomId, default: [:]]
        roomSlots[slotId] = item.id
        placedItemsByRoom[roomId] = roomSlots
        petStats.happiness += item.bonus
        petStats.energy += max(1, item.bonus / 2)
    }

    func placedItemId(in roomId: String, slotId: String) -> String? {
        placedItemsByRoom[roomId]?[slotId]
    }
}
