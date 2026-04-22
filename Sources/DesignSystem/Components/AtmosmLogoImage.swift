import SwiftUI

// Renders the Atmosm globe + A logo.
// If an "AtmosmLogo" image set is present in Assets.xcassets, it's used.
// Otherwise we fall back to a styled SF Symbol so the app still builds.
struct AtmosmLogoImage: View {
    var body: some View {
        if UIImage(named: "AtmosmLogo") != nil {
            Image("AtmosmLogo")
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "leaf.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(AppColor.primaryNavy)
        }
    }
}
