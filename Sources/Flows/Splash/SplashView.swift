import SwiftUI

// First screen shown on app launch. If `SplashGlobe.mp4` is bundled, play
// it full-bleed; otherwise fall back to the static `SplashBackground`
// image; otherwise render a text-only composition.
// Auto-dismisses when the video finishes OR at `maxDuration` (whichever
// comes first) so users are never forced to sit through the full clip.
struct SplashView: View {
    var onFinished: () -> Void

    // Safety cap — even if the video is long or fails to signal end,
    // we bounce into the app at this many seconds. Tuned so the globe
    // rotation reads without making launch feel slow.
    private let maxDuration: TimeInterval = 3.5

    @State private var hasDismissed = false

    var body: some View {
        ZStack {
            AppColor.splashBackground
                .ignoresSafeArea()

            if let videoURL = Bundle.main.url(forResource: "SplashGlobe", withExtension: "mp4") {
                LoopingVideoPlayer(url: videoURL, loop: false) {
                    dismissOnce()
                }
                .ignoresSafeArea()
            } else if UIImage(named: "SplashBackground") != nil {
                Image("SplashBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                // Fallback composition if both video and image are missing.
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
            // Hard cap — even for the text fallback / if the video finish
            // notification never arrives, we always move on.
            DispatchQueue.main.asyncAfter(deadline: .now() + maxDuration) {
                dismissOnce()
            }
        }
    }

    private func dismissOnce() {
        guard !hasDismissed else { return }
        hasDismissed = true
        onFinished()
    }
}

#Preview {
    SplashView(onFinished: {})
}
