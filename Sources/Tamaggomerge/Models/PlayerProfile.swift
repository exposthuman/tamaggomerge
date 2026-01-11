import Foundation

struct PlayerProfile: Codable, Equatable {
    var id: UUID
    var displayName: String
    var selectedPetID: String?
    var petState: PetState

    init(id: UUID = UUID(), displayName: String, selectedPetID: String? = nil, petState: PetState = PetState()) {
        self.id = id
        self.displayName = displayName
        self.selectedPetID = selectedPetID
        self.petState = petState
    }

    mutating func selectPet(_ petID: String) {
        selectedPetID = petID
        petState.lastInteractionAt = Date()
    }
}
