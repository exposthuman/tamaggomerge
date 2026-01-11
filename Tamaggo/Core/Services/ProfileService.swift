import Foundation

protocol ProfileService {
    func fetchProfile() async throws -> PlayerProfile
    func saveProfile(_ profile: PlayerProfile) async throws
}

final class StubProfileService: ProfileService {
    func fetchProfile() async throws -> PlayerProfile {
        try await Task.sleep(nanoseconds: 150_000_000)
        return PlayerProfile(id: UUID(), username: "Player", createdAt: Date(), lastLoginAt: Date())
    }

    func saveProfile(_ profile: PlayerProfile) async throws {
        try await Task.sleep(nanoseconds: 150_000_000)
    }
}
