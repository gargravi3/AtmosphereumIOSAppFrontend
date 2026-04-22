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
                            value: app.coinsTotal,
                            title: "Atmosm Coins",
                            prefix: nil
                        )

                        Text("Which is equivalent to")
                            .font(.atmosmBody)
                            .foregroundStyle(AppColor.textPrimary)
                            .padding(.top, 8)

                        CoinCardView(
                            style: .slateCloud,
                            value: app.coinsEquivalentKg,
                            title: "kg of CO₂",
                            prefix: "reducing"
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
        }
        .refreshable {
            await app.reloadFromServer(force: true)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: app.coinsTotal)
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
