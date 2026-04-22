import SwiftUI

struct UtilitiesView: View {
    @Bindable var state: OnboardingState
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        TrackerScreenLayout(title: "Utilities", category: .utilities, onBack: onBack) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Your approx monthly bill for")
                    .font(.atmosmBody.bold())
                    .foregroundStyle(AppColor.textPrimary)

                CurrencyField(label: "Electricity", text: $state.electricityBill)
                CurrencyField(label: "Heating",     text: $state.heatingBill)
                CurrencyField(label: "Cooling",     text: $state.coolingBill)
                CurrencyField(label: "Water",       text: $state.waterBill)

                NumericRow(
                    label: "Number of days you work from home",
                    text: $state.wfhDays,
                    placeholder: "0"
                )

                Text("Number of people in your household?")
                    .font(.atmosmBody.bold())
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.top, 4)

                RangeSlider(
                    value: $state.householdSize,
                    range: 1...12,
                    leftLabel: "1",
                    rightLabel: "12",
                    valueFormatter: { "\(Int($0))" }
                )

                PrimaryButton(title: "Next", style: .navy) {
                    onNext()
                }
                .padding(.top, 8)

                InfoCard(
                    imageAsset: "InfoCardUtilities",
                    bodyText: "Top 1% emitters globally each had carbon footprints of. Over 50 tonnes, more than 1000 times than those of the bottom 1%"
                )
                .padding(.top, 16)
            }
        }
    }
}

#Preview {
    NavigationStack {
        UtilitiesView(state: OnboardingState(), onBack: {}, onNext: {})
    }
}
