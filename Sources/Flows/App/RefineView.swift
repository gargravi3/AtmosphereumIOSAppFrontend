import SwiftUI

// Categories the user can refine, matching the five backend buckets.
// Each case maps to its own tracker editor screen.
enum RefineCategory: String, CaseIterable, Hashable {
    case driving, flights, food, utilities, waste

    var title: String {
        switch self {
        case .driving:   return "Driving"
        case .flights:   return "Flights"
        case .food:      return "Food"
        case .utilities: return "Utilities"
        case .waste:     return "Lifestyle & Waste"
        }
    }

    var icon: String {
        switch self {
        case .driving:   return "car.fill"
        case .flights:   return "airplane"
        case .food:      return "fork.knife"
        case .utilities: return "bolt.fill"
        case .waste:     return "leaf.fill"
        }
    }
}

// Lives inside AppShellView's home NavigationStack — does NOT open its own
// nested stack (that caused HomeRoute destinations to be invisible to
// navigation links pushed from children).
struct RefineView: View {
    @Bindable var app: AppState
    @Binding var path: NavigationPath
    let onBack: () -> Void
    let onRestart: () -> Void

    @State private var isHydrated = false

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        IconButton(systemName: "chevron.left", accessibilityLabel: "Back", action: onBack)
                        Spacer()
                    }
                    Text("Refine")
                        .font(.atmosmTitle)
                        .foregroundStyle(AppColor.primaryNavy)
                }
                .padding(.horizontal, 12)
                .padding(.top, 4)

                Text("Tap a category to edit your answers. Your footprint updates after each save.")
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(RefineCategory.allCases, id: \.self) { category in
                        tile(for: category)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                VStack(spacing: 12) {
                    Button(action: onRestart) {
                        Text("Take initial survey again")
                            .font(.atmosmBody.italic())
                            .foregroundStyle(AppColor.primaryNavy)
                            .underline()
                    }
                    .buttonStyle(.plain)

                    Text("Redoing initial questions will clear refinements and points for all categories")
                        .font(.atmosmCaption)
                        .foregroundStyle(AppColor.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            // Hydrate the shared RefineSession once per view appearance —
            // fetches the latest profile from the server so the editor
            // screens open with the user's current answers prefilled.
            guard !isHydrated else { return }
            if let profile = try? await NetworkService.shared.getProfile() {
                RefineSession.shared.state.hydrate(from: profile)
            }
            isHydrated = true
        }
    }

    @ViewBuilder
    private func tile(for category: RefineCategory) -> some View {
        Button {
            path.append(HomeRoute.refineCategory(category))
        } label: {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 42, weight: .regular))
                    .foregroundStyle(AppColor.textPrimary)
                Text(category.title)
                    .font(.atmosmBody.bold())
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                Text(String(format: "%.2f Tons", currentTons(for: category)))
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColor.fieldBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColor.fieldBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func currentTons(for category: RefineCategory) -> Double {
        switch category {
        case .driving:   return app.tonsDriving   ?? 0
        case .flights:   return app.tonsFlights   ?? 0
        case .food:      return app.tonsFood      ?? 0
        case .utilities: return app.tonsUtilities ?? 0
        case .waste:     return app.tonsWaste     ?? 0
        }
    }
}

// Shared OnboardingState used across the category editor pushes so they
// all read/write the same data. Held on a singleton rather than on
// AppState because it's specifically tied to the refine flow and the
// didVisit* flags only make sense within that context.
final class RefineSession {
    static let shared = RefineSession()
    let state = OnboardingState()
    private init() {}
}

// Hosts a single category editor screen pushed from the Refine tiles.
// Owns the "Next → save → pop" flow so RefineView itself stays simple.
struct RefineCategoryEditor: View {
    @Bindable var app: AppState
    @Binding var path: NavigationPath
    let category: RefineCategory

    @State private var isSaving = false
    @State private var saveError: String? = nil

    private var state: OnboardingState { RefineSession.shared.state }

    var body: some View {
        editor
            .overlay(alignment: .top) {
                if isSaving {
                    HStack(spacing: 8) {
                        ProgressView().controlSize(.small)
                        Text("Saving…").font(.atmosmCaption).foregroundStyle(AppColor.textSecondary)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Capsule().fill(Color.white).shadow(radius: 2))
                    .padding(.top, 72)
                } else if let err = saveError {
                    Text(err)
                        .font(.atmosmCaption)
                        .foregroundStyle(.red)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Capsule().fill(Color.white))
                        .padding(.top, 72)
                }
            }
    }

    @ViewBuilder
    private var editor: some View {
        switch category {
        case .driving:
            DrivingView(
                state: state,
                onBack: { pop() },
                onNext: { save(flag: \.didVisitDriving) },
                startExpanded: true
            )
        case .flights:
            FlightsView(
                state: state,
                onBack: { pop() },
                onNext: { save(flag: \.didVisitFlights) },
                startExpanded: true
            )
        case .food:
            FoodView(
                state: state,
                onBack: { pop() },
                onNext: { save(flag: \.didVisitFood) },
                startExpanded: true
            )
        case .utilities:
            UtilitiesView(
                state: state,
                onBack: { pop() },
                onNext: { save(flag: \.didVisitUtilities) }
            )
        case .waste:
            WasteView(
                state: state,
                onBack: { pop() },
                onNext: { save(flag: \.didVisitWaste) }
            )
        }
    }

    private func pop() {
        if !path.isEmpty { path.removeLast() }
    }

    private func save(flag: ReferenceWritableKeyPath<OnboardingState, Bool>) {
        state[keyPath: flag] = true
        saveError = nil
        isSaving  = true
        Task {
            _ = await state.syncProfileAwait()
            await app.reloadFromServer()
            await MainActor.run {
                isSaving = false
                pop()
            }
        }
    }
}

#Preview {
    RefineView(
        app: AppState(),
        path: .constant(NavigationPath()),
        onBack: {},
        onRestart: {}
    )
}
