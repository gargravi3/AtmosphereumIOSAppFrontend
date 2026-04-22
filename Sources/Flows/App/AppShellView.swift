import SwiftUI

// Main app shell shown once the user completes onboarding.
// Hosts a 4-tab bottom navigator and renders the current tab.
struct AppShellView: View {
    var onLogout: () -> Void = {}

    @State private var app = AppState()
    @State private var homePath = NavigationPath()
    @State private var reducePath = NavigationPath()
    @State private var showMenu = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch app.selectedTab {
                case .home:
                    NavigationStack(path: $homePath) {
                        HomeView(
                            app: app,
                            onShowFootprint: { homePath.append(HomeRoute.footprint) },
                            onBrowseReduce: { app.selectedTab = .reduce },
                            onMenu:   { showMenu = true }
                        )
                        .navigationDestination(for: HomeRoute.self) { route in
                            switch route {
                            case .footprint:
                                FootprintDetailView(
                                    app: app,
                                    onBack:   { homePath.removeLast() },
                                    onRefine: { homePath.append(HomeRoute.refine) }
                                )
                            case .refine:
                                RefineView(
                                    app: app,
                                    path: $homePath,
                                    onBack: { homePath.removeLast() },
                                    onRestart: {}
                                )
                            case .refineCategory(let category):
                                RefineCategoryEditor(
                                    app: app,
                                    path: $homePath,
                                    category: category
                                )
                            }
                        }
                    }
                case .leaderboard:
                    NavigationStack {
                        LeaderboardView(app: app, onMenu: { showMenu = true })
                    }
                case .reduce:
                    NavigationStack(path: $reducePath) {
                        ReduceView(app: app, path: $reducePath, onMenu: { showMenu = true })
                            .navigationDestination(for: ReduceRoute.self) { route in
                                switch route {
                                case .category(let name):
                                    ReduceCategoryListView(
                                        app: app,
                                        category: name,
                                        onBack:   { reducePath.removeLast() },
                                        onSelect: { goal in reducePath.append(ReduceRoute.goal(goal)) }
                                    )
                                case .goal(let goal):
                                    GoalDetailView(
                                        app: app,
                                        goal: goal,
                                        onBack: { reducePath.removeLast() }
                                    )
                                }
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            AppTabBar(selection: Binding(get: { app.selectedTab }, set: { app.selectedTab = $0 }))
        }
        .background(AppColor.lightBlueBackground)
        .ignoresSafeArea(.keyboard)
        .confirmationDialog("Account", isPresented: $showMenu, titleVisibility: .visible) {
            Button("Log Out", role: .destructive) { onLogout() }
            Button("Cancel", role: .cancel) {}
        }
    }
}

enum HomeRoute: Hashable {
    case footprint
    case refine
    case refineCategory(RefineCategory)
}

#Preview {
    AppShellView()
}
