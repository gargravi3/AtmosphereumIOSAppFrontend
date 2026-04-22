import SwiftUI

// Large stat card used on Home + Reduce detail.
// Matches the two blue/grey cards from Figma node 153:337.
struct CoinCardView: View {
    enum Style {
        case navyCoin   // dark blue bg + gold coin — "You have 100 Atmosm Coins"
        case slateCloud // grey-blue bg + CO2 cloud — "reducing 100 kg of CO2"
    }

    let style: Style
    let value: Int
    let title: String      // "Atmosm Coins" | "kg of CO₂"
    let prefix: String?    // "reducing" | nil

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(style == .navyCoin ? AppColor.primaryNavy : AppColor.textPrimary.opacity(0.6))

            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    if let prefix {
                        Text(prefix)
                            .font(.atmosmBody)
                            .foregroundStyle(.white)
                    }
                    Text("\(value)")
                        .font(.system(size: 54, weight: .heavy))
                        .foregroundStyle(.white)
                    Text(title)
                        .font(.atmosmBody.bold())
                        .foregroundStyle(.white)
                }
                Spacer(minLength: 0)
                artwork
                    .frame(width: 90, height: 90)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(height: 138)
    }

    @ViewBuilder
    private var artwork: some View {
        switch style {
        case .navyCoin:
            if UIImage(named: "AtmosmCoin") != nil {
                Image("AtmosmCoin").resizable().scaledToFit()
            } else {
                Image(systemName: "dollarsign.circle.fill")
                    .resizable().scaledToFit()
                    .foregroundStyle(.yellow)
            }
        case .slateCloud:
            if UIImage(named: "CO2Cloud") != nil {
                Image("CO2Cloud").resizable().scaledToFit()
                    .colorInvert()
            } else {
                Image(systemName: "cloud.fill")
                    .resizable().scaledToFit()
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        CoinCardView(style: .navyCoin, value: 100, title: "Atmosm Coins", prefix: nil)
        CoinCardView(style: .slateCloud, value: 100, title: "kg of CO₂", prefix: "reducing")
    }
    .padding(24)
    .background(AppColor.lightBlueBackground)
}
