import SwiftUI

// Bottom info card: hero image, body text, "Read more..." italic link.
struct InfoCard: View {
    let imageAsset: String
    let bodyText: String
    var onReadMore: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if UIImage(named: imageAsset) != nil {
                Image(imageAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColor.fieldBackground)
                    .frame(height: 120)
            }

            Text(bodyText)
                .font(.atmosmBody)
                .foregroundStyle(AppColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onReadMore) {
                Text("Read more...")
                    .font(.atmosmBody.italic().bold())
                    .foregroundStyle(AppColor.primaryNavy)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    InfoCard(
        imageAsset: "InfoCardDriving",
        bodyText: "Switching from an SUV to an electric car can result in a CO\u{2082} emissions reduction in 50 - 100%, depending on the electric source."
    )
    .padding()
    .background(AppColor.lightBlueBackground)
}
