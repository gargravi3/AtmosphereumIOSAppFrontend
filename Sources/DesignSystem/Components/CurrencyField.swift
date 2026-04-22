import SwiftUI

// Row with a left label + white $-prefixed input on the right.
struct CurrencyField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(label)
                .font(.atmosmBody)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                Text("$")
                    .font(.atmosmBody)
                    .foregroundStyle(AppColor.textPrimary)
                TextField(placeholder, text: $text)
                    .font(.atmosmBody)
                    .foregroundStyle(AppColor.textPrimary)
                    .tint(AppColor.primaryNavy)
                    .keyboardType(.decimalPad)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 4).fill(AppColor.fieldBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4).stroke(AppColor.fieldBorder, lineWidth: 1)
            )
            .frame(width: 140)
        }
    }
}

// Plain numeric row (label + plain input) used for "Number of days you work from home".
struct NumericRow: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(label)
                .font(.atmosmBody)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField(placeholder, text: $text)
                .font(.atmosmBody)
                .foregroundStyle(AppColor.textPrimary)
                .tint(AppColor.primaryNavy)
                .keyboardType(.numberPad)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 4).fill(AppColor.fieldBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4).stroke(AppColor.fieldBorder, lineWidth: 1)
                )
                .frame(width: 140)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        CurrencyField(label: "Electricity", text: .constant(""))
        CurrencyField(label: "Heating", text: .constant("120"))
        NumericRow(label: "Number of days you work from home", text: .constant(""), placeholder: "0")
    }
    .padding()
    .background(AppColor.lightBlueBackground)
}
