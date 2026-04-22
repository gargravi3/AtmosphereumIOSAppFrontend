import SwiftUI

// Home (Figma node 153:384). Coin-centric layout:
//   - "You have... X Atmosm Coins" card (navy)
//   - "reducing X kg of CO₂" card (slate)
//   - "Remember you need to reduce another Y kg to #NetZero" copy
//   - Link down to the full donut-chart Footprint detail.
struct HomeView: View {
    @Bindable var app: AppState
    let onShowFootprint: () -> Void
    let onBrowseReduce: () -> Void
    let onMenu: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Overridden values used during the post-goal count-up celebration.
    // When nil, cards display the live server values. When set, they
    // display these interpolated values instead while ticking up.
    @State private var displayedCoins: Int? = nil
    @State private var displayedKg: Int? = nil
    @State private var celebrating = false

    // Zero-coin state stays visually loud (the "0" is motivating) but we
    // bolt an explicit CTA underneath so the user knows where to go next.
    private var hasNoCoins: Bool { app.coinsTotal == 0 }

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                HomeHeader(onMenu: onMenu)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("You are well on your ")
                            .font(.atmosmBody)
                            .foregroundStyle(AppColor.textPrimary)
                        + Text("#NetZeroMe")
                            .font(.atmosmBody.bold())
                            .foregroundStyle(AppColor.primaryNavy)
                        + Text(" journey. Awareness is key in this transition.")
                            .font(.atmosmBody)
                            .foregroundStyle(AppColor.textPrimary)

                        Text("You have...")
                            .font(.atmosmBody)
                            .foregroundStyle(AppColor.textPrimary)
                            .padding(.top, 8)

                        CoinCardView(
                            style: .navyCoin,
                            value: displayedCoins ?? app.coinsTotal,
                            title: "Atmosm Coins",
                            prefix: nil,
                            boosted: celebrating
                        )

                        Text("Which is equivalent to")
                            .font(.atmosmBody)
                            .foregroundStyle(AppColor.textPrimary)
                            .padding(.top, 8)

                        CoinCardView(
                            style: .slateCloud,
                            value: displayedKg ?? app.coinsEquivalentKg,
                            title: "kg of CO₂",
                            prefix: "reducing",
                            boosted: celebrating
                        )

                        if hasNoCoins {
                            zeroCoinCTA
                                .padding(.top, 4)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        Group {
                            Text("Remember you need to reduce or offset ")
                            + Text("\(app.coinsNeededForNetZero.formatted()) kg")
                                .font(.atmosmBody.bold())
                            + Text(" to collect enough coins to go ")
                            + Text("#NetZero")
                                .font(.atmosmBody.bold())
                                .foregroundColor(AppColor.primaryNavy)
                            + Text(".")
                        }
                        .font(.atmosmBody)
                        .foregroundStyle(AppColor.textPrimary)
                        .minimumScaleFactor(0.85)
                        .padding(.top, 12)

                        PrimaryButton(title: "See your footprint", style: .navy) {
                            onShowFootprint()
                        }
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
        }
        .task {
            await app.reloadFromServer()
            await app.loadCatalog()
            // If we landed on Home because a goal was just completed,
            // run the celebration as soon as the view appears.
            await runCelebrationIfPending()
        }
        .onChange(of: app.pendingCoinCelebration) { _, new in
            guard new != nil else { return }
            Task { await runCelebrationIfPending() }
        }
        .refreshable {
            await app.reloadFromServer(force: true)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: app.coinsTotal)
    }

    // Drives the count-up. Starts at the old totals captured at the
    // moment of completion and walks both coin + kg values up to the
    // new server totals in lockstep. On each tick SwiftUI's numericText
    // contentTransition rolls the digits smoothly.
    private func runCelebrationIfPending() async {
        guard let snapshot = app.pendingCoinCelebration else { return }
        let targetCoins = app.coinsTotal
        let targetKg    = app.coinsEquivalentKg

        // If nothing actually changed (e.g. server returned same totals),
        // bail without any fanfare to avoid a misleading stuck animation.
        guard targetCoins > snapshot.oldCoins || targetKg > snapshot.oldKg else {
            await MainActor.run { app.pendingCoinCelebration = nil }
            return
        }

        // Reduce Motion: skip the count-up, keep the cards at live values.
        if reduceMotion {
            Haptics.success()
            await MainActor.run { app.pendingCoinCelebration = nil }
            return
        }

        await MainActor.run {
            displayedCoins = snapshot.oldCoins
            displayedKg    = snapshot.oldKg
            celebrating    = true
        }

        // Tick ~60 fps, incrementing each value until it reaches the
        // target. We advance both independently so if the two deltas
        // differ the "slower" one still finishes smoothly. For large
        // rewards (>60 coins) we step by more than 1 per tick so a
        // 500-coin reward still completes in ~1.5s instead of 8s.
        let tickNanos: UInt64 = 16_000_000  // ~16ms (60fps)
        let deltaCoins = max(targetCoins - snapshot.oldCoins, 0)
        let deltaKg    = max(targetKg    - snapshot.oldKg,    0)
        let totalDurationSec: Double = 1.5
        let totalTicks = max(Int(totalDurationSec / 0.016), 1)
        let stepCoins = max(deltaCoins / totalTicks, 1)
        let stepKg    = max(deltaKg    / totalTicks, 1)

        var c = snapshot.oldCoins
        var k = snapshot.oldKg
        while c < targetCoins || k < targetKg {
            try? await Task.sleep(nanoseconds: tickNanos)
            c = min(c + stepCoins, targetCoins)
            k = min(k + stepKg,    targetKg)
            await MainActor.run {
                displayedCoins = c
                displayedKg    = k
            }
        }

        // Settle: release the overrides, drop the glow/boost, fire a
        // final success haptic to punctuate.
        Haptics.success()
        await MainActor.run {
            displayedCoins = nil
            displayedKg    = nil
            celebrating    = false
            app.pendingCoinCelebration = nil
        }
    }

    // Compact nudge shown only while coins == 0, sitting between the
    // two coin cards and the NetZero reminder. Doesn't hide the "0" —
    // it reinforces it with a clear next step.
    private var zeroCoinCTA: some View {
        Button(action: onBrowseReduce) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Earn your first coins")
                        .font(.atmosmBody.bold())
                        .foregroundStyle(AppColor.primaryNavy)
                    Text("Add a goal in Reduce — get +5 coins just for committing.")
                        .font(.atmosmCaption)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.primaryNavy)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            )
        }
        .buttonStyle(.atmosm)
    }
}

struct HomeHeader: View {
    let onMenu: () -> Void
    var body: some View {
        ZStack {
            HStack {
                IconButton(
                    systemName: "line.3.horizontal",
                    accessibilityLabel: "Menu",
                    size: 22,
                    action: onMenu
                )
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }

            AtmosmLogoImage()
                .frame(width: 44, height: 54)
        }
    }
}

#Preview {
    HomeView(app: AppState(), onShowFootprint: {}, onBrowseReduce: {}, onMenu: {})
}
