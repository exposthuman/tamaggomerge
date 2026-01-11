import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showingSignup = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome Back")
                .font(.largeTitle)
                .bold()

            VStack(alignment: .leading, spacing: 12) {
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
                Task { await authViewModel.signIn() }
            } label: {
                if authViewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(authViewModel.isLoading)

            Button("Create an account") {
                showingSignup = true
            }
            .sheet(isPresented: $showingSignup) {
                NavigationView {
                    SignupView()
                }
            }
        }
        .padding()
        .navigationTitle("Login")
    }
}
