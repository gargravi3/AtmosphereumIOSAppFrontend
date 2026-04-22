import SwiftUI

// Reusable chevron / menu / close button with a guaranteed 44x44 hit area
// (Apple's HIG minimum) and a built-in accessibility label.
// Use everywhere a lone SF Symbol acts as a tap target.
struct IconButton: View {
    let systemName: String
    var accessibilityLabel: String
    var size: CGFloat = 20
    var color: Color = AppColor.textPrimary
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptics.tap()
            action()
        }) {
            Image(systemName: systemName)
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.atmosm(haptic: false))
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    HStack {
        IconButton(systemName: "chevron.left", accessibilityLabel: "Back") {}
        IconButton(systemName: "line.3.horizontal", accessibilityLabel: "Menu") {}
        IconButton(systemName: "xmark", accessibilityLabel: "Close") {}
    }
}
