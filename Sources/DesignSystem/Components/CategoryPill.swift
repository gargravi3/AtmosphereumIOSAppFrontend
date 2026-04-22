import SwiftUI

// Small rounded color pill used on Home screen (Flights / Energy / Lifestyle / Driving / Food).
struct CategoryPill: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.atmosmCaption.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(Capsule().fill(color))
    }
}

// Small colored dot used in chart legends.
struct LegendDot: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(label)
                .font(.atmosmCaption)
                .foregroundStyle(AppColor.textPrimary)
        }
    }
}
