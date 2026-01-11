import Foundation
import Combine
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var displayName: String = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published private(set) var profile: PlayerProfile?
    @Published private(set) var isAuthenticated: Bool = false

    private let profileService: ProfileService
    private let profileCache: ProfileCache
    private let networkMonitor: NetworkMonitor
    private var authListener: AuthStateDidChangeListenerHandle?
    private var cancellables = Set<AnyCancellable>()

    init(
        profileService: ProfileService,
        profileCache: ProfileCache,
        networkMonitor: NetworkMonitor = NetworkMonitor()
    ) {
        self.profileService = profileService
        self.profileCache = profileCache
        self.networkMonitor = networkMonitor

        self.profile = profileCache.loadProfile()

        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            self.isAuthenticated = user != nil
            Task {
                await self.refreshProfile()
            }
        }

        networkMonitor.$isConnected
            .removeDuplicates()
            .sink { [weak self] isConnected in
                guard let self, isConnected else { return }
                Task { await self.syncPendingProfileIfNeeded() }
            }
            .store(in: &cancellables)

        Task {
            await syncPendingProfileIfNeeded()
        }
    }

    deinit {
        if let authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }

    func signIn() async {
        errorMessage = nil
        guard validateLogin() else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = result.user
            let displayName = user.displayName ?? email
            let profile = try await profileService.createProfileIfNeeded(
                uid: user.uid,
                email: user.email ?? email,
                displayName: displayName
            )
            setProfile(profile)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signUp() async {
        errorMessage = nil
        guard validateSignup() else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = result.user
            let profile = try await profileService.createProfileIfNeeded(
                uid: user.uid,
                email: user.email ?? email,
                displayName: displayName
            )
            setProfile(profile)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        errorMessage = nil
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            profile = nil
            profileCache.clearProfile()
            profileCache.clearPendingProfile()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshProfile() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            if let profile = try await profileService.fetchProfile(uid: uid) {
                setProfile(profile)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateDisplayName(_ newName: String) async {
        guard let current = profile else { return }
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Display name cannot be empty."
            return
        }

        var pending = current
        pending.displayName = trimmed
        pending.updatedAt = Date()
        profileCache.saveProfile(pending)
        profileCache.savePendingProfile(pending)
        profile = pending

        if networkMonitor.isConnected {
            await syncPendingProfileIfNeeded()
        }
    }

    private func syncPendingProfileIfNeeded() async {
        guard networkMonitor.isConnected else { return }
        guard let pending = profileCache.loadPendingProfile() else { return }

        do {
            try await profileService.saveProfile(pending)
            profileCache.clearPendingProfile()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func setProfile(_ profile: PlayerProfile) {
        self.profile = profile
        profileCache.saveProfile(profile)
    }

    private func validateLogin() -> Bool {
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Email is required."
            return false
        }
        if !email.contains("@") {
            errorMessage = "Enter a valid email."
            return false
        }
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters."
            return false
        }
        return true
    }

    private func validateSignup() -> Bool {
        if displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Display name is required."
            return false
        }
        return validateLogin()
    }
}
