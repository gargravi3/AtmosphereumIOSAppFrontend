import SwiftUI

// Donut-chart "Your Footprint" view — extracted from the old Home screen.
// Now reachable via the Home screen's "See your footprint" button.
struct FootprintDetailView: View {
    @Bindable var app: AppState
    let onBack: () -> Void
    let onRefine: () -> Void

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        IconButton(systemName: "chevron.left", accessibilityLabel: "Back", action: onBack)
                        Spacer()
                    }
                    Text("Your Footprint")
                        .font(.atmosmTitle)
                        .foregroundStyle(AppColor.primaryNavy)
                }
                .padding(.horizontal, 12)
                .padding(.top, 4)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        DonutChart(
                            segments: app.breakdown,
                            centerValue: String(format: "%.1f", app.displayTons),
                            centerLabel: "TONS",
                            highlightIndex: topContributorIndex,
                            highlightText: topContributorPercent,
                            animated: true
                        )
                        .frame(width: 240, height: 240)
                        .padding(.top, 24)

                        FlowLayout(spacing: 10, lineSpacing: 10) {
                            ForEach(app.breakdown.filter { $0.value > 0 }, id: \.self) { seg in
                                CategoryPill(title: seg.label, color: seg.color)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 24)

                        VStack(spacing: 2) {
                            Text("Your annual carbon footprint is")
                                .font(.atmosmBody)
                                .foregroundStyle(AppColor.textPrimary)
                            Text(String(format: "%.1f Tons CO₂", app.displayTons))
                                .font(.atmosmBody.bold())
                                .foregroundStyle(AppColor.textPrimary)
                        }
                        .padding(.top, 4)

                        PrimaryButton(title: "Refine Your Estimate", style: .navy) {
                            onRefine()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }

    private var topContributorIndex: Int {
        let segs = app.breakdown
        guard let idx = segs.indices.max(by: { segs[$0].value < segs[$1].value }) else { return 0 }
        return idx
    }

    private var topContributorPercent: String {
        let total = app.breakdown.reduce(0) { $0 + $1.value }
        guard total > 0 else { return "" }
        let top = app.breakdown[topContributorIndex].value
        return "\(Int((top / total * 100).rounded()))%"
    }
}

#Preview {
    FootprintDetailView(app: AppState(), onBack: {}, onRefine: {})
}
