import SwiftUI

struct DrivingView: View {
    @Bindable var state: OnboardingState
    let onBack: () -> Void
    let onNext: () -> Void

    @State private var showRefine: Bool = false

    private let transportModes = ["Motorbike", "Car", "Train", "Bus", "Bicycle", "Walk"]
    private let fuelTypes = ["Diesel", "Petrol/Gasoline", "EV", "Hybrid", "CNG/LPG"]

    var body: some View {
        TrackerScreenLayout(title: "Driving", category: .driving, onBack: onBack) {
            VStack(alignment: .leading, spacing: 20) {
                (
                    Text("What is your mode of local transport ")
                        .font(.atmosmBody.bold())
                    + Text("(Work and Personal)")
                        .font(.atmosmCaption)
                )
                .foregroundStyle(AppColor.textPrimary)

                PillFlow(
                    items: transportModes,
                    title: { $0 },
                    isSelected: { state.transportModes.contains($0) },
                    onTap: { mode in
                        if state.transportModes.contains(mode) {
                            state.transportModes.remove(mode)
                        } else {
                            state.transportModes.insert(mode)
                        }
                    }
                )

                Text("How many Kilometers do you travel per month (Avg.)?")
                    .font(.atmosmBody.bold())
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.top, 8)

                RangeSlider(
                    value: $state.kilometersPerMonth,
                    range: 0...10_000,
                    leftLabel: "0 km",
                    rightLabel: "> 10,000 km",
                    valueFormatter: { "\(Int($0)) Kms" }
                )

                // Refine section — appears inline once the user taps "Refine".
                if showRefine {
                    refineSection
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                RefineNextRow(
                    onRefine: {
                        withAnimation(.easeInOut(duration: 0.2)) { showRefine.toggle() }
                    },
                    onNext: onNext
                )
                .padding(.top, 16)

                InfoCard(
                    imageAsset: "InfoCardDriving",
                    bodyText: "Switching from an SUV to an electric car can result in a CO\u{2082} emissions reduction in 50 - 100%, depending on the electric source."
                )
                .padding(.top, 16)
            }
        }
    }

    // MARK: - Refine

    // Figma node 95:267 — Driving detailed fields.
    @ViewBuilder
    private var refineSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Mode of transport")
                .font(.atmosmBody.bold())
                .foregroundStyle(AppColor.textPrimary)
                .padding(.top, 8)

            percentRow(label: "Motorbike",         value: $state.drivingModeMotorbikePct)
            percentRow(label: "Car",               value: $state.drivingModeCarPct)
            percentRow(label: "Train / Metro / Bus", value: $state.drivingModeTransitPct)
            percentRow(label: "Cycling",           value: $state.drivingModeCyclingPct)
            percentRow(label: "Walk",              value: $state.drivingModeWalkPct)

            HStack {
                Text("Total")
                    .font(.atmosmBody.bold())
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                Text(totalPctString)
                    .font(.atmosmBody.bold())
                    .foregroundStyle(totalPctExact ? AppColor.primaryNavy : .red)
            }

            Text("Primary own vehicle type")
                .font(.atmosmBody.bold())
                .foregroundStyle(AppColor.textPrimary)
                .padding(.top, 8)

            PillFlow(
                items: fuelTypes,
                title: { $0 },
                isSelected: { state.drivingFuelType == $0 },
                onTap: { fuel in
                    state.drivingFuelType = (state.drivingFuelType == fuel) ? nil : fuel
                }
            )

            Text("Average Monthly commute to Office (Out of the total above)")
                .font(.atmosmBody.bold())
                .foregroundStyle(AppColor.textPrimary)
                .padding(.top, 8)

            RangeSlider(
                value: $state.officeCommuteKm,
                range: 0...10_000,
                leftLabel: "0 km",
                rightLabel: "> 10,000 km",
                valueFormatter: { "\(Int($0)) Kms" }
            )
        }
    }

    @ViewBuilder
    private func percentRow(label: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.atmosmBody)
                .foregroundStyle(AppColor.textPrimary)
            HStack(spacing: 12) {
                Slider(value: value, in: 0...100, step: 1)
                    .tint(AppColor.primaryNavy)
                    .frame(maxWidth: .infinity)
                Text("\(Int(value.wrappedValue)) %")
                    .font(.atmosmCaption.bold())
                    .foregroundStyle(AppColor.primaryNavy)
                    .frame(width: 56, alignment: .trailing)
            }
        }
    }

    private var totalPct: Int {
        Int((state.drivingModeMotorbikePct
             + state.drivingModeCarPct
             + state.drivingModeTransitPct
             + state.drivingModeCyclingPct
             + state.drivingModeWalkPct).rounded())
    }
    private var totalPctString: String { "\(totalPct) %" }
    private var totalPctExact: Bool { totalPct == 100 }
}

#Preview {
    NavigationStack {
        DrivingView(state: OnboardingState(), onBack: {}, onNext: {})
    }
}
