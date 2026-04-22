import SwiftUI

struct SelectRegionView: View {
    @Bindable var state: OnboardingState
    let onNext: () -> Void
    let onSkip: () -> Void

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                OnboardingHeader(
                    title: "Select Region",
                    subtitle: "Tell us where are you from",
                    subtitleColor: AppColor.accentRed,
                    currentStep: 2
                )
                .padding(.horizontal, 24)
                .padding(.top, 16)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Region.all) { region in
                            SelectableCard(
                                title: region.title,
                                isSelected: state.selectedRegion == region.id
                            ) {
                                AssetOrSymbolImage(
                                    assetName: region.assetImage,
                                    systemName: region.systemIcon,
                                    tint: state.selectedRegion == region.id ? .white : AppColor.textPrimary
                                )
                            } action: {
                                state.selectedRegion = region.id
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }

                BottomCTA(
                    nextEnabled: state.selectedRegion != nil,
                    onNext: onNext,
                    onSkip: onSkip
                )
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { BackButton() }
        }
    }
}

#Preview {
    NavigationStack {
        SelectRegionView(state: OnboardingState(), onNext: {}, onSkip: {})
    }
}
