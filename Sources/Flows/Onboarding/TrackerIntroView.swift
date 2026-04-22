import SwiftUI

// Second "Tell Us More" screen (Figma node 426:771). Previews the tracker
// categories and gives the user the option to skip them entirely via
// "Do this later" — landing straight in the app.
struct TrackerIntroView: View {
    let onBack: () -> Void
    let onNext: () -> Void
    let onSkip: () -> Void

    // Category rows — icon + label, in the exact order shown in Figma.
    private let rows: [Row] = [
        .init(icon: "car.fill",      label: "Driving"),
        .init(icon: "airplane",      label: "Flights"),
        .init(icon: "fork.knife",    label: "Food"),
        .init(icon: "bolt.fill",     label: "Utilities"),
        .init(icon: "bag.fill",      label: "Lifestyle"),
        .init(icon: "trash.fill",    label: "Waste")
    ]

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Back chevron
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppColor.primaryNavy)
                            .padding(8)
                    }
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.leading, 16)

                // Title (centered per Figma)
                Text("Welcome to\nAtmosphereum")
                    .font(.atmosmTitle)
                    .foregroundStyle(AppColor.primaryNavy)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)

                // Intro copy
                Text("Let's calculate your carbon footprint and see how you can make a positive impact. It's quick and easy – just a few minutes and we'll talk about...")
                    .font(.atmosmBody)
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                // Category list + illustration side-by-side
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(rows) { row in
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle().fill(AppColor.primaryNavy).frame(width: 40, height: 40)
                                    Image(systemName: row.icon)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                                Text(row.label)
                                    .font(.atmosmBody)
                                    .foregroundStyle(AppColor.textPrimary)
                            }
                        }
                    }
                    .padding(.leading, 24)

                    Spacer(minLength: 0)

                    // Footprint illustration (exported from Figma node 426:965)
                    if UIImage(named: "CarbonFootprintIllustration") != nil {
                        Image("CarbonFootprintIllustration")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 180, maxHeight: 220)
                            .padding(.trailing, 8)
                    } else {
                        // Fallback in case the asset didn't ship
                        Image(systemName: "leaf.fill")
                            .resizable().scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundStyle(AppColor.primaryGreen)
                    }
                }
                .padding(.top, 24)

                Spacer()

                PrimaryButton(title: "Next", style: .navy, action: onNext)
                    .padding(.horizontal, 24)

                Button(action: onSkip) {
                    Text("Do this later >>")
                        .font(.atmosmCaption)
                        .foregroundStyle(AppColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 16)
            }
        }
        .navigationBarBackButtonHidden()
    }

    private struct Row: Identifiable {
        let id = UUID()
        let icon: String
        let label: String
    }
}

#Preview {
    TrackerIntroView(onBack: {}, onNext: {}, onSkip: {})
}
