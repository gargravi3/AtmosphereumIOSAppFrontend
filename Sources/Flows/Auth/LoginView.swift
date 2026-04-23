import SwiftUI

struct LoginView: View {
    // Optional pre-fill (e.g. handed off from signup's "already
    // registered → log in instead" hint). Empty = normal entry.
    var initialEmail: String = ""
    let onLoggedIn: () -> Void
    let onBack: () -> Void

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil
    @State private var didApplyInitialEmail: Bool = false

    private enum Field: Hashable { case email, password }
    @FocusState private var focus: Field?

    private var isValid: Bool {
        OnboardingState.isLikelyEmail(email) && !password.isEmpty
    }

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    IconButton(
                        systemName: "chevron.left",
                        accessibilityLabel: "Back",
                        size: 18,
                        color: AppColor.primaryNavy,
                        action: onBack
                    )
                    Spacer()
                    AtmosmLogoImage()
                        .frame(width: 40, height: 48)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.top, 4)
                .padding(.horizontal, 8)

                Text("Welcome back")
                    .font(.atmosmTitle)
                    .foregroundStyle(AppColor.primaryNavy)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                Text("Log in to continue tracking your carbon footprint.")
                    .font(.atmosmBody)
                    .foregroundStyle(AppColor.textSecondary)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        AtmosmTextField(
                            label: "Email",
                            capitalization: .never,
                            keyboardType: .emailAddress,
                            submitLabel: .next,
                            textContentType: .emailAddress,
                            focus: $focus, focusValue: Field.email,
                            text: $email,
                            onSubmit: { focus = .password }
                        )
                        AtmosmTextField(
                            label: "Password",
                            isSecure: true,
                            submitLabel: .go,
                            textContentType: .password,
                            focus: $focus, focusValue: Field.password,
                            text: $password,
                            onSubmit: {
                                focus = nil
                                if isValid { submit() }
                            }
                        )

                        if let err = errorMessage {
                            Text(err)
                                .font(.atmosmCaption)
                                .foregroundStyle(.red)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                }

                PrimaryButton(
                    title: isSubmitting ? "Logging in…" : "Log In",
                    style: .navy,
                    isEnabled: isValid && !isSubmitting
                ) {
                    submit()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            // Only honour the hand-off once so returning to the view
            // (e.g. after an error) doesn't overwrite in-progress edits.
            if !didApplyInitialEmail && !initialEmail.isEmpty {
                email = initialEmail
                didApplyInitialEmail = true
                focus = .password
            }
        }
    }

    private func submit() {
        errorMessage = nil
        isSubmitting = true
        Task {
            do {
                _ = try await NetworkService.shared.login(
                    LoginRequest(
                        email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                        password: password
                    )
                )
                await MainActor.run {
                    isSubmitting = false
                    onLoggedIn()
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    LoginView(onLoggedIn: {}, onBack: {})
}
