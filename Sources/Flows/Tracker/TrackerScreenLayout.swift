import SwiftUI

// Common chrome for the 5 tracker screens (Driving / Flights / Food / Utilities / Waste).
struct TrackerScreenLayout<Body: View>: View {
    let title: String
    let category: TrackerCategory
    let content: () -> Body
    let onBack: () -> Void

    init(
        title: String,
        category: TrackerCategory,
        onBack: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Body
    ) {
        self.title = title
        self.category = category
        self.onBack = onBack
        self.content = content
    }

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                CategoryTracker(current: category)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                HStack {
                    IconButton(systemName: "chevron.left", accessibilityLabel: "Back", action: onBack)
                    Spacer()
                    Text(title)
                        .font(.atmosmTitle)
                        .foregroundStyle(AppColor.textPrimary)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    content()
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
