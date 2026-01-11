import Foundation

final class PetStateManager {
    private let store: PlayerProfileStore
    private var timer: Timer?
    private(set) var profile: PlayerProfile

    init(store: PlayerProfileStore, profile: PlayerProfile) {
        self.store = store
        self.profile = profile
        applyDegradationIfNeeded()
    }

    func startSessionDegradation() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.tickDegradation()
        }
    }

    func stopSessionDegradation() {
        timer?.invalidate()
        timer = nil
    }

    func selectPet(_ petID: String) {
        profile.selectPet(petID)
        store.saveProfile(profile)
    }

    func feedPet() {
        profile.petState.feed()
        store.saveProfile(profile)
    }

    func petPet() {
        profile.petState.pet()
        store.saveProfile(profile)
    }

    private func applyDegradationIfNeeded() {
        let now = Date()
        profile.petState.applyDegradation(from: profile.petState.lastInteractionAt, to: now)
        store.saveProfile(profile)
    }

    private func tickDegradation() {
        let now = Date()
        profile.petState.applyDegradation(from: profile.petState.lastInteractionAt, to: now)
        store.saveProfile(profile)
    }
}
