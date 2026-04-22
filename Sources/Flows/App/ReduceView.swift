import SwiftUI

private enum ReduceTab: String, Hashable, CaseIterable {
    case browse = "Browse"
    case myGoals = "My Goals"
}

enum ReduceRoute: Hashable {
    case goal(Goal)
    case category(String)
}

struct ReduceView: View {
    @Bindable var app: AppState
    @Binding var path: NavigationPath
    let onMenu: () -> Void

    @State private var tab: ReduceTab = .browse
    @State private var search: String = ""

    // Fallback image per category for the tiles (until we have real imagery).
    private let categoryAssets: [String: String] = [
        "Advocacy and Choice":  "ReduceCardForest",
        "Family and Community": "ReduceCardCommunity",
        "Travel and Vacations": "ReduceCardForest",
        "Home and Lifestyle":   "ReduceCardCommunity"
    ]

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(spacing: 16) {
                HomeHeader(onMenu: onMenu)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                Text("Reduce")
                    .font(.atmosmTitle)
                    .foregroundStyle(AppColor.primaryNavy)

                segmentControl
                    .padding(.horizontal, 24)

                SearchBar(text: $search)
                    .padding(.horizontal, 24)

                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        if tab == .browse {
                            browseContent
                        } else {
                            myGoalsContent
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .task {
            await app.loadCatalog()
            await app.reloadFromServer()
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: - Browse

    @ViewBuilder
    private var browseContent: some View {
        Text("Browse Categories")
            .font(.atmosmTitle)
            .foregroundStyle(AppColor.primaryNavy)
            .padding(.horizontal, 24)

        let categories = groupedCategories()
        ForEach(categories, id: \.self) { cat in
            CategoryTile(
                title: cat,
                count: goalsByCategory(cat).count,
                imageAsset: categoryAssets[cat] ?? "ReduceCardForest",
                onTap: { path.append(ReduceRoute.category(cat)) }
            )
            .padding(.horizontal, 24)
        }
    }

    // MARK: - My Goals

    @ViewBuilder
    private var myGoalsContent: some View {
        if app.myGoals.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundStyle(AppColor.primaryNavy)
                Text("No goals yet")
                    .font(.atmosmTitle)
                    .foregroundStyle(AppColor.primaryNavy)
                Text("Head to Browse to pick a goal and start earning coins.")
                    .font(.atmosmBody)
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 32)
            .padding(.horizontal, 24)
        } else {
            ForEach(filteredMyGoals) { ug in
                if let g = matchingGoal(for: ug) {
                    Button { path.append(ReduceRoute.goal(g)) } label: {
                        MyGoalRow(userGoal: ug)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                }
            }
        }
    }

    // MARK: - Helpers

    private func groupedCategories() -> [String] {
        let all = Set(app.catalog.map { $0.category })
        return all.sorted()
    }

    private func goalsByCategory(_ category: String) -> [Goal] {
        app.catalog.filter { $0.category == category }
    }

    private var filteredMyGoals: [UserGoal] {
        if search.isEmpty { return app.myGoals }
        let lc = search.lowercased()
        return app.myGoals.filter {
            $0.title.lowercased().contains(lc) || $0.category.lowercased().contains(lc)
        }
    }

    private func matchingGoal(for ug: UserGoal) -> Goal? {
        app.catalog.first { $0.id == ug.goalId }
            ?? Goal.placeholder(from: ug)
    }

    private var segmentControl: some View {
        HStack(spacing: 0) {
            ForEach(ReduceTab.allCases, id: \.self) { item in
                Button { tab = item } label: {
                    Text(item.rawValue)
                        .font(.atmosmBody.bold())
                        .foregroundStyle(tab == item ? .white : AppColor.primaryNavy)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Capsule().fill(tab == item ? AppColor.primaryNavy : AppColor.lightBluePill))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Capsule().fill(AppColor.lightBluePill))
    }
}

// MARK: - Category tile

private struct CategoryTile: View {
    let title: String
    let count: Int
    let imageAsset: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                if UIImage(named: imageAsset) != nil {
                    Image(imageAsset)
                        .resizable().scaledToFill()
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColor.fieldBackground).frame(height: 150)
                }
                Text("\(title) (\(count) Goals)")
                    .font(.atmosmBody)
                    .foregroundStyle(AppColor.textPrimary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - My Goals row

private struct MyGoalRow: View {
    let userGoal: UserGoal

    var body: some View {
        HStack(spacing: 12) {
            if UIImage(named: userGoal.imageAsset) != nil {
                Image(userGoal.imageAsset)
                    .resizable().scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColor.fieldBackground)
                    .frame(width: 72, height: 72)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(userGoal.title)
                    .font(.atmosmBody.bold())
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)
                Text(userGoal.category)
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.textPrimary.opacity(0.6))
                GoalProgressBar(status: GoalStatus(rawValue: userGoal.status) ?? .added)
                    .padding(.top, 4)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(userGoal.coinReward)")
                    .font(.atmosmBody.bold())
                    .foregroundStyle(AppColor.primaryNavy)
                Text("coins")
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.textPrimary.opacity(0.6))
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(AppColor.fieldBackground))
    }
}

// Category list (one step below a category tile)
struct ReduceCategoryListView: View {
    @Bindable var app: AppState
    let category: String
    let onBack: () -> Void
    let onSelect: (Goal) -> Void

    var body: some View {
        ZStack {
            AppColor.lightBlueBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        IconButton(systemName: "chevron.left", accessibilityLabel: "Back", action: onBack)
                        Spacer()
                    }
                    Text(category)
                        .font(.atmosmTitle)
                        .foregroundStyle(AppColor.primaryNavy)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .padding(.horizontal, 12)
                .padding(.top, 4)

                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(app.catalog.filter { $0.category == category }) { g in
                            Button { onSelect(g) } label: {
                                GoalRow(goal: g)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

private struct GoalRow: View {
    let goal: Goal
    var body: some View {
        HStack(spacing: 12) {
            if UIImage(named: goal.imageAsset) != nil {
                Image(goal.imageAsset)
                    .resizable().scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColor.fieldBackground)
                    .frame(width: 72, height: 72)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.atmosmBody.bold())
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)
                Text(goal.body)
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.textPrimary.opacity(0.7))
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(goal.coinReward)")
                    .font(.atmosmBody.bold())
                    .foregroundStyle(AppColor.primaryNavy)
                Text("coins")
                    .font(.atmosmCaption)
                    .foregroundStyle(AppColor.textPrimary.opacity(0.6))
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(AppColor.fieldBackground))
    }
}

// Lets us render a GoalRow for a user-goal when the catalog hasn't loaded yet.
fileprivate extension Goal {
    static func placeholder(from ug: UserGoal) -> Goal {
        Goal(
            id: ug.goalId,
            category: ug.category,
            title: ug.title,
            body: ug.body,
            imageAsset: ug.imageAsset,
            coinReward: ug.coinReward,
            shareText: ug.shareText
        )
    }
}
