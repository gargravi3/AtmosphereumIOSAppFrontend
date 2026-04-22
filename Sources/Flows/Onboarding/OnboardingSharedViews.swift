import SwiftUI

// Shared header used across Select Interests / Region / Industry screens.
struct OnboardingHeader: View {
    let title: String
    let subtitle: String
    var subtitleColor: Color = AppColor.textPrimary
    let currentStep: Int

    var body: some View {
        VStack(spacing: 12) {
            StepIndicator(total: 3, current: currentStep)

            VStack(spacing: 4) {
                Text(title)
                    .font(.atmosmTitle)
                    .foregroundStyle(AppColor.primaryNavy)
                Text(subtitle)
                    .font(.atmosmBody)
                    .foregroundStyle(subtitleColor)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// Bottom CTA block shared across post-signup screens.
struct BottomCTA: View {
    let nextEnabled: Bool
    let onNext: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            PrimaryButton(title: "Next", style: .navy, isEnabled: nextEnabled, action: onNext)
            Button(action: onSkip) {
                Text("Do this later >>")
                    .font(.atmosmBody)
                    .foregroundStyle(AppColor.textPrimary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

// Back chevron shared across all post-signup screens.
struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppColor.primaryNavy)
        }
    }
}
