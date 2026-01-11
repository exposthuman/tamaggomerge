import Foundation

struct PetState: Codable, Equatable {
    var name: String
    var level: Int
    var happiness: Double
    var hunger: Double
    var lastInteractionAt: Date
}
