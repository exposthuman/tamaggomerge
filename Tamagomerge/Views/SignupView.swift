import SwiftUI

struct SignupView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(
        \.dismiss
    ) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()

            VStack(alignment: .leading, spacing: 12) {
                TextField("Display Name", text: $authViewModel.displayName)
                    .textFieldStyle(.roundedBorder)

                TextField("Email", text: $authViewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $authViewModel.password)
                    .textFieldStyle(.roundedBorder)
            }

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task {
                    await authViewModel.signUp()
                    if authViewModel.isAuthenticated {
                        dismiss()
                    }
                }
            } label: {
                if authViewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(authViewModel.isLoading)
        }
        .padding()
        .navigationTitle("Sign Up")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}
