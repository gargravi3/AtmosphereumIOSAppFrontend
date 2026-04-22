import SwiftUI

private struct RefineTile: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let tons: Double
    let icon: String
}

struct RefineView: View {
    let onBack: () -> Void
    let onRestart: () -> Void

    @State private var selected: UUID?

    private let tiles: [RefineTile] = [
        .init(title: "Driving",   tons: 0.7,  icon: "car.fill"),
        .init(title: "Flights",   tons: 1.34, icon: "airplane"),
        .init(title: "Food",      tons: 1.35, icon: "fork.knife"),
        .init(title: "Utilities", tons: 0.15, icon: "bolt.fill"),
        .init(title: "Lifestyle", tons: 0.27, icon: "bag.fill"),
        .init(title: "Waste",     tons: 0.27, icon: "trash.fill")
    ]

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(AppColor.textPrimary)
                        }
                        Spacer()
                    }
                    Text("Refine")
                        .font(.atmosmTitle)
                        .foregroundStyle(AppColor.primaryNavy)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(tiles) { tile in
                        let isSelected = tile.id == selected || (selected == nil && tile.title == "Driving")
                        Button {
                            selected = tile.id
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: tile.icon)
                                    .font(.system(size: 42, weight: .regular))
                                    .foregroundStyle(isSelected ? .white : AppColor.textPrimary)
                                Text("\(tile.title)\n(\(String(format: "%.2g", tile.tons)) Tons)")
                                    .font(.atmosmBody)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(isSelected ? .white : AppColor.textPrimary)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, minHeight: 140)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isSelected ? AppColor.primaryNavy : AppColor.fieldBackground)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isSelected ? Color.clear : AppColor.fieldBorder, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

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
    }
}

#Preview {
    RefineView(onBack: {}, onRestart: {})
}
