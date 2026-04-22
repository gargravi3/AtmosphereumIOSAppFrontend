import SwiftUI

// Slider with discrete textual labels underneath (e.g. Never / Sometimes / Mostly / Always).
// Stores an Int index from 0..<labels.count.
struct LabeledSlider: View {
    @Binding var value: Int
    let labels: [String]

    var body: some View {
        VStack(spacing: 8) {
            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0.rounded()) }
                ),
                in: 0...Double(max(labels.count - 1, 1)),
                step: 1
            )
            .tint(AppColor.primaryNavy)

            HStack {
                ForEach(Array(labels.enumerated()), id: \.offset) { idx, label in
                    Text(label)
                        .font(.atmosmCaption)
                        .foregroundStyle(AppColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: alignment(for: idx))
                }
            }
        }
    }

    private func alignment(for idx: Int) -> Alignment {
        if idx == 0 { return .leading }
        if idx == labels.count - 1 { return .trailing }
        return .center
    }
}

// Slider with continuous value + end-cap labels and a "pill" showing the current value below the thumb.
struct RangeSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let leftLabel: String
    let rightLabel: String
    let valueFormatter: (Double) -> String

    var body: some View {
        VStack(spacing: 6) {
            Slider(value: $value, in: range)
                .tint(AppColor.primaryNavy)

            HStack {
                Text(leftLabel)
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                Text(valueFormatter(value))
                    .font(.atmosmCaption.bold())
                    .foregroundStyle(AppColor.primaryNavy)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(AppColor.lightBluePill))
                Spacer()
                Text(rightLabel)
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.textPrimary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        LabeledSlider(value: .constant(2), labels: ["Never","Sometimes","Mostly","Always"])
        RangeSlider(
            value: .constant(1000),
            range: 0...10_000,
            leftLabel: "0 km",
            rightLabel: "> 10,000 km",
            valueFormatter: { "\(Int($0)) Kms" }
        )
    }
    .padding()
    .background(AppColor.lightBlueBackground)
}
