import SwiftUI

// Three-step progress indicator used across the post-signup onboarding flow.
// Matches the Figma layout: three small numbered circles on a horizontal bar
// with the bar filled up to the current step.
struct StepIndicator: View {
    let total: Int
    let current: Int // 1-indexed
    var activeColor: Color = AppColor.primaryNavy
    var inactiveColor: Color = AppColor.stepInactive

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let stepCount = max(total, 1)
            let stops: [CGFloat] = (0..<stepCount).map { i in
                CGFloat(i) / CGFloat(stepCount - 1)
            }
            let progress = CGFloat(max(0, min(current, stepCount) - 1)) / CGFloat(stepCount - 1)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(inactiveColor)
                    .frame(height: 4)

                Capsule()
                    .fill(activeColor)
                    .frame(width: width * progress, height: 4)

                ForEach(0..<stepCount, id: \.self) { i in
                    let isActive = (i + 1) <= current
                    ZStack {
                        Circle()
                            .fill(isActive ? activeColor : inactiveColor)
                            .frame(width: 16, height: 16)
                        Text("\(i + 1)")
                            .font(AppFont.bold(10))
                            .foregroundStyle(isActive ? .white : AppColor.textPrimary.opacity(0.6))
                    }
                    .offset(x: (width - 16) * stops[i])
                }
            }
        }
        .frame(height: 16)
    }
}

#Preview {
    VStack(spacing: 24) {
        StepIndicator(total: 3, current: 1)
        StepIndicator(total: 3, current: 2)
        StepIndicator(total: 3, current: 3)
    }
    .padding()
    .background(AppColor.lightBlueBackground)
}
