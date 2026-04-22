import SwiftUI

struct WasteView: View {
    @Bindable var state: OnboardingState
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        TrackerScreenLayout(title: "Waste", category: .waste, onBack: onBack) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Do you recycle?")
                    .font(.atmosmBody.bold())
                    .foregroundStyle(AppColor.textPrimary)

                YesNoRow(label: "Paper / Cardboard", value: $state.recyclePaper)
                YesNoRow(label: "Plastic",           value: $state.recyclePlastic)
                YesNoRow(label: "Glass",             value: $state.recycleGlass)
                YesNoRow(label: "Metal",             value: $state.recycleMetal)
                YesNoRow(label: "Food",              value: $state.recycleFood)
                YesNoRow(label: "Clothes / Shoes",   value: $state.recycleClothes)
                YesNoRow(label: "Furniture",         value: $state.recycleFurniture)
                YesNoRow(label: "Electronics",       value: $state.recycleElectronics)

                PrimaryButton(title: "Next", style: .navy) {
                    onNext()
                }
                .padding(.top, 12)

                InfoCard(
                    imageAsset: "InfoCardWaste",
                    bodyText: "A study by UPC's INTEXER found that Reusing 1 kg of clothes saves 25 kg of CO2"
                )
                .padding(.top, 16)
            }
        }
    }
}

#Preview {
    NavigationStack {
        WasteView(state: OnboardingState(), onBack: {}, onNext: {})
    }
}
