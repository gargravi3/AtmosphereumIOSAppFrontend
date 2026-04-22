import SwiftUI

// Square card used on Interests / Region / Industry screens.
// - Inactive: white bg with subtle border, black text/icon
// - Active:   navy fill, white text/icon
struct SelectableCard<Icon: View>: View {
    let title: String
    let isSelected: Bool
    let icon: () -> Icon
    let action: () -> Void

    init(
        title: String,
        isSelected: Bool,
        @ViewBuilder icon: @escaping () -> Icon,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                icon()
                    .frame(width: 56, height: 56)
                    .foregroundStyle(isSelected ? .white : AppColor.textPrimary)

                Text(title)
                    .font(.atmosmLabel)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(isSelected ? .white : AppColor.textPrimary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 156)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AppColor.primaryNavy : AppColor.fieldBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColor.fieldBorder, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: 16) {
        SelectableCard(title: "Asia", isSelected: true) {
            Image(systemName: "globe.asia.australia.fill")
                .resizable().scaledToFit()
        } action: {}
        SelectableCard(title: "Middle East", isSelected: false) {
            Image(systemName: "map.fill")
                .resizable().scaledToFit()
        } action: {}
    }
    .padding()
    .background(AppColor.lightBlueBackground)
}
