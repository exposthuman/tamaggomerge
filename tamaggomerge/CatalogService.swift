import Foundation

final class CatalogService {
    static let shared = CatalogService()

    private(set) var catalog: ItemCatalog
    private(set) var roomOrder: [String]
    private var roomsById: [String: Room]

    private init() {
        let bundle = Bundle.main
        guard let url = bundle.url(forResource: "ItemCatalog", withExtension: "json") else {
            catalog = ItemCatalog(rooms: [])
            roomOrder = []
            roomsById = [:]
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(ItemCatalog.self, from: data)
            catalog = decoded
            roomOrder = decoded.rooms.map { $0.id }
            roomsById = Dictionary(uniqueKeysWithValues: decoded.rooms.map { ($0.id, $0) })
        } catch {
            catalog = ItemCatalog(rooms: [])
            roomOrder = []
            roomsById = [:]
        }
    }

    func room(for id: String) -> Room? {
        roomsById[id]
    }
}
