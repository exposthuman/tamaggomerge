import Foundation

struct RoomState: Codable, Equatable {
    var id: UUID
    var name: String
    var theme: String
    var lastUpdatedAt: Date
}
