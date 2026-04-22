import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search"

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .font(.atmosmBody)
                .foregroundStyle(AppColor.textPrimary)
                .tint(AppColor.primaryNavy)
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColor.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Capsule().fill(AppColor.fieldBackground))
        .overlay(Capsule().stroke(AppColor.fieldBorder, lineWidth: 1))
    }
}

#Preview {
    SearchBar(text: .constant(""))
        .padding()
        .background(AppColor.lightBlueBackground)
}
