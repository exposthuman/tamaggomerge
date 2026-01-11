import Foundation

final class ProfileCache {
    private let profileKey = "cachedPlayerProfile"
    private let pendingKey = "pendingProfileSync"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func saveProfile(_ profile: PlayerProfile) {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        defaults.set(data, forKey: profileKey)
    }

    func loadProfile() -> PlayerProfile? {
        guard let data = defaults.data(forKey: profileKey) else { return nil }
        return try? JSONDecoder().decode(PlayerProfile.self, from: data)
    }

    func clearProfile() {
        defaults.removeObject(forKey: profileKey)
    }

    func savePendingProfile(_ profile: PlayerProfile) {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        defaults.set(data, forKey: pendingKey)
    }

    func loadPendingProfile() -> PlayerProfile? {
        guard let data = defaults.data(forKey: pendingKey) else { return nil }
        return try? JSONDecoder().decode(PlayerProfile.self, from: data)
    }

    func clearPendingProfile() {
        defaults.removeObject(forKey: pendingKey)
    }
}
