import SwiftUI

enum AppTab: String, Hashable, CaseIterable {
    case home, leaderboard, reduce

    var title: String {
        switch self {
        case .home:        return "Home"
        case .leaderboard: return "Leaderboard"
        case .reduce:      return "Reduce"
        }
    }

    var systemIcon: String {
        switch self {
        case .home:        return "house.fill"
        case .leaderboard: return "trophy.fill"
        case .reduce:      return "arrow.down.circle"
        }
    }
}

struct AppTabBar: View {
    @Binding var selection: AppTab
    @Namespace private var indicator

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    guard selection != tab else { return }
                    Haptics.tap()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selection = tab
                    }
                } label: {
                    VStack(spacing: 2) {
                        ZStack {
                            if selection == tab {
                                Capsule()
                                    .fill(AppColor.primaryNavy.opacity(0.1))
                                    .frame(width: 54, height: 28)
                                    .matchedGeometryEffect(id: "indicator", in: indicator)
                            }
                            Image(systemName: tab.systemIcon)
                                .font(.system(size: 20, weight: .regular))
                                .foregroundStyle(selection == tab ? AppColor.primaryNavy : AppColor.textPrimary.opacity(0.6))
                        }
                        .frame(height: 30)
                        Text(tab.title)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(selection == tab ? AppColor.primaryNavy : AppColor.textPrimary.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .accessibilityLabel(tab.title)
                    .accessibilityAddTraits(selection == tab ? [.isSelected] : [])
                }
                .buttonStyle(.atmosm(haptic: false))  // we already haptic'd above
            }
        }
        .padding(.vertical, 10)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.04), radius: 8, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppColor.fieldBorder)
                .frame(height: 0.5)
        }
    }
}

#Preview {
    AppTabBar(selection: .constant(.home))
}
