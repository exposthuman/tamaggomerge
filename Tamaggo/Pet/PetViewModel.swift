import Foundation

final class PetViewModel {
    private(set) var petState: PetState

    init(petState: PetState) {
        self.petState = petState
    }

    func feed(amount: Double) {
        petState.hunger = max(0, petState.hunger - amount)
        petState.lastInteractionAt = Date()
    }
}
