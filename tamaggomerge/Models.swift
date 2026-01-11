import Foundation

enum Currency: String, Codable {
    case soft
    case hard
}

struct ItemCatalog: Codable {
    let rooms: [Room]
}

struct Room: Codable {
    let id: String
    let name: String
    let items: [Item]
    let slots: [Slot]
}

struct Item: Codable, Hashable {
    let id: String
    let name: String
    let price: Int
    let currency: Currency
    let bonus: Int
}

struct Slot: Codable {
    let id: String
    let x: Double
    let y: Double
}

struct PetStats {
    var happiness: Int
    var energy: Int
}
