import Foundation
import FirebaseAuth
import FirebaseFirestore

final class ProfileService {
    private let store: Firestore

    init(store: Firestore = Firestore.firestore()) {
        self.store = store
    }

    func fetchProfile(uid: String) async throws -> PlayerProfile? {
        let document = try await store.collection("playerProfiles").document(uid).getDocument()
        guard document.exists else { return nil }
        return PlayerProfile(document: document)
    }

    func createProfileIfNeeded(uid: String, email: String, displayName: String) async throws -> PlayerProfile {
        if let existing = try await fetchProfile(uid: uid) {
            return existing
        }

        let now = Date()
        let profile = PlayerProfile(
            id: uid,
            displayName: displayName,
            email: email,
            createdAt: now,
            updatedAt: now
        )

        try await saveProfile(profile)
        return profile
    }

    func saveProfile(_ profile: PlayerProfile) async throws {
        try await store
            .collection("playerProfiles")
            .document(profile.id)
            .setData(profile.firestoreData, merge: true)
    }

    func updateProfile(_ profile: PlayerProfile, displayName: String) async throws -> PlayerProfile {
        var updated = profile
        updated.displayName = displayName
        updated.updatedAt = Date()
        try await saveProfile(updated)
        return updated
    }
}
