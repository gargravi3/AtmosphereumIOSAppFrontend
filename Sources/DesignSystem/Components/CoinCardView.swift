import SwiftUI

// Large stat card used on Home + Reduce detail.
// Matches the two blue/grey cards from Figma node 153:337.
struct CoinCardView: View {
    enum Style {
        case navyCoin   // dark blue bg + gold coin — "You have 100 Atmosm Coins"
        case slateCloud // grey-blue bg + CO2 cloud — "reducing 100 kg of CO2"
    }

    let style: Style
    let value: Int
    let title: String      // "Atmosm Coins" | "kg of CO₂"
    let prefix: String?    // "reducing" | nil

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.medium)
                .fill(style == .navyCoin ? AppColor.primaryNavy : AppColor.slateCard)

            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    if let prefix {
                        Text(prefix)
                            .font(.atmosmBody)
                            .foregroundStyle(.white)
                    }
                    Text("\(value)")
                        .font(.system(size: 54, weight: .heavy))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text(title)
                        .font(.atmosmBody.bold())
                        .foregroundStyle(.white)
                }
                Spacer(minLength: 0)
                artwork
                    .frame(width: 90, height: 90)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(height: 138)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: value)
    }

    @ViewBuilder
    private var artwork: some View {
        switch style {
        case .navyCoin:
            SpinningCoin {
                AssetOrSymbolImage(assetName: "AtmosmCoin", systemName: "dollarsign.circle.fill", tint: nil)
            }
        case .slateCloud:
            DriftingCloud {
                AssetOrSymbolImage(assetName: "CO2Cloud", systemName: "cloud.fill", tint: .white)
                    .colorInvert()
            }
        }
    }
}

// MARK: - Coin: perspective Y-axis spin + gentle hover bob.
// Both loops run concurrently with different periods so they never lock
// into the same phase, which keeps the motion feeling organic. Honours
// the user's Reduce Motion setting — when on, we keep the hover only
// (since a small translation is much less vestibular-triggering than
// a continuous rotation).
private struct SpinningCoin<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var spin: Double = 0
    @State private var hover: CGFloat = 0
    let content: () -> Content

    var body: some View {
        content()
            .rotation3DEffect(
                .degrees(spin),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.85
            )
            .offset(y: hover)
            .onAppear {
                if !reduceMotion {
                    withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                        spin = 360
                    }
                }
                withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                    hover = -6
                }
            }
            // Pause animations when scrolled off-screen or tab hidden —
            // otherwise Core Animation keeps stepping them at 60fps forever.
            .onDisappear {
                withAnimation(.linear(duration: 0)) {
                    spin = 0
                    hover = 0
                }
            }
    }
}

// MARK: - Cloud: horizontal drift + vertical bob.
// Slightly louder than the coin's ambient hover so the card doesn't feel
// static; still low-amplitude so it reads as drifting, not rocking.
private struct DriftingCloud<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var drift: CGFloat = 0
    @State private var bob: CGFloat = 0
    let content: () -> Content

    var body: some View {
        content()
            .offset(x: drift, y: bob)
            .onAppear {
                if !reduceMotion {
                    withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                        drift = 9
                    }
                }
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    bob = -5
                }
            }
            .onDisappear {
                withAnimation(.linear(duration: 0)) {
                    drift = 0
                    bob = 0
                }
            }
    }
}

#Preview {
    VStack(spacing: 16) {
        CoinCardView(style: .navyCoin, value: 100, title: "Atmosm Coins", prefix: nil)
        CoinCardView(style: .slateCloud, value: 100, title: "kg of CO₂", prefix: "reducing")
    }
    .padding(24)
    .background(AppColor.lightBlueBackground)
}
