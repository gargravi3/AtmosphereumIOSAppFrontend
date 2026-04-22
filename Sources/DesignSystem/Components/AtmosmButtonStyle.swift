import SwiftUI

// App-wide press feedback: subtle scale + opacity + haptic tick.
// Apply to any Button that would otherwise use `.buttonStyle(.plain)`;
// it preserves custom chrome (Capsule, cards, icons) while restoring the
// tactile feel SwiftUI's plain style strips away.
struct AtmosmButtonStyle: ButtonStyle {
    var haptic: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.75),
                       value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if haptic && isPressed { Haptics.tap() }
            }
    }
}

extension ButtonStyle where Self == AtmosmButtonStyle {
    static var atmosm: AtmosmButtonStyle { AtmosmButtonStyle() }
    static func atmosm(haptic: Bool) -> AtmosmButtonStyle { AtmosmButtonStyle(haptic: haptic) }
}
