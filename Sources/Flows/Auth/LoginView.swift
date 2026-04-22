import SwiftUI

struct LoginView: View {
    let onLoggedIn: () -> Void
    let onBack: () -> Void

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil

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
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppColor.primaryNavy)
                            .padding(8)
                    }
                    Spacer()
                    AtmosmLogoImage()
                        .frame(width: 40, height: 48)
                    Spacer()
                    // spacer for symmetry with chevron button
                    Color.clear.frame(width: 34, height: 34)
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)

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
