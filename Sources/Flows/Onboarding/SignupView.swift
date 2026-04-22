import SwiftUI

struct SignupView: View {
    @Bindable var state: OnboardingState
    let onContinue: () -> Void
    var onTerms: () -> Void = {}
    var onBack: () -> Void = {}

    // Focus chain. Pressing Return advances to the next field; the final
    // Confirm Password field submits the form.
    private enum Field: Hashable {
        case firstName, lastName, email, password, confirm
    }
    @FocusState private var focus: Field?

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Back button (to Welcome) on left, Atmosm logo centered.
                // Trailing spacer keeps the logo visually centered.
                ZStack {
                    HStack {
                        IconButton(
                            systemName: "chevron.left",
                            accessibilityLabel: "Back",
                            size: 18,
                            color: AppColor.primaryNavy,
                            action: onBack
                        )
                        Spacer()
                    }
                    AtmosmLogoImage()
                        .frame(width: 50, height: 61)
                }
                .padding(.top, 4)
                .padding(.horizontal, 4)
                .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        AtmosmTextField(
                            label: "First Name",
                            capitalization: .words,
                            submitLabel: .next,
                            textContentType: .givenName,
                            focus: $focus, focusValue: Field.firstName,
                            text: $state.firstName,
                            onSubmit: { focus = .lastName }
                        )
                        AtmosmTextField(
                            label: "Last Name",
                            capitalization: .words,
                            submitLabel: .next,
                            textContentType: .familyName,
                            focus: $focus, focusValue: Field.lastName,
                            text: $state.lastName,
                            onSubmit: { focus = .email }
                        )
                        AtmosmTextField(
                            label: "Email",
                            capitalization: .never,
                            keyboardType: .emailAddress,
                            submitLabel: .next,
                            textContentType: .emailAddress,
                            focus: $focus, focusValue: Field.email,
                            text: $state.email,
                            onSubmit: { focus = .password }
                        )
                        AtmosmTextField(
                            label: "Password",
                            isSecure: true,
                            submitLabel: .next,
                            textContentType: .newPassword,
                            focus: $focus, focusValue: Field.password,
                            text: $state.password,
                            onSubmit: { focus = .confirm }
                        )
                        AtmosmTextField(
                            label: "Confirm Password",
                            isSecure: true,
                            submitLabel: .go,
                            textContentType: .newPassword,
                            focus: $focus, focusValue: Field.confirm,
                            text: $state.confirmPassword,
                            onSubmit: {
                                focus = nil
                                if state.isSignupValid { submit() }
                            }
                        )

                        PasswordStrengthBar(strength: state.passwordStrength)
                            .padding(.top, 8)

                        PasswordRequirements()
                            .padding(.top, 4)

                        if let err = state.signupError {
                            Text(err)
                                .font(.atmosmCaption)
                                .foregroundStyle(.red)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }

                PrimaryButton(
                    title: state.isSubmitting ? "Creating account…" : "Next",
                    style: .navy,
                    isEnabled: state.isSignupValid && !state.isSubmitting
                ) {
                    submit()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)

                HStack(spacing: 4) {
                    Text("By signing up you accept our")
                    Button(action: onTerms) {
                        Text("Terms & Conditions")
                            .underline()
                            .foregroundStyle(AppColor.primaryNavy)
                    }
                    .buttonStyle(.plain)
                }
                .font(.atmosmCaption)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden()
    }

    private func submit() {
        state.signupError = nil
        state.isSubmitting = true
        Task {
            do {
                _ = try await NetworkService.shared.register(
                    RegisterRequest(
                        email: state.email.trimmingCharacters(in: .whitespacesAndNewlines),
                        password: state.password,
                        firstName: state.firstName,
                        lastName: state.lastName
                    )
                )
                await MainActor.run {
                    state.isSubmitting = false
                    onContinue()
                }
            } catch {
                await MainActor.run {
                    state.isSubmitting = false
                    state.signupError = error.localizedDescription
                }
            }
        }
    }
}

private struct PasswordRequirements: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Your password must contain at least")
                .font(.atmosmCaption)
            Label("1 letter", systemImage: "circle.fill")
                .labelStyle(BulletLabelStyle())
            Label("1 number or special character (example: # ? ! &)", systemImage: "circle.fill")
                .labelStyle(BulletLabelStyle())
            Label("and at least 8 characters", systemImage: "circle.fill")
                .labelStyle(BulletLabelStyle())
        }
        .font(.atmosmCaption)
        .foregroundStyle(AppColor.textPrimary)
    }
}

private struct BulletLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("•")
            configuration.title
        }
    }
}

#Preview {
    NavigationStack {
        SignupView(state: OnboardingState(), onContinue: {})
    }
}
