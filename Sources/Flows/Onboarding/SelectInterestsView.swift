import SwiftUI

struct SelectInterestsView: View {
    @Bindable var state: OnboardingState
    let onNext: () -> Void
    let onSkip: () -> Void

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                OnboardingHeader(
                    title: "Select Interests",
                    subtitle: "Choose 4 or more topics you care about!",
                    currentStep: 1
                )
                .padding(.horizontal, 24)
                .padding(.top, 16)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Interest.all) { interest in
                            SelectableCard(
                                title: interest.title,
                                isSelected: state.selectedInterests.contains(interest.id)
                            ) {
                                AssetOrSymbolImage(
                                    assetName: interest.assetImage,
                                    systemName: interest.systemIcon,
                                    tint: state.selectedInterests.contains(interest.id) ? .white : AppColor.textPrimary
                                )
                            } action: {
                                toggle(interest)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                    Text("More...")
                        .font(.atmosmBody)
                        .foregroundStyle(AppColor.textSecondary)
                        .padding(.bottom, 8)
                }

                BottomCTA(
                    nextEnabled: state.hasEnoughInterests,
                    onNext: onNext,
                    onSkip: onSkip
                )
            }
        }
        .navigationBarBackButtonHidden()
    }

    private func toggle(_ interest: Interest) {
        if state.selectedInterests.contains(interest.id) {
            state.selectedInterests.remove(interest.id)
        } else {
            state.selectedInterests.insert(interest.id)
        }
    }
}

#Preview {
    NavigationStack {
        SelectInterestsView(state: OnboardingState(), onNext: {}, onSkip: {})
    }
}
