import SwiftUI

struct DonutSegment: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let value: Double
    let color: Color
}

// Carbon footprint donut chart with a center label and an optional highlight tooltip.
// Pass `animated: true` to get an entry radial-sweep: segments draw from 0 to
// their final arcs and the center value counts up in sync. Existing callers
// that don't pass the flag keep rendering instantly as before.
struct DonutChart: View {
    let segments: [DonutSegment]
    let centerValue: String
    let centerLabel: String

    // Optional highlighted segment (e.g. "20%") positioned on the ring.
    var highlightIndex: Int? = nil
    var highlightText: String? = nil

    // Radial-draw entry animation toggle.
    var animated: Bool = false

    private let lineWidth: CGFloat = 32

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress: CGFloat = 0

    // Cached formatters — creating one per frame during the count-up
    // animation caused measurable CPU. One per decimal-place is plenty.
    private static let formatters: [Int: NumberFormatter] = {
        var map: [Int: NumberFormatter] = [:]
        for d in 0...3 {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.minimumFractionDigits = d
            f.maximumFractionDigits = d
            map[d] = f
        }
        return map
    }()

    var body: some View {
        // Rely on the parent's explicit .frame(width:height:) instead of
        // a GeometryReader. Every existing caller already pins a size, so
        // this drops a layout pass and keeps the view self-sizing.
        content
    }

    @ViewBuilder
    private var content: some View {
        let sum = segments.reduce(0) { $0 + $1.value }

        ZStack {
            // Ring segments. When animating, each segment's visible arc
            // is its final arc multiplied by `progress`, so the ring
            // sweeps smoothly clockwise from 12-o'clock.
            ForEach(Array(segments.enumerated()), id: \.offset) { idx, seg in
                let (start, end) = animatedAngles(upTo: idx, segments: segments, total: sum)
                Circle()
                    .trim(from: start, to: end)
                    .stroke(seg.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                    .rotationEffect(.degrees(-90))
                    .padding(lineWidth / 2)
            }

            // Center number. When animating, counts up from 0 to the real
            // value by interpolating the parsed double against `progress`.
            VStack(spacing: 2) {
                Text(displayedCenterValue)
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(AppColor.primaryNavy)
                    .contentTransition(.numericText())
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(centerLabel)
                    .font(.atmosmCaption.bold())
                    .foregroundStyle(AppColor.textSecondary)
            }

            // Optional highlight label (e.g. "20%" tooltip). Held back until
            // the sweep is ~80% done so it doesn't appear over empty space.
            if let idx = highlightIndex, let txt = highlightText, idx < segments.count {
                GeometryReader { geo in
                    let radius = min(geo.size.width, geo.size.height) / 2 - lineWidth / 2
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
                        .position(
                            x: geo.size.width  / 2 + x,
                            y: geo.size.height / 2 + y
                        )
                        .opacity(highlightOpacity)
                }
            }
        }
        .onAppear {
            guard animated else { progress = 1; return }
            if reduceMotion {
                progress = 1
            } else {
                withAnimation(.easeOut(duration: 0.9)) {
                    progress = 1
                }
            }
        }
    }

    // MARK: - Geometry

    private func angles(upTo index: Int, segments: [DonutSegment], total: Double) -> (CGFloat, CGFloat) {
        guard total > 0 else { return (0, 0) }
        var start: Double = 0
        for i in 0..<index { start += segments[i].value / total }
        let seg = segments[index].value / total
        return (CGFloat(start), CGFloat(start + seg))
    }

    private func animatedAngles(upTo index: Int, segments: [DonutSegment], total: Double) -> (CGFloat, CGFloat) {
        let (start, end) = angles(upTo: index, segments: segments, total: total)
        let p = animated ? progress : 1
        return (start * p, end * p)
    }

    // MARK: - Center value animation

    private var displayedCenterValue: String {
        guard animated else { return centerValue }
        let p = Double(progress)
        let normalized = centerValue.replacingOccurrences(of: ",", with: "")
        guard let target = Double(normalized) else { return centerValue }
        let current = target * p
        let decimals = decimalPlaces(in: centerValue)
        return formatted(current, decimals: decimals)
    }

    private var highlightOpacity: Double {
        guard animated else { return 1 }
        let p = Double(progress)
        return max(0, min(1, (p - 0.75) / 0.20))
    }

    private func decimalPlaces(in s: String) -> Int {
        if let dot = s.firstIndex(of: ".") {
            let tail = s[s.index(after: dot)...]
            return tail.filter(\.isNumber).count
        }
        return 0
    }

    private func formatted(_ v: Double, decimals: Int) -> String {
        let d = min(max(decimals, 0), 3)
        return Self.formatters[d]?.string(from: NSNumber(value: v)) ?? "\(v)"
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
        highlightText: "20%",
        animated: true
    )
    .frame(width: 260, height: 260)
    .padding()
    .background(AppColor.lightBlueBackground)
}
