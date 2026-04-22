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

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button { selection = tab } label: {
                    VStack(spacing: 2) {
                        Image(systemName: tab.systemIcon)
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(selection == tab ? AppColor.primaryNavy : AppColor.textPrimary.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 12)
        .background(Color.white.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppColor.fieldBorder)
                .frame(height: 1)
        }
    }
}

#Preview {
    AppTabBar(selection: .constant(.home))
}
