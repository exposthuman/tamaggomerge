import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var editDisplayName: String = ""

    var body: some View {
        VStack(spacing: 16) {
            if let profile = authViewModel.profile {
                VStack(spacing: 8) {
                    Text(profile.displayName)
                        .font(.title)
                        .bold()
                    Text(profile.email)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Update display name")
                        .font(.headline)
                    TextField("Display name", text: $editDisplayName)
                        .textFieldStyle(.roundedBorder)
                    Button("Save") {
                        Task { await authViewModel.updateDisplayName(editDisplayName) }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                Text("Loading profile...")
            }

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button("Sign Out") {
                authViewModel.signOut()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .onAppear {
            if let name = authViewModel.profile?.displayName {
                editDisplayName = name
            }
        }
    }
}
