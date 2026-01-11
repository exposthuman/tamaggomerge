import Foundation

protocol AuthService {
    func login(username: String, password: String) async throws
    func signUp(username: String, password: String) async throws
    func signOut() async
}

final class StubAuthService: AuthService {
    func login(username: String, password: String) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
    }

    func signUp(username: String, password: String) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
    }

    func signOut() async {
        await Task.yield()
    }
}
