import SwiftUI

// Two-button row shown at the bottom of tracker screens:
//   [ Refine (outline) ]   [ Next (filled navy) ]
struct RefineNextRow: View {
    var onRefine: () -> Void
    var onNext: () -> Void
    var nextEnabled: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onRefine) {
                Text("Refine")
                    .font(.atmosmButton)
                    .foregroundStyle(AppColor.primaryNavy)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Capsule().fill(AppColor.fieldBackground))
                    .overlay(Capsule().stroke(AppColor.primaryNavy, lineWidth: 1.5))
            }
            .buttonStyle(.plain)

            Button(action: onNext) {
                Text("Next")
                    .font(.atmosmButton)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Capsule().fill(AppColor.primaryNavy.opacity(nextEnabled ? 1 : 0.5)))
            }
            .buttonStyle(.plain)
            .disabled(!nextEnabled)
        }
    }
}

#Preview {
    RefineNextRow(onRefine: {}, onNext: {})
        .padding()
        .background(AppColor.lightBlueBackground)
}
