import SwiftUI

struct SelectIndustryView: View {
    @Bindable var state: OnboardingState
    let onNext: () -> Void
    let onSkip: () -> Void

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                OnboardingHeader(
                    title: "Select Industry",
                    subtitle: "What industry are you active in?",
                    currentStep: 3
                )
                .padding(.horizontal, 24)
                .padding(.top, 16)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Industry.featured) { industry in
                            SelectableCard(
                                title: industry.title,
                                isSelected: state.selectedIndustry == industry.id
                            ) {
                                AssetOrSymbolImage(
                                    assetName: industry.assetImage,
                                    systemName: industry.systemIcon,
                                    tint: state.selectedIndustry == industry.id ? .white : AppColor.textPrimary
                                )
                            } action: {
                                state.selectedIndustry = industry.id
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    DropdownField(
                        label: "Others",
                        placeholder: "Select",
                        options: Industry.others,
                        selection: $state.otherIndustry
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }

                BottomCTA(
                    nextEnabled: state.selectedIndustry != nil || state.otherIndustry != nil,
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
        SelectIndustryView(state: OnboardingState(), onNext: {}, onSkip: {})
    }
}
