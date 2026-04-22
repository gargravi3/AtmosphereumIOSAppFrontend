import SwiftUI

// First screen shown on app launch. Full-bleed navy image with the Atmosm
// wordmark baked in; auto-dismisses after a short delay.
struct SplashView: View {
    var onFinished: () -> Void

    var body: some View {
        ZStack {
            AppColor.splashBackground
                .ignoresSafeArea()

            if UIImage(named: "SplashBackground") != nil {
                Image("SplashBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                // Fallback composition if the asset is missing.
                VStack {
                    Spacer()
                    Text("Atmosm")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("Atmosphereum")
                        .font(.atmosmBody.bold())
                        .foregroundStyle(.white)
                        .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
