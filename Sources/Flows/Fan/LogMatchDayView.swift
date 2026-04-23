import SwiftUI

// 3-step wizard for logging a match:
//   1. Travel     — transport mode + rough-distance bucket
//   2. Food       — broad diet category (skipped / plant / veggie / meat)
//   3. Habits     — recycled? / reusable cup?
//
// On submit: POSTs to /match-day, the server rolls kg + coins into
// the user's annual totals, and we stash a CoinCelebration snapshot
// so Home's existing count-up + golden glow fires when we land there.
struct LogMatchDayView: View {
    @Bindable var app: AppState
    let onBack: () -> Void

    // MARK: - State

    @State private var step: Step = .travel

    @State private var transport: MatchTransport = .bus
    @State private var distanceBucket: MatchDistanceBucket = .nearby
    @State private var food: MatchFood = .meat
    @State private var recycled: Bool? = true
    @State private var reusableCup: Bool? = false

    @State private var isSubmitting = false
    @State private var errorMessage: String? = nil

    enum Step: Int, CaseIterable {
        case travel = 0, food, habits

        var title: String {
            switch self {
            case .travel: return "How did you get there?"
            case .food:   return "What did you eat?"
            case .habits: return "Anything sustainable?"
            }
        }

        var subtitle: String {
            switch self {
            case .travel: return "Pick your transport and rough distance."
            case .food:   return "Pick the closest match — we'll handle the rest."
            case .habits: return "These small choices add up to fewer kg."
            }
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                // Step indicator — 3 dots, filled for current/past,
                // outline for upcoming. Haptic tap moves through.
                stepIndicator
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    .padding(.bottom, 12)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(step.title)
                            .font(.atmosmHeadline)
                            .foregroundStyle(AppColor.primaryNavy)

                        Text(step.subtitle)
                            .font(.atmosmBody)
                            .foregroundStyle(AppColor.textSecondary)
                            .padding(.bottom, 4)

                        // Slide the step body in from the trailing edge
                        // when advancing, trailing edge when going back.
                        // Identity on Step.rawValue so each step is its
                        // own subtree for SwiftUI's transition diffing.
                        Group {
                            switch step {
                            case .travel: travelStep
                            case .food:   foodStep
                            case .habits: habitsStep
                            }
                        }
                        .id(step.rawValue)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .leading).combined(with: .opacity)
                        ))

                        if let err = errorMessage {
                            Text(err)
                                .font(.atmosmCaption)
                                .foregroundStyle(AppColor.accentRed)
                        }

                        footerButtons
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: - Chrome

    private var header: some View {
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
    }

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(Step.allCases, id: \.rawValue) { s in
                Capsule()
                    .fill(s.rawValue <= step.rawValue ? AppColor.primaryNavy : AppColor.stepInactive)
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Step 1: Travel

    private var travelStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Transport")
                .font(.atmosmCaption.bold())
                .foregroundStyle(AppColor.textSecondary)

            let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(MatchTransport.allCases, id: \.self) { mode in
                    transportChip(mode)
                }
            }

            // Active travel produces zero direct emissions, so asking
            // for distance is pointless noise — skip the bucket picker.
            if transport != .walk && transport != .bike {
                Text("Rough round-trip distance")
                    .font(.atmosmCaption.bold())
                    .foregroundStyle(AppColor.textSecondary)
                    .padding(.top, 4)

                VStack(spacing: 8) {
                    ForEach(MatchDistanceBucket.allCases) { bucket in
                        distanceRow(bucket)
                    }
                }
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

    private func distanceRow(_ bucket: MatchDistanceBucket) -> some View {
        let selected = (distanceBucket == bucket)
        return Button {
            Haptics.tap()
            distanceBucket = bucket
        } label: {
            HStack(spacing: 12) {
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
                VStack(alignment: .leading, spacing: 2) {
                    Text(bucket.displayName)
                        .font(.atmosmBody.bold())
                        .foregroundStyle(AppColor.textPrimary)
                    Text(bucket.helperText)
                        .font(.atmosmCaption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .stroke(selected ? AppColor.primaryNavy : AppColor.fieldBorder,
                            lineWidth: selected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 2: Food

    private var foodStep: some View {
        VStack(spacing: 10) {
            ForEach(MatchFood.allCases, id: \.self) { opt in
                foodCard(opt)
            }
        }
    }

    private func foodCard(_ opt: MatchFood) -> some View {
        let selected = (food == opt)
        return Button {
            Haptics.tap()
            food = opt
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.small)
                        .fill(Color(hex: opt.tint).opacity(selected ? 1.0 : 0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: opt.systemIcon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(selected ? .white : Color(hex: opt.tint))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(opt.displayName)
                        .font(.atmosmBody.bold())
                        .foregroundStyle(AppColor.textPrimary)
                    Text(opt.helperText)
                        .font(.atmosmCaption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(AppColor.primaryNavy)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .stroke(selected ? AppColor.primaryNavy : AppColor.fieldBorder,
                            lineWidth: selected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 3: Habits

    private var habitsStep: some View {
        VStack(spacing: 10) {
            habitToggle(
                title: "Recycled your waste",
                systemIcon: "arrow.3.trianglepath",
                value: $recycled
            )
            habitToggle(
                title: "Brought a reusable cup",
                systemIcon: "cup.and.saucer.fill",
                value: $reusableCup
            )
        }
    }

    private func habitToggle(title: String, systemIcon: String, value: Binding<Bool?>) -> some View {
        let isOn = value.wrappedValue == true
        return Button {
            Haptics.tap()
            value.wrappedValue = !isOn
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.small)
                        .fill(isOn ? AppColor.primaryGreen : AppColor.lightBluePill)
                        .frame(width: 44, height: 44)
                    Image(systemName: systemIcon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isOn ? .white : AppColor.primaryNavy)
                }
                Text(title)
                    .font(.atmosmBody.bold())
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                // A real Toggle styled to match the card. Using a plain
                // image + the outer Button's tap gives us a bigger hit
                // target than an inline Toggle would.
                ZStack {
                    Capsule()
                        .fill(isOn ? AppColor.primaryGreen : AppColor.stepInactive)
                        .frame(width: 42, height: 26)
                    Circle()
                        .fill(.white)
                        .frame(width: 20, height: 20)
                        .offset(x: isOn ? 8 : -8)
                        .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .stroke(AppColor.fieldBorder, lineWidth: 1)
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isOn)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Footer navigation

    private var footerButtons: some View {
        VStack(spacing: 10) {
            PrimaryButton(
                title: isSubmitting ? "Logging…" : primaryTitle,
                style: .navy
            ) {
                Task { await advanceOrSubmit() }
            }
            .disabled(isSubmitting)

            if step != .travel {
                Button {
                    Haptics.tap()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        step = Step(rawValue: step.rawValue - 1) ?? .travel
                    }
                } label: {
                    Text("Back")
                        .font(.atmosmBody.bold())
                        .foregroundStyle(AppColor.primaryNavy)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.plain)
                .disabled(isSubmitting)
            }
        }
    }

    private var primaryTitle: String {
        step == .habits ? "Log Match" : "Next"
    }

    private func advanceOrSubmit() async {
        if step != .habits {
            Haptics.tap()
            await MainActor.run {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    step = Step(rawValue: step.rawValue + 1) ?? .habits
                }
            }
            return
        }
        await submit()
    }

    // MARK: - Submit

    private func submit() async {
        guard !isSubmitting else { return }
        let distanceKm = (transport == .walk || transport == .bike)
            ? 0
            : distanceBucket.representativeKm

        await MainActor.run {
            isSubmitting = true
            errorMessage = nil
        }

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
            await app.reloadFromServer(force: true)
            await app.loadMatchDay()

            await MainActor.run {
                app.pendingCoinCelebration = CoinCelebration(
                    reward:    resp.coinsEarned,
                    oldCoins:  oldCoins,
                    oldKg:     oldKg
                )
                Haptics.success()
                app.selectedTab = .home
                isSubmitting = false
                onBack()
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
