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

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2 - lineWidth / 2
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
                        .frame(width: radius * 2, height: radius * 2)
                }

                // Center number. When animating, counts up from 0 to the real
                // value by interpolating the parsed double against `progress`.
                VStack(spacing: 2) {
                    Text(displayedCenterValue)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(AppColor.primaryNavy)
                        .contentTransition(.numericText())
                    Text(centerLabel)
                        .font(.atmosmCaption.bold())
                        .foregroundStyle(AppColor.textSecondary)
                }

                // Optional highlight label (e.g. "20%" tooltip). Held back until
                // the sweep is ~80% done so it doesn't appear over empty space.
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
                        .opacity(highlightOpacity)
                }
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    }

    // MARK: - Geometry

    // Final arc for a given segment — used for static positioning like the
    // highlight tooltip, which should sit on its real slice mid-angle even
    // while the ring is still being drawn.
    private func angles(upTo index: Int, segments: [DonutSegment], total: Double) -> (CGFloat, CGFloat) {
        guard total > 0 else { return (0, 0) }
        var start: Double = 0
        for i in 0..<index { start += segments[i].value / total }
        let seg = segments[index].value / total
        return (CGFloat(start), CGFloat(start + seg))
    }

    // Scaled arc used by the ring during the entry animation. When
    // `animated == false` or on first render before the animation kicks
    // in we still want the static chart to render, so we fall back to
    // progress == 1 in the non-animated branch.
    private func animatedAngles(upTo index: Int, segments: [DonutSegment], total: Double) -> (CGFloat, CGFloat) {
        let (start, end) = angles(upTo: index, segments: segments, total: total)
        let p = animated ? progress : 1
        return (start * p, end * p)
    }

    // MARK: - Center value animation

    // When animating, interpolate the numeric portion of `centerValue` so
    // the displayed text counts up from 0 to the real value. We keep the
    // user's formatting (decimal count, thousands separator) by looking at
    // the original string.
    private var displayedCenterValue: String {
        guard animated else { return centerValue }
        let p = Double(progress)
        // Try to parse a Double out of the label (supports "5.9", "1,234",
        // "15,000" etc.). If we can't parse one, fall back to the raw label.
        let normalized = centerValue.replacingOccurrences(of: ",", with: "")
        guard let target = Double(normalized) else { return centerValue }
        let current = target * p
        // Preserve decimal places from the original string.
        let decimals = decimalPlaces(in: centerValue)
        return formatted(current, decimals: decimals)
    }

    private var highlightOpacity: Double {
        guard animated else { return 1 }
        let p = Double(progress)
        // Fade in between 0.75 → 0.95 of the sweep.
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
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.minimumFractionDigits = decimals
        fmt.maximumFractionDigits = decimals
        return fmt.string(from: NSNumber(value: v)) ?? "\(v)"
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
