import Foundation

final class PlayerProfileStore {
    private let storageKey = "player-profile"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadProfile(displayName: String) -> PlayerProfile {
        if let data = defaults.data(forKey: storageKey),
           let profile = try? decoder.decode(PlayerProfile.self, from: data) {
            return profile
        }

        return PlayerProfile(displayName: displayName)
    }

    func saveProfile(_ profile: PlayerProfile) {
        guard let data = try? encoder.encode(profile) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
