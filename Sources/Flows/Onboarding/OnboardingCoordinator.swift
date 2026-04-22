import SwiftUI

struct OnboardingCoordinator: View {
    var onFinished: () -> Void = {}
    var onBack: () -> Void = {}
    @State private var path = NavigationPath()
    @State private var state = OnboardingState()

    var body: some View {
        NavigationStack(path: $path) {
            SignupView(
                state: state,
                onContinue: { path.append(OnboardingStep.interests) },
                onTerms:    { path.append(OnboardingStep.terms) },
                onBack:     onBack
            )
            .navigationDestination(for: OnboardingStep.self) { step in
                switch step {
                case .terms:
                    TermsView(onBack: { path.removeLast() })

                case .interests:
                    SelectInterestsView(
                        state: state,
                        onNext: { state.syncProfile(); path.append(OnboardingStep.region) },
                        onSkip: { path.append(OnboardingStep.tellUsMore) }
                    )

                case .region:
                    SelectRegionView(
                        state: state,
                        onNext: { state.syncProfile(); path.append(OnboardingStep.industry) },
                        onSkip: { path.append(OnboardingStep.tellUsMore) }
                    )

                case .industry:
                    SelectIndustryView(
                        state: state,
                        onNext: { state.syncProfile(); path.append(OnboardingStep.tellUsMore) },
                        onSkip: { path.append(OnboardingStep.tellUsMore) }
                    )

                case .tellUsMore:
                    TellUsMoreView(
                        state: state,
                        onNext: { state.syncProfile(); path.append(OnboardingStep.trackerIntro) },
                        onSkip: { path.append(OnboardingStep.trackerIntro) }
                    )

                case .trackerIntro:
                    TrackerIntroView(
                        onBack: { path.removeLast() },
                        onNext: { path.append(OnboardingStep.driving) },
                        onSkip: {
                            // "Do this later" — finish the onboarding without
                            // collecting the tracker answers. We still wait
                            // for any pending profile sync so the app lands
                            // with whatever data we already have.
                            Task {
                                _ = await state.syncProfileAwait()
                                await MainActor.run { onFinished() }
                            }
                        }
                    )

                case .driving:
                    DrivingView(
                        state: state,
                        onBack:   { path.removeLast() },
                        onNext:   {
                            state.didVisitDriving = true
                            state.syncProfile()
                            path.append(OnboardingStep.flights)
                        }
                    )

                case .flights:
                    FlightsView(
                        state: state,
                        onBack: { path.removeLast() },
                        onNext: {
                            state.didVisitFlights = true
                            state.syncProfile()
                            path.append(OnboardingStep.food)
                        }
                    )

                case .food:
                    FoodView(
                        state: state,
                        onBack:   { path.removeLast() },
                        onNext:   {
                            state.didVisitFood = true
                            state.syncProfile()
                            path.append(OnboardingStep.utilities)
                        }
                    )

                case .utilities:
                    UtilitiesView(
                        state: state,
                        onBack: { path.removeLast() },
                        onNext: {
                            state.didVisitUtilities = true
                            state.syncProfile()
                            path.append(OnboardingStep.waste)
                        }
                    )

                case .waste:
                    WasteView(
                        state: state,
                        onBack: { path.removeLast() },
                        onNext: {
                            state.didVisitWaste = true
                            // Wait for the final profile PUT to complete so
                            // the Home screen loads with the computed tons
                            // already persisted server-side.
                            Task {
                                _ = await state.syncProfileAwait()
                                await MainActor.run { onFinished() }
                            }
                        }
                    )

                case .done:
                    OnboardingDoneView()
                }
            }
        }
    }
}

struct OnboardingDoneView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .resizable().scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(AppColor.primaryNavy)
            Text("You're all set!")
                .font(.atmosmTitle)
            Text("Welcome to Atmosm.")
                .font(.atmosmBody)
                .foregroundStyle(AppColor.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.lightBlueBackground)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    OnboardingCoordinator()
}
