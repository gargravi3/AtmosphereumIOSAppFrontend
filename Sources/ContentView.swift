import SwiftUI

enum AppRoute {
    case welcome
    case signup     // full onboarding flow (starts with SignupView)
    case login
    case app        // main tab shell
}

struct ContentView: View {
    @State private var showSplash = true
    @State private var route: AppRoute = .welcome
    // Pre-fill value handed off when the signup view's email hint says
    // "already registered → Log in instead". Cleared after consumption.
    @State private var loginPrefillEmail: String = ""

    var body: some View {
        ZStack {
            content
            if showSplash {
                SplashView(onFinished: {
                    // If we already have a saved JWT, skip straight to the app.
                    if KeychainHelper.loadToken() != nil {
                        route = .app
                    }
                    withAnimation(.easeOut(duration: 0.4)) {
                        showSplash = false
                    }
                })
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch route {
        case .welcome:
            WelcomeView(
                onSignUp: { withAnimation { route = .signup } },
                onLogIn:  { withAnimation { route = .login } }
            )

        case .signup:
            OnboardingCoordinator(
                onFinished: {
                    withAnimation(.easeInOut(duration: 0.35)) { route = .app }
                },
                onBack: { withAnimation { route = .welcome } },
                onSwitchToLogin: { email in
                    loginPrefillEmail = email
                    withAnimation(.easeInOut(duration: 0.25)) { route = .login }
                }
            )

        case .login:
            LoginView(
                initialEmail: loginPrefillEmail,
                onLoggedIn: { withAnimation(.easeInOut(duration: 0.35)) { route = .app } },
                onBack:     {
                    loginPrefillEmail = ""
                    withAnimation { route = .welcome }
                }
            )

        case .app:
            AppShellView(onLogout: {
                KeychainHelper.clearToken()
                withAnimation { route = .welcome }
            })
        }
    }
}

#Preview {
    ContentView()
}

#Preview {
    ContentView()
}
