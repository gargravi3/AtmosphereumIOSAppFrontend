import UIKit

// Central haptic vocabulary — 4 flavors cover every app event we care about.
// Keep call sites terse: Haptics.tap(), Haptics.success(), etc.
// All generators are created per-call because holding one alive is
// counter-productive; iOS warms its own pool after first use.
enum Haptics {
    /// Light selection tick — tab switches, chip taps, toggles.
    static func tap() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    /// Soft impact — primary button press, goal added, card reveal.
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    /// Success cue — goal completed, coins earned, form submitted.
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Error cue — network failure, validation rejection.
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
