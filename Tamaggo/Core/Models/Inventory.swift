import Foundation

struct Inventory: Codable, Equatable {
    var items: [InventoryItem]
}

struct InventoryItem: Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var quantity: Int
}
