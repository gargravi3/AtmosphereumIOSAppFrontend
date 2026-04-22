import SwiftUI

struct LeaderboardView: View {
    @Bindable var app: AppState
    let onMenu: () -> Void

    @State private var scope: LeaderboardScope = .global
    @State private var entries: [LeaderboardEntry] = []
    @State private var myRank: Int? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Top chart panel (light-blue bg)
                VStack(spacing: 16) {
                    HomeHeader(onMenu: onMenu)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)

                    StackedBarChart(bars: [
                        .init(label: "You",    total: app.displayTons, segments: app.breakdown),
                        .init(label: "UAE",    total: 2.4, segments: scaled(app.breakdown, to: 2.4)),
                        .init(label: "Global", total: 4.1, segments: scaled(app.breakdown, to: 4.1))
                    ], maxHeight: 240)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    FlowLayout(spacing: 16, lineSpacing: 8) {
                        LegendDot(color: AppColor.chartRed,    label: "Driving")
                        LegendDot(color: AppColor.chartGreen,  label: "Flights")
                        LegendDot(color: AppColor.primaryNavy, label: "Energy")
                        LegendDot(color: AppColor.chartPurple, label: "Lifestyle")
                        LegendDot(color: AppColor.chartOrange, label: "Food")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .background(AppColor.lightBlueBackground)

                // Bottom leaderboard list (white bg)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Leaderboard")
                        .font(.atmosmTitle)
                        .foregroundStyle(AppColor.primaryNavy)
                        .frame(maxWidth: .infinity, alignment: .center)

                    // Scope picker — each tap refetches the list in that scope.
                    HStack(spacing: 8) {
                        scopeChip(.global,       label: "Global")
                        scopeChip(.country,      label: "My Country")
                        scopeChip(.organization, label: "My Industry")
                    }

                    if let rank = myRank, !entries.contains(where: { $0.isMe }) {
                        Text("Your current rank: #\(rank)")
                            .font(.atmosmCaption)
                            .foregroundStyle(AppColor.textSecondary)
                    }

                    // Show the full-width spinner only on the very first
                    // load. Later refreshes (pull-to-refresh, scope changes)
                    // keep the last-known list visible underneath so rows
                    // don't flash in/out.
                    if isLoading && entries.isEmpty {
                        HStack { Spacer(); ProgressView(); Spacer() }
                            .padding(.vertical, 24)
                    } else if entries.isEmpty, let err = errorMessage {
                        Text(err)
                            .font(.atmosmCaption)
                            .foregroundStyle(.red)
                    } else if entries.isEmpty {
                        Text("No entries yet. Complete your onboarding to appear here.")
                            .font(.atmosmCaption)
                            .foregroundStyle(AppColor.textSecondary)
                            .padding(.vertical, 16)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(entries, id: \.id) { entry in
                                leaderboardRow(entry: entry)
                                Divider()
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .background(Color.white)
            }
        }
        .background(AppColor.lightBlueBackground)
        .navigationBarBackButtonHidden()
        .task { await reload() }
        .refreshable { await reload() }
        .onChange(of: scope) { _, _ in Task { await reload() } }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func scopeChip(_ s: LeaderboardScope, label: String) -> some View {
        let selected = (scope == s)
        Button(action: { scope = s }) {
            Text(label)
                .font(.atmosmCaption.bold())
                .foregroundStyle(selected ? .white : AppColor.primaryNavy)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(selected ? AppColor.primaryNavy : AppColor.lightBluePill)
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func leaderboardRow(entry: LeaderboardEntry) -> some View {
        HStack(spacing: 16) {
            // Rank badge
            Text("#\(entry.rank)")
                .font(.atmosmCaption.bold())
                .foregroundStyle(AppColor.primaryNavy)
                .frame(width: 32, alignment: .leading)

            // Initials avatar — no stock photos.
            ZStack {
                Circle().fill(AppColor.lightBluePill)
                Text(initials(for: entry))
                    .font(.atmosmCaption.bold())
                    .foregroundStyle(AppColor.primaryNavy)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.fullName)
                    .font(.atmosmBody)
                    .foregroundStyle(entry.isMe ? AppColor.primaryNavy : AppColor.textPrimary)
                    .fontWeight(entry.isMe ? .bold : .regular)
                if entry.isMe {
                    Text("You")
                        .font(.atmosmCaption)
                        .foregroundStyle(AppColor.primaryGreen)
                }
            }
            Spacer()
            Text(String(format: "%.2f Tons", entry.tonsTotal))
                .font(.atmosmBody.bold())
                .foregroundStyle(AppColor.textPrimary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, entry.isMe ? 8 : 0)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(entry.isMe ? AppColor.lightBluePill.opacity(0.6) : Color.clear)
        )
    }

    private func initials(for e: LeaderboardEntry) -> String {
        let f = e.firstName.first.map(String.init) ?? ""
        let l = e.lastName.first.map(String.init)  ?? ""
        return (f + l).uppercased()
    }

    private func scaled(_ segs: [DonutSegment], to total: Double) -> [DonutSegment] {
        let sum = segs.reduce(0) { $0 + $1.value }
        guard sum > 0 else { return segs }
        return segs.map { .init(label: $0.label, value: $0.value / sum * total, color: $0.color) }
    }

    private func reload() async {
        await MainActor.run { isLoading = true; errorMessage = nil }
        do {
            let res = try await NetworkService.shared.fetchLeaderboard(scope: scope, limit: 20)
            // If the enclosing Task was cancelled (e.g. SwiftUI killed the
            // pull-to-refresh task once the gesture ended), don't apply
            // anything — just exit quietly.
            try Task.checkCancellation()
            await MainActor.run {
                entries = res.entries
                myRank  = res.myRank
                isLoading = false
            }
        } catch is CancellationError {
            await MainActor.run { isLoading = false }
        } catch let urlErr as URLError where urlErr.code == .cancelled {
            await MainActor.run { isLoading = false }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

#Preview {
    LeaderboardView(app: AppState(), onMenu: {})
}
