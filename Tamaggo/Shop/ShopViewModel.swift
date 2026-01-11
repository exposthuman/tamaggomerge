import Foundation

final class ShopViewModel {
    private(set) var inventory: Inventory

    init(inventory: Inventory) {
        self.inventory = inventory
    }

    func addItem(_ item: InventoryItem) {
        inventory.items.append(item)
    }
}
