import SwiftUI

@main
struct TamagomergeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var authViewModel = AuthViewModel(
        profileService: ProfileService(),
        profileCache: ProfileCache()
    )

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}
