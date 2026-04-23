import SwiftUI

// Brentford FC promo card surfaced on Home. Dismissable via the X —
// once dismissed, the Fan Page is still reachable from the hamburger
// menu. Sits between the two coin cards and the NetZero reminder.
struct MatchDayPromoCard: View {
    let onOpen: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(spacing: 12) {
                // Brentford red accent stripe + Griffin (SF shield fallback)
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.small)
                        .fill(AppColor.brentfordRed)
                        .frame(width: 44, height: 44)
                    Image(systemName: "shield.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Brentford Fan?")
                        .font(.atmosmBody.bold())
                        .foregroundStyle(AppColor.primaryNavy)
                    Text("Track your match day footprint — earn coins for sustainable choices.")
                        .font(.atmosmCaption)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.primaryNavy)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            )
            .overlay(alignment: .topTrailing) {
                // The dismiss button is on top of the card button so we
                // stop-propagation by using a separate Button with its
                // own tap target. contentShape ensures the 32x32 region
                // is clickable but leaves the rest of the card to the
                // outer button.
                Button {
                    Haptics.tap()
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColor.textSecondary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Dismiss Brentford promo")
                .buttonStyle(.plain)
            }
        }
        .buttonStyle(.atmosm)
    }
}

#Preview {
    MatchDayPromoCard(onOpen: {}, onDismiss: {})
        .padding()
        .background(AppColor.lightBlueBackground)
}
