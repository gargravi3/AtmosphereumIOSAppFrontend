import SwiftUI

// Single-screen form for logging a match day. On submit, POSTs to the
// backend, which computes kg + coins, rolls them into the user's
// annual tons + coins totals, and returns the new totals.
//
// We stash the coin snapshot into AppState.pendingCoinCelebration right
// before popping, so Home's existing count-up celebration fires when
// the user next lands there.
struct LogMatchDayView: View {
    @Bindable var app: AppState
    let onBack: () -> Void

    @State private var transport: MatchTransport = .bus
    @State private var distanceKmStr: String = "12"   // round trip default
    @State private var food: MatchFood = .plantBased
    @State private var recycled: Bool? = true
    @State private var reusableCup: Bool? = false

    @State private var isSubmitting = false
    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        IconButton(systemName: "chevron.left", accessibilityLabel: "Back", action: onBack)
                        Spacer()
                    }
                    Text("Log Match")
                        .font(.atmosmTitle)
                        .foregroundStyle(AppColor.primaryNavy)
                }
                .padding(.horizontal, 12)
                .padding(.top, 4)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        transportSection
                        foodSection
                        habitsSection

                        if let err = errorMessage {
                            Text(err)
                                .font(.atmosmCaption)
                                .foregroundStyle(AppColor.accentRed)
                        }

                        PrimaryButton(title: isSubmitting ? "Logging…" : "Log Match", style: .navy) {
                            Task { await submit() }
                        }
                        .disabled(isSubmitting)
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: - Sections

    private var transportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How did you get there?")
                .font(.atmosmBody.bold())
                .foregroundStyle(AppColor.textPrimary)

            // 3-column grid of transport chips. Tapping one selects it.
            let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(MatchTransport.allCases, id: \.self) { mode in
                    transportChip(mode)
                }
            }

            if transport != .walk && transport != .bike {
                HStack {
                    Text("Round trip (km)")
                        .font(.atmosmBody)
                        .foregroundStyle(AppColor.textPrimary)
                    Spacer()
                    TextField("0", text: $distanceKmStr)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.small)
                                .fill(AppColor.fieldBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppRadius.small)
                                        .stroke(AppColor.fieldBorder, lineWidth: 1)
                                )
                        )
                }
                .padding(.top, 4)
            }
        }
    }

    private func transportChip(_ mode: MatchTransport) -> some View {
        let selected = (transport == mode)
        return Button {
            Haptics.tap()
            transport = mode
        } label: {
            VStack(spacing: 6) {
                Image(systemName: mode.systemIcon)
                    .font(.system(size: 20, weight: .semibold))
                Text(mode.displayName)
                    .font(.atmosmCaption.bold())
            }
            .foregroundStyle(selected ? .white : AppColor.primaryNavy)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .fill(selected ? AppColor.primaryNavy : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .stroke(selected ? Color.clear : AppColor.fieldBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var foodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What did you eat at the stadium?")
                .font(.atmosmBody.bold())
                .foregroundStyle(AppColor.textPrimary)

            VStack(spacing: 6) {
                ForEach(MatchFood.allCases, id: \.self) { opt in
                    foodRow(opt)
                }
            }
        }
    }

    private func foodRow(_ opt: MatchFood) -> some View {
        let selected = (food == opt)
        return Button {
            Haptics.tap()
            food = opt
        } label: {
            HStack {
                ZStack {
                    Circle()
                        .stroke(AppColor.primaryNavy, lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if selected {
                        Circle()
                            .fill(AppColor.primaryNavy)
                            .frame(width: 12, height: 12)
                    }
                }
                Text(opt.displayName)
                    .font(.atmosmBody)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Stadium habits")
                .font(.atmosmBody.bold())
                .foregroundStyle(AppColor.textPrimary)
            YesNoRow(label: "Recycled your waste?",  value: $recycled)
            YesNoRow(label: "Brought a reusable cup?", value: $reusableCup)
        }
    }

    // MARK: - Submit

    private func submit() async {
        guard !isSubmitting else { return }
        let distanceKm = (transport == .walk || transport == .bike)
            ? 0
            : (Double(distanceKmStr) ?? 0)

        await MainActor.run {
            isSubmitting = true
            errorMessage = nil
        }

        // Snapshot coin totals BEFORE the server roll-up so Home's
        // celebration count-up has something to tick from.
        let oldCoins = app.coinsTotal
        let oldKg    = app.coinsEquivalentKg

        let payload = MatchDayLogRequest(
            club: "brentford",
            matchDate: Date(),
            transport: transport.rawValue,
            distanceKm: distanceKm,
            foodChoice: food.rawValue,
            recycled: recycled ?? false,
            reusableCup: reusableCup ?? false
        )
        do {
            let resp = try await NetworkService.shared.logMatchDay(payload)
            // Force-refresh so tonsTotal + coinsTotal reflect the new
            // server state. This also repopulates matchLogs/summary.
            await app.reloadFromServer(force: true)
            await app.loadMatchDay()

            await MainActor.run {
                // Push a celebration snapshot so Home runs its count-up.
                // reward is the coins just earned; old totals are the
                // pre-POST snapshot we captured above.
                app.pendingCoinCelebration = CoinCelebration(
                    reward:    resp.coinsEarned,
                    oldCoins:  oldCoins,
                    oldKg:     oldKg
                )
                Haptics.success()
                app.selectedTab = .home
                isSubmitting = false
                onBack()  // pop this flow
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isSubmitting = false
                Haptics.error()
            }
        }
    }
}

#Preview {
    LogMatchDayView(app: AppState(), onBack: {})
}
