import SwiftUI

struct DonutSegment: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let value: Double
    let color: Color
}

// Carbon footprint donut chart with a center label and an optional highlight tooltip.
struct DonutChart: View {
    let segments: [DonutSegment]
    let centerValue: String
    let centerLabel: String

    // Optional highlighted segment (e.g. "20%") positioned on the ring.
    var highlightIndex: Int? = nil
    var highlightText: String? = nil

    private let lineWidth: CGFloat = 32

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2 - lineWidth / 2
            let sum = segments.reduce(0) { $0 + $1.value }

            ZStack {
                // Ring segments
                ForEach(Array(segments.enumerated()), id: \.offset) { idx, seg in
                    let (start, end) = angles(upTo: idx, segments: segments, total: sum)
                    Circle()
                        .trim(from: start, to: end)
                        .stroke(seg.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                        .rotationEffect(.degrees(-90))
                        .frame(width: radius * 2, height: radius * 2)
                }

                // Center number
                VStack(spacing: 2) {
                    Text(centerValue)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(AppColor.primaryNavy)
                    Text(centerLabel)
                        .font(.atmosmCaption.bold())
                        .foregroundStyle(AppColor.textSecondary)
                }

                // Optional highlight label (e.g. "20%" tooltip)
                if let idx = highlightIndex, let txt = highlightText, idx < segments.count {
                    let (start, end) = angles(upTo: idx, segments: segments, total: sum)
                    let mid = (start + end) / 2
                    let angle = Angle(radians: Double(mid) * 2 * .pi - .pi / 2)
                    let x = cos(angle.radians) * Double(radius)
                    let y = sin(angle.radians) * Double(radius)
                    Text(txt)
                        .font(.atmosmCaption.bold())
                        .foregroundStyle(AppColor.textPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.white))
                        .overlay(Capsule().stroke(AppColor.fieldBorder, lineWidth: 1))
                        .offset(x: x, y: y)
                }
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func angles(upTo index: Int, segments: [DonutSegment], total: Double) -> (CGFloat, CGFloat) {
        guard total > 0 else { return (0, 0) }
        var start: Double = 0
        for i in 0..<index { start += segments[i].value / total }
        let seg = segments[index].value / total
        return (CGFloat(start), CGFloat(start + seg))
    }
}

#Preview {
    DonutChart(
        segments: [
            .init(label: "Flights",   value: 22, color: AppColor.chartGreen),
            .init(label: "Energy",    value: 18, color: AppColor.primaryNavy),
            .init(label: "Lifestyle", value: 22, color: AppColor.chartPurple),
            .init(label: "Driving",   value: 22, color: AppColor.chartRed),
            .init(label: "Food",      value: 16, color: AppColor.chartOrange)
        ],
        centerValue: "5.9",
        centerLabel: "TONS",
        highlightIndex: 1,
        highlightText: "20%"
    )
    .frame(width: 260, height: 260)
    .padding()
    .background(AppColor.lightBlueBackground)
}
