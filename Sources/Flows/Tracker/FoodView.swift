import SwiftUI

struct FoodView: View {
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

    private let labels = ["Never", "Sometimes", "Mostly", "Always"]

    var body: some View {
        TrackerScreenLayout(title: "Food", category: .food, onBack: onBack) {
            VStack(alignment: .leading, spacing: 20) {
                Text("What do you eat?")
                    .font(.atmosmBody.bold())
                    .foregroundStyle(AppColor.textPrimary)

                foodGroup(title: "Vegan",        value: $state.foodVegan)
                foodGroup(title: "Dairy",        value: $state.foodDairy)
                foodGroup(title: "Fish & Sea Food", value: $state.foodFish)
                foodGroup(title: "Poultry",      value: $state.foodPoultry)
                foodGroup(title: "Red Meat",     value: $state.foodRedMeat)

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
                    imageAsset: "InfoCardFood",
                    bodyText: "Adopting a plant based diet or reducing meat and dairy consumption can save ~ 1.5 - 2.5 tons of CO2 emissions per year"
                )
                .padding(.top, 16)
            }
        }
    }

    // MARK: - Refine

    // Figma node 101:692 — Food additional questions.
    @ViewBuilder
    private var refineSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Do you actively seek locally produced food?")
                .font(.atmosmBody.bold())
                .foregroundStyle(AppColor.textPrimary)
                .padding(.top, 8)

            LabeledSlider(value: $state.foodLocal, labels: labels)

            Text("How much of your food goes waste?")
                .font(.atmosmBody.bold())
                .foregroundStyle(AppColor.textPrimary)
                .padding(.top, 8)

            RangeSlider(
                value: $state.foodWastePercent,
                range: 0...80,
                leftLabel: "0%",
                rightLabel: "80%",
                valueFormatter: { "\(Int($0))%" }
            )
        }
    }

    @ViewBuilder
    private func foodGroup(title: String, value: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.atmosmBody)
                .foregroundStyle(AppColor.textPrimary)
            LabeledSlider(value: value, labels: labels)
        }
    }
}

#Preview {
    NavigationStack {
        FoodView(state: OnboardingState(), onBack: {}, onNext: {})
    }
}
