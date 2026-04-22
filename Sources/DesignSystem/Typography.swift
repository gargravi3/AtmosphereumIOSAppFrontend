import SwiftUI

// Atmosm uses IBM Plex Sans in the Figma file. We fall back to the system
// font if the app bundle does not ship the custom font.
enum AppFont {
    static let family = "IBMPlexSans"

    static func regular(_ size: CGFloat) -> Font {
        Font.custom("\(family)-Regular", size: size, relativeTo: .body)
    }

    static func bold(_ size: CGFloat) -> Font {
        Font.custom("\(family)-Bold", size: size, relativeTo: .body)
    }
}

extension Font {
    static let atmosmTitle    = AppFont.bold(24)
    static let atmosmHeadline = AppFont.bold(20)
    static let atmosmBody     = AppFont.regular(16)
    static let atmosmLabel    = AppFont.bold(14)
    static let atmosmCaption  = AppFont.regular(12)
    // Standard iOS button text: 17pt semibold/bold. The 24pt Figma value
    // only applied to hero Welcome screen buttons; regular CTAs use this.
    static let atmosmButton   = AppFont.bold(17)
    // Kept for the big Welcome / Signup hero CTAs.
    static let atmosmButtonHero = AppFont.bold(22)
}
