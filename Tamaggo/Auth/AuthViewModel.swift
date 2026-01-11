import Foundation

final class AuthViewModel {
    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    func login(username: String, password: String) async throws {
        try await authService.login(username: username, password: password)
    }

    func signUp(username: String, password: String) async throws {
        try await authService.signUp(username: username, password: password)
    }
}
