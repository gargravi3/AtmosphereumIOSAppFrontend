import SwiftUI

// Row with a label on the left and Yes/No radio options on the right.
// Value is Bool? (nil = nothing selected yet).
struct YesNoRow: View {
    let label: String
    @Binding var value: Bool?

    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.atmosmBody)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Radio(
                title: "Yes",
                isOn: value == true,
                action: { value = true }
            )
            .frame(width: 80)

            Radio(
                title: "No",
                isOn: value == false,
                action: { value = false }
            )
            .frame(width: 70)
        }
        .padding(.vertical, 4)
    }
}

private struct Radio: View {
    let title: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(AppColor.primaryNavy, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                    if isOn {
                        Circle()
                            .fill(AppColor.primaryNavy)
                            .frame(width: 14, height: 14)
                    }
                }
                Text(title)
                    .font(.atmosmBody)
                    .foregroundStyle(AppColor.textPrimary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        YesNoRow(label: "Paper / Cardboard", value: .constant(true))
        YesNoRow(label: "Plastic", value: .constant(nil))
        YesNoRow(label: "Glass", value: .constant(false))
    }
    .padding()
    .background(AppColor.lightBlueBackground)
}
