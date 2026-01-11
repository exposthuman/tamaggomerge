import Foundation

struct PlayerProfile: Codable, Equatable {
    let id: UUID
    var username: String
    var createdAt: Date
    var lastLoginAt: Date?
}
