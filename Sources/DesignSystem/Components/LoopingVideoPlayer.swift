import SwiftUI
import AVKit

// Muted, full-bleed video player for splash-style backgrounds.
// Uses AVPlayerLayer via UIViewRepresentable instead of VideoPlayer because
// we want: no controls, silent audio, precise aspect fill, and a callback
// when the clip reaches the end so the caller can decide to loop or dismiss.
struct LoopingVideoPlayer: UIViewRepresentable {
    let url: URL
    /// Whether to loop the clip. If `false`, the player plays once and
    /// `onFinished` fires when it hits the end.
    var loop: Bool = false
    /// Called when the clip plays through to the end (fires once per clip
    /// when `loop == false`; fires on every loop boundary when `loop == true`).
    var onFinished: (() -> Void)? = nil

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView(url: url, loop: loop)
        view.onFinished = onFinished
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.onFinished = onFinished
    }

    final class PlayerUIView: UIView {
        private let playerLayer = AVPlayerLayer()
        private let player: AVPlayer
        private let loop: Bool
        var onFinished: (() -> Void)?

        init(url: URL, loop: Bool) {
            let item = AVPlayerItem(url: url)
            self.player = AVPlayer(playerItem: item)
            self.loop = loop
            super.init(frame: .zero)

            // Mute — splash video must never blare audio at launch.
            player.isMuted = true
            // Don't interrupt music playback on the device.
            try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])

            playerLayer.player = player
            playerLayer.videoGravity = .resizeAspectFill
            layer.addSublayer(playerLayer)

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(playerDidFinish),
                name: .AVPlayerItemDidPlayToEndTime,
                object: item
            )

            player.play()
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

        override func layoutSubviews() {
            super.layoutSubviews()
            playerLayer.frame = bounds
        }

        @objc private func playerDidFinish() {
            onFinished?()
            if loop {
                player.seek(to: .zero)
                player.play()
            }
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}
