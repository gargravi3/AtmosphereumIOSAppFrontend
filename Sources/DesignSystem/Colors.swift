import SwiftUI

extension Color {
    init(hex: String) {
        let trimmed = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var int: UInt64 = 0
        Scanner(string: trimmed).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch trimmed.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

enum AppColor {
    // Signup / cream theme (from Figma Login Screen 1)
    static let creamBackground = Color(hex: "#FFF9E7")
    static let screenBackground = Color(hex: "#FAFAFA")
    static let primaryGreen = Color(hex: "#218A5F")

    // Post-signup / blue theme (from Select Region / Tell Us More)
    static let lightBlueBackground = Color(hex: "#E6EEF8")
    static let primaryNavy = Color(hex: "#1E3A8A")
    static let lightBluePill = Color(hex: "#CFE0F5")

    // Splash
    static let splashBackground = Color(hex: "#0A1747")

    // Chart / category palette
    static let chartRed    = Color(hex: "#F46B5E")
    static let chartGreen  = Color(hex: "#3FC68F")
    static let chartPurple = Color(hex: "#6B43C7")
    static let chartOrange = Color(hex: "#F2A75C")

    // Shared
    static let fieldBackground = Color.white
    static let fieldBorder = Color(hex: "#E2E3E4")
    static let strengthBarInactive = Color.white
    static let textPrimary = Color.black
    static let textSecondary = Color(hex: "#555555")
    static let accentRed = Color(hex: "#D32F2F")
    static let stepInactive = Color(hex: "#E5E7EB")
}
