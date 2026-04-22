import SwiftUI

struct FlightsView: View {
    @Bindable var state: OnboardingState
    let onBack: () -> Void
    let onNext: () -> Void
    var startExpanded: Bool = false

    @State private var showRefine: Bool

    init(
        state: OnboardingState,
        onBack: @escaping () -> Void,
        onNext: @escaping () -> Void,
        startExpanded: Bool = false
    ) {
        self.state = state
        self.onBack = onBack
        self.onNext = onNext
        self.startExpanded = startExpanded
        self._showRefine = State(initialValue: startExpanded)
    }

    var body: some View {
        TrackerScreenLayout(title: "Flights", category: .flights, onBack: onBack) {
            VStack(alignment: .leading, spacing: 20) {
                Text("How many round-trip flights do you take in a year on an average")
                    .font(.atmosmBody.bold())
                    .foregroundStyle(AppColor.textPrimary)

                RangeSlider(
                    value: $state.flightsPerYear,
                    range: 0...30,
                    leftLabel: "",
                    rightLabel: "",
                    valueFormatter: { "\(Int($0))" }
                )

                Text("What is preferred choice of flying?")
                    .font(.atmosmBody.bold())
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.top, 8)

                HStack(spacing: 12) {
                    PillButton(title: "Economy",  isSelected: state.flightClass == "Economy")  { state.flightClass = "Economy" }
                    PillButton(title: "Business", isSelected: state.flightClass == "Business") { state.flightClass = "Business" }
                }

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
                    imageAsset: "InfoCardFlights",
                    bodyText: "A passenger in premium class emitted ~3 times more CO2 per kilometer than a passenger in economy class, depending on aircraft class"
                )
                .padding(.top, 16)
            }
        }
    }

    // MARK: - Refine

    // Figma node 101:548 — Flights detailed breakdown:
    //   rows = Economy / Business / First,
    //   cols = Personal / Work, each cell is a count.
    // Plus a duration matrix with the same 2 columns for 4 buckets.
    @ViewBuilder
    private var refineSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How many flights do you take in a year?")
                .font(.atmosmBody.bold())
                .foregroundStyle(AppColor.textPrimary)
                .padding(.top, 8)

            matrixHeader

            countRow(label: "Economy",
                     personal: $state.flightsEconomyPersonal,
                     work:     $state.flightsEconomyWork)
            countRow(label: "Business",
                     personal: $state.flightsBusinessPersonal,
                     work:     $state.flightsBusinessWork)
            countRow(label: "First",
                     personal: $state.flightsFirstPersonal,
                     work:     $state.flightsFirstWork)

            HStack {
                Text("Total")
                    .font(.atmosmBody.bold())
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                totalChip(total: totalPersonal).frame(width: 110)
                Spacer().frame(width: 18)
                totalChip(total: totalWork).frame(width: 110)
            }

            Text("Generally how long are your flights?")
                .font(.atmosmBody.bold())
                .foregroundStyle(AppColor.textPrimary)
                .padding(.top, 8)

            matrixHeader

            countRow(label: "Local (0 - 2 Hours)",
                     personal: $state.flightsLocalPersonal,
                     work:     $state.flightsLocalWork)
            countRow(label: "Regional (2 - 6 Hours)",
                     personal: $state.flightsRegionalPersonal,
                     work:     $state.flightsRegionalWork)
            countRow(label: "Global (6 - 10 Hours)",
                     personal: $state.flightsGlobalPersonal,
                     work:     $state.flightsGlobalWork)
            countRow(label: "Wow > 10 Hours",
                     personal: $state.flightsExtendedPersonal,
                     work:     $state.flightsExtendedWork)
        }
    }

    private var matrixHeader: some View {
        HStack {
            Spacer()
            Text("Personal").font(.atmosmCaption.bold()).foregroundStyle(AppColor.textPrimary)
                .frame(width: 110)
            Spacer().frame(width: 18)
            Text("Work").font(.atmosmCaption.bold()).foregroundStyle(AppColor.textPrimary)
                .frame(width: 110)
        }
    }

    @ViewBuilder
    private func countRow(label: String, personal: Binding<Int>, work: Binding<Int>) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Text(label)
                .font(.atmosmBody)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            stepperField(value: personal).frame(width: 110)
            Spacer().frame(width: 18)
            stepperField(value: work).frame(width: 110)
        }
    }

    // Simple pill-shaped stepper: [ − ] 0 [ + ]
    @ViewBuilder
    private func stepperField(value: Binding<Int>) -> some View {
        HStack(spacing: 0) {
            Button {
                if value.wrappedValue > 0 { value.wrappedValue -= 1 }
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.primaryNavy)
                    .frame(width: 32, height: 40)
            }
            .buttonStyle(.plain)

            Text("\(value.wrappedValue)")
                .font(.atmosmBody.bold())
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity)

            Button {
                value.wrappedValue += 1
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.primaryNavy)
                    .frame(width: 32, height: 40)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 40)
        .background(Capsule().fill(AppColor.fieldBackground))
        .overlay(Capsule().stroke(AppColor.primaryNavy.opacity(0.25), lineWidth: 1))
    }

    private func totalChip(total: Int) -> some View {
        Text("\(total)")
            .font(.atmosmBody.bold())
            .foregroundStyle(.white)
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(Capsule().fill(AppColor.primaryNavy))
    }

    private var totalPersonal: Int {
        state.flightsEconomyPersonal
        + state.flightsBusinessPersonal
        + state.flightsFirstPersonal
    }
    private var totalWork: Int {
        state.flightsEconomyWork
        + state.flightsBusinessWork
        + state.flightsFirstWork
    }
}

#Preview {
    NavigationStack {
        FlightsView(state: OnboardingState(), onBack: {}, onNext: {})
    }
}
