import SwiftUI

// Brentford FC Match Day hub. Shows lifetime totals across all logged
// matches and a list of recent matches. CTA opens the logging form.
struct FanPageView: View {
    @Bindable var app: AppState
    let onBack: () -> Void
    let onLogMatch: () -> Void

    @State private var isLoading = false

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        summaryCard
                            .padding(.horizontal, 24)
                            .padding(.top, 16)

                        PrimaryButton(title: "Log Today's Match", style: .navy) {
                            onLogMatch()
                        }
                        .padding(.horizontal, 24)

                        recentMatchesSection
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .task { await refresh() }
        .refreshable { await refresh(force: true) }
    }

    // MARK: - Sections

    // Brentford-red banner + white page title. Keeps the IconButton back
    // chevron in the same spot as other detail views.
    private var header: some View {
        VStack(spacing: 0) {
            ZStack {
                AppColor.brentfordRed
                HStack(spacing: 12) {
                    IconButton(
                        systemName: "chevron.left",
                        accessibilityLabel: "Back",
                        size: 18,
                        color: .white,
                        action: onBack
                    )
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "shield.fill")
                            .foregroundStyle(.white)
                        Text("Brentford FC")
                            .font(.atmosmBody.bold())
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 12)
            }
            .frame(height: 52)

            Text("Match Day")
                .font(.atmosmTitle)
                .foregroundStyle(AppColor.primaryNavy)
                .padding(.top, 12)
        }
    }

    private var summaryCard: some View {
        let summary = app.matchSummary
        let count = summary?.matchCount ?? 0
        let savedKg = summary?.totalKgSaved ?? 0
        let emittedKg = summary?.totalKgEmitted ?? 0

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Match Day Footprint")
                        .font(.atmosmCaption.bold())
                        .foregroundStyle(AppColor.textSecondary)
                    Text("\(count) match\(count == 1 ? "" : "es") tracked")
                        .font(.atmosmBody.bold())
                        .foregroundStyle(AppColor.primaryNavy)
                }
                Spacer()
                Image(systemName: "shield.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(AppColor.brentfordRed)
            }

            Divider()

            HStack(alignment: .top, spacing: 24) {
                statBlock(
                    value: String(format: "%.1f kg", emittedKg),
                    label: "Total emitted",
                    color: AppColor.textPrimary
                )
                statBlock(
                    value: String(format: "%.1f kg", savedKg),
                    label: "Saved vs. avg fan",
                    color: AppColor.primaryGreen
                )
            }

            if count == 0 {
                Text("Log your first match to start tracking.")
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.textSecondary)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.large)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        )
    }

    private func statBlock(value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(color)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(label)
                .font(.atmosmCaption)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    private var recentMatchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Matches")
                .font(.atmosmBody.bold())
                .foregroundStyle(AppColor.primaryNavy)

            if isLoading && app.matchLogs.isEmpty {
                HStack { Spacer(); ProgressView(); Spacer() }
                    .padding(.vertical, 24)
            } else if app.matchLogs.isEmpty {
                Text("No matches yet. Tap Log Today's Match to get started.")
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 8) {
                    ForEach(app.matchLogs.prefix(5)) { entry in
                        matchRow(entry)
                    }
                }
            }
        }
    }

    private func matchRow(_ entry: MatchDayEntry) -> some View {
        let transport = MatchTransport(rawValue: entry.transport)
        return HStack(spacing: 12) {
            Image(systemName: transport?.systemIcon ?? "questionmark.circle")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppColor.primaryNavy)
                .frame(width: 36, height: 36)
                .background(Circle().fill(AppColor.lightBluePill))

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.matchDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.atmosmBody.bold())
                    .foregroundStyle(AppColor.textPrimary)
                Text("\(transport?.displayName ?? "?")  •  \(MatchFood(rawValue: entry.foodChoice)?.displayName ?? "No food")")
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f kg", entry.kgEmitted))
                    .font(.atmosmBody.bold())
                    .foregroundStyle(AppColor.textPrimary)
                Text("+\(entry.coinsEarned) coins")
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.primaryGreen)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.medium)
                .fill(Color.white)
        )
    }

    private func refresh(force: Bool = false) async {
        if !force && app.matchSummary != nil { return }
        await MainActor.run { isLoading = true }
        await app.loadMatchDay()
        await MainActor.run { isLoading = false }
    }
}

#Preview {
    FanPageView(app: AppState(), onBack: {}, onLogMatch: {})
}
