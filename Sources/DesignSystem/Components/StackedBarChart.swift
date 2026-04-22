import SwiftUI

struct StackedBar: Identifiable {
    let id = UUID()
    let label: String
    let total: Double
    // Segments stacked bottom-to-top
    let segments: [DonutSegment]
}

// Side-by-side stacked bar chart (e.g. You / UAE / Global, split by category).
struct StackedBarChart: View {
    let bars: [StackedBar]
    var totalFormatter: (Double) -> String = { String(format: "%.1f Tons", $0) }
    var maxHeight: CGFloat = 280

    var body: some View {
        let maxValue = max(bars.map { $0.total }.max() ?? 1, 1)

        HStack(alignment: .bottom, spacing: 24) {
            ForEach(bars) { bar in
                VStack(spacing: 8) {
                    Text(totalFormatter(bar.total))
                        .font(.atmosmCaption.bold())
                        .foregroundStyle(AppColor.textPrimary)

                    let scaled = CGFloat(bar.total / maxValue) * maxHeight
                    VStack(spacing: 0) {
                        // Bottom-to-top: iterate segments in reverse so bottom ones stay at bottom.
                        ForEach(bar.segments.reversed()) { seg in
                            Rectangle()
                                .fill(seg.color)
                                .frame(height: (CGFloat(seg.value / bar.total)) * scaled)
                        }
                    }
                    .frame(height: scaled)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .frame(maxWidth: .infinity)

                    Text(bar.label)
                        .font(.atmosmBody)
                        .foregroundStyle(AppColor.textPrimary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    StackedBarChart(bars: [
        .init(label: "You", total: 5.9, segments: [
            .init(label: "Driving",   value: 1.2, color: AppColor.chartRed),
            .init(label: "Flights",   value: 1.1, color: AppColor.chartGreen),
            .init(label: "Energy",    value: 1.3, color: AppColor.primaryNavy),
            .init(label: "Lifestyle", value: 1.3, color: AppColor.chartPurple),
            .init(label: "Food",      value: 1.0, color: AppColor.chartOrange)
        ]),
        .init(label: "UAE", total: 2.4, segments: [
            .init(label: "Driving",   value: 0.5, color: AppColor.chartRed),
            .init(label: "Flights",   value: 0.5, color: AppColor.chartGreen),
            .init(label: "Energy",    value: 0.5, color: AppColor.primaryNavy),
            .init(label: "Lifestyle", value: 0.5, color: AppColor.chartPurple),
            .init(label: "Food",      value: 0.4, color: AppColor.chartOrange)
        ]),
        .init(label: "Global", total: 4.1, segments: [
            .init(label: "Driving",   value: 0.8, color: AppColor.chartRed),
            .init(label: "Flights",   value: 0.9, color: AppColor.chartGreen),
            .init(label: "Energy",    value: 0.7, color: AppColor.primaryNavy),
            .init(label: "Lifestyle", value: 0.9, color: AppColor.chartPurple),
            .init(label: "Food",      value: 0.8, color: AppColor.chartOrange)
        ])
    ])
    .padding()
    .background(AppColor.lightBlueBackground)
}
