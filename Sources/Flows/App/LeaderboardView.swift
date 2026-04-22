import SwiftUI

// A single source of truth for the leaderboard screen's state.
// Using an enum prevents illegal combinations like `isLoading=true` while
// also having `entries != []` and `errorMessage != nil` all at once.
private enum LeaderboardPhase: Equatable {
    case idle
    case loading             // first load — show full-width spinner
    case refreshing          // subsequent reload — keep old list visible
    case loaded
    case failed(String)
}

struct LeaderboardView: View {
    @Bindable var app: AppState
    let onMenu: () -> Void

    @State private var scope: LeaderboardScope = .global
    @State private var entries: [LeaderboardEntry] = []
    @State private var myRank: Int? = nil
    @State private var phase: LeaderboardPhase = .idle

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
                    switch phase {
                    case .loading:
                        HStack { Spacer(); ProgressView(); Spacer() }
                            .padding(.vertical, 24)
                    case .failed(let err) where entries.isEmpty:
                        Text(err)
                            .font(.atmosmCaption)
                            .foregroundStyle(.red)
                    case _ where entries.isEmpty && phase != .loading:
                        Text("No entries yet. Complete your onboarding to appear here.")
                            .font(.atmosmCaption)
                            .foregroundStyle(AppColor.textSecondary)
                            .padding(.vertical, 16)
                    default:
                        VStack(spacing: 0) {
                            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                                leaderboardRow(entry: entry)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                                    .animation(
                                        .spring(response: 0.45, dampingFraction: 0.85)
                                            .delay(Double(index) * 0.035),
                                        value: entries.map(\.id)
                                    )
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

            // Initials avatar — no stock photos. Fall back to an SF person
            // glyph if the user somehow has no initials (e.g. all-symbol name).
            ZStack {
                Circle().fill(AppColor.lightBluePill)
                let init_ = initials(for: entry)
                if init_.isEmpty {
                    Image(systemName: "person.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColor.primaryNavy)
                } else {
                    Text(init_)
                        .font(.atmosmCaption.bold())
                        .foregroundStyle(AppColor.primaryNavy)
                }
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
        await MainActor.run {
            phase = entries.isEmpty ? .loading : .refreshing
        }
        do {
            let res = try await NetworkService.shared.fetchLeaderboard(scope: scope, limit: 20)
            // If the enclosing Task was cancelled (e.g. SwiftUI killed the
            // pull-to-refresh task once the gesture ended), don't apply
            // anything — just exit quietly.
            try Task.checkCancellation()
            await MainActor.run {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    entries = res.entries
                }
                myRank = res.myRank
                phase  = .loaded
            }
        } catch is CancellationError {
            await MainActor.run { phase = entries.isEmpty ? .idle : .loaded }
        } catch let urlErr as URLError where urlErr.code == .cancelled {
            await MainActor.run { phase = entries.isEmpty ? .idle : .loaded }
        } catch {
            await MainActor.run { phase = .failed(error.localizedDescription) }
        }
    }
}

#Preview {
    LeaderboardView(app: AppState(), onMenu: {})
}
