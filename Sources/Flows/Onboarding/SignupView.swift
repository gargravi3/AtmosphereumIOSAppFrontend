import SwiftUI

struct SignupView: View {
    @Bindable var state: OnboardingState
    let onContinue: () -> Void
    var onTerms: () -> Void = {}
    var onBack: () -> Void = {}
    // Called when the user taps the "Log in instead" link inside the
    // email-taken hint. Passes the already-typed email so the login
    // screen can pre-fill and save the user a round of typing.
    var onSwitchToLogin: (String) -> Void = { _ in }

    // Focus chain. Pressing Return advances to the next field; the final
    // Confirm Password field submits the form.
    private enum Field: Hashable {
        case firstName, lastName, email, password, confirm
    }
    @FocusState private var focus: Field?

    // Debounced email-availability probe. Restarted on every keystroke.
    @State private var emailCheckTask: Task<Void, Never>? = nil

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

                        emailAvailabilityHint
                            .animation(.easeInOut(duration: 0.15), value: state.emailStatus)
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
        .onChange(of: state.email) { _, newValue in
            scheduleEmailCheck(for: newValue)
        }
        .onAppear {
            // If the user bounced back here after a failed submit, the
            // field already has a value — kick off one probe so the
            // hint reflects reality instead of .unknown.
            if !state.email.isEmpty {
                scheduleEmailCheck(for: state.email)
            }
        }
        .onDisappear { emailCheckTask?.cancel() }
    }

    // MARK: - Email availability

    @ViewBuilder
    private var emailAvailabilityHint: some View {
        switch state.emailStatus {
        case .unknown, .invalidFormat:
            EmptyView()
        case .checking:
            HStack(spacing: 6) {
                ProgressView()
                    .scaleEffect(0.7)
                Text("Checking…")
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        case .available:
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppColor.primaryGreen)
                Text("Email is available")
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.primaryGreen)
            }
        case .taken:
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(AppColor.accentRed)
                Text("Already registered.")
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.accentRed)
                Button {
                    onSwitchToLogin(state.email)
                } label: {
                    Text("Log in instead")
                        .font(.atmosmCaption.bold())
                        .underline()
                        .foregroundStyle(AppColor.primaryNavy)
                }
                .buttonStyle(.plain)
                Spacer(minLength: 0)
            }
        }
    }

    // Debounces availability probes — 500ms after the last keystroke.
    // Cancels any in-flight task on every edit so we don't stack
    // racing requests.
    private func scheduleEmailCheck(for raw: String) {
        emailCheckTask?.cancel()
        let email = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty else {
            state.emailStatus = .unknown
            return
        }
        guard OnboardingState.isLikelyEmail(email) else {
            state.emailStatus = .invalidFormat
            return
        }
        state.emailStatus = .checking
        emailCheckTask = Task {
            // 500ms debounce. Sleep throws on cancel, which exits early.
            do { try await Task.sleep(nanoseconds: 500_000_000) } catch { return }
            if Task.isCancelled { return }
            do {
                let available = try await NetworkService.shared.checkEmailAvailable(email)
                if Task.isCancelled { return }
                await MainActor.run {
                    // Only apply the result if the field still matches
                    // what we queried — the user may have kept typing.
                    let stillMatches = state.email.trimmingCharacters(in: .whitespacesAndNewlines) == email
                    guard stillMatches else { return }
                    state.emailStatus = available ? .available : .taken
                }
            } catch is CancellationError {
                return
            } catch {
                // Network errors shouldn't block signup — reset to
                // unknown and let the server's 409 catch duplicates
                // as a last line of defence.
                await MainActor.run {
                    if !Task.isCancelled {
                        state.emailStatus = .unknown
                    }
                }
            }
        }
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
