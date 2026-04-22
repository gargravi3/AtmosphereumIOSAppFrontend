import SwiftUI

// Renders a bundled asset if it exists, otherwise falls back to the named SF Symbol.
// If `tint` is provided, the image is rendered as a template with that color
// (useful to keep monochrome icons visible on dark backgrounds).
struct AssetOrSymbolImage: View {
    let assetName: String?
    let systemName: String
    var tint: Color? = nil

    var body: some View {
        if let name = assetName, UIImage(named: name) != nil {
            if let tint {
                Image(name)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(tint)
            } else {
                Image(name)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
            }
        } else {
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(tint ?? AppColor.textPrimary)
        }
    }
}
