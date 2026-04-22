import SwiftUI

struct DropdownField: View {
    let label: String
    let placeholder: String
    let options: [String]
    @Binding var selection: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.atmosmLabel)
                .foregroundStyle(AppColor.textPrimary)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection = option }
                }
            } label: {
                HStack {
                    Text(selection ?? placeholder)
                        .font(.atmosmBody)
                        .foregroundStyle(selection == nil ? AppColor.textSecondary : AppColor.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundStyle(AppColor.textPrimary)
                }
                .padding(.horizontal, 12)
                .frame(height: 52)
                .background(AppColor.fieldBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(AppColor.fieldBorder, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
    }
}

#Preview {
    @Previewable @State var value: String? = nil
    return DropdownField(
        label: "Country",
        placeholder: "Select Country",
        options: ["United States", "India", "United Kingdom"],
        selection: $value
    )
    .padding()
    .background(AppColor.lightBlueBackground)
}
