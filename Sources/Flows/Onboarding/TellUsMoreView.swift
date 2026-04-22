import SwiftUI

struct TellUsMoreView: View {
    @Bindable var state: OnboardingState
    let onNext: () -> Void
    let onSkip: () -> Void

    private let countries = ["United States", "India", "United Kingdom", "Germany", "Japan"]
    private let cities = ["New York", "San Francisco", "Mumbai", "London", "Berlin", "Tokyo"]
    private let functions = ["Engineer", "Designer", "Product Manager", "Researcher", "Marketing", "Sales"]

    private enum Field: Hashable { case firstName, lastName, handle }
    @FocusState private var focus: Field?

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("Tell Us More")
                        .font(.atmosmTitle)
                        .foregroundStyle(AppColor.primaryNavy)
                    Text("We'd like to get to know you better")
                        .font(.atmosmBody)
                        .foregroundStyle(AppColor.textPrimary)
                }
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        AtmosmTextField(
                            label: "First Name",
                            capitalization: .words,
                            submitLabel: .next,
                            textContentType: .givenName,
                            focus: $focus, focusValue: Field.firstName,
                            text: $state.firstName,
                            onSubmit: { focus = .lastName }
                        )
                        AtmosmTextField(
                            label: "Last Name",
                            capitalization: .words,
                            submitLabel: .next,
                            textContentType: .familyName,
                            focus: $focus, focusValue: Field.lastName,
                            text: $state.lastName,
                            onSubmit: { focus = .handle }
                        )
                        AtmosmTextField(
                            label: "Choose an Atmosm handle",
                            labelColor: AppColor.accentRed,
                            capitalization: .never,
                            submitLabel: .done,
                            textContentType: .username,
                            focus: $focus, focusValue: Field.handle,
                            text: $state.atmosmHandle,
                            onSubmit: { focus = nil }
                        )

                        DropdownField(
                            label: "Country",
                            placeholder: "Select Country",
                            options: countries,
                            selection: $state.country
                        )
                        DropdownField(
                            label: "City",
                            placeholder: "Select City",
                            options: cities,
                            selection: $state.city
                        )
                        DropdownField(
                            label: "Function",
                            placeholder: "Select Function",
                            options: functions,
                            selection: $state.function
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }

                BottomCTA(
                    nextEnabled: !state.atmosmHandle.isEmpty
                        && state.country != nil
                        && state.city != nil,
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
        TellUsMoreView(state: OnboardingState(), onNext: {}, onSkip: {})
    }
}
