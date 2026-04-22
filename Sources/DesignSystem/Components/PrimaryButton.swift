import SwiftUI

struct PrimaryButton: View {
    enum Style {
        case green
        case navy

        var background: Color {
            switch self {
            case .green: return AppColor.primaryGreen
            case .navy:  return AppColor.primaryNavy
            }
        }
    }

    let title: String
    var style: Style = .navy
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.atmosmButton)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    Capsule().fill(style.background.opacity(isEnabled ? 1 : 0.5))
                )
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Next", style: .navy) {}
        PrimaryButton(title: "Next", style: .green) {}
        PrimaryButton(title: "Next", style: .navy, isEnabled: false) {}
    }
    .padding()
}
