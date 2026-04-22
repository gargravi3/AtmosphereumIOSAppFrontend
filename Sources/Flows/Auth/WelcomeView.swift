import SwiftUI

struct WelcomeView: View {
    let onSignUp: () -> Void
    let onLogIn: () -> Void

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                AtmosmLogoImage()
                    .frame(width: 120, height: 148)
                    .padding(.bottom, 16)

                Text("Atmosm")
                    .font(.atmosmTitle)
                    .foregroundStyle(AppColor.primaryNavy)

                Text("Track. Reduce. Repeat.")
                    .font(.atmosmBody)
                    .foregroundStyle(AppColor.textSecondary)
                    .padding(.top, 4)

                Spacer()

                VStack(spacing: 12) {
                    PrimaryButton(title: "Sign Up", style: .navy, action: onSignUp)

                    Button(action: onLogIn) {
                        Text("I already have an account")
                            .font(.atmosmButton)
                            .foregroundStyle(AppColor.primaryNavy)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .overlay(
                                Capsule().stroke(AppColor.primaryNavy, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    WelcomeView(onSignUp: {}, onLogIn: {})
}
