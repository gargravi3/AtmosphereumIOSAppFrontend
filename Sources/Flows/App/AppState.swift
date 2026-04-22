import SwiftUI

// Application-level state used by the main app shell (post-onboarding).
@Observable
final class AppState {
    var selectedTab: AppTab = .home

    // Server-computed carbon footprint. Nil until the first /profile fetch.
    var tonsTotal: Double? = nil
    var tonsDriving: Double? = nil
    var tonsFlights: Double? = nil
    var tonsFood: Double? = nil
    var tonsUtilities: Double? = nil
    var tonsWaste: Double? = nil

    var userFirstName: String = ""
    var userLastName: String = ""

    // Atmosm Coins (1 coin = 1 kg CO2 reduction)
    var coinsTotal: Int = 0
    var coinsEquivalentKg: Int = 0
    var coinsNeededForNetZero: Int = 0

    // Goal catalog + current-user goals
    var catalog: [Goal] = []
    var myGoals: [UserGoal] = []

    var isLoadingProfile: Bool = false
    var profileError: String? = nil

    // Donut/stacked-bar breakdown in the app's chart colour palette.
    // Falls back to zero-valued demo segments until data arrives.
    var breakdown: [DonutSegment] {
        [
            .init(label: "Driving",   value: tonsDriving   ?? 0, color: AppColor.chartRed),
            .init(label: "Flights",   value: tonsFlights   ?? 0, color: AppColor.chartGreen),
            .init(label: "Food",      value: tonsFood      ?? 0, color: AppColor.chartOrange),
            .init(label: "Energy",    value: tonsUtilities ?? 0, color: AppColor.primaryNavy),
            .init(label: "Lifestyle", value: tonsWaste     ?? 0, color: AppColor.chartPurple)
        ]
    }

    /// Returns `tonsTotal` if the server has computed it, else falls back to
    /// summing the breakdown so the UI always has something to show.
    var displayTons: Double {
        if let t = tonsTotal { return t }
        return breakdown.reduce(0) { $0 + $1.value }
    }

    func apply(profile: UserResponse) {
        self.userFirstName = profile.firstName
        self.userLastName  = profile.lastName
        self.tonsTotal     = profile.tonsTotal
        self.tonsDriving   = profile.tonsDriving
        self.tonsFlights   = profile.tonsFlights
        self.tonsFood      = profile.tonsFood
        self.tonsUtilities = profile.tonsUtilities
        self.tonsWaste     = profile.tonsWaste
        self.coinsTotal    = profile.coinsTotal ?? 0
        self.coinsEquivalentKg = profile.coinsTotal ?? 0
        self.coinsNeededForNetZero = max(Int((profile.tonsTotal ?? 0) * 1000) - (profile.coinsTotal ?? 0), 0)
    }

    func apply(coins: CoinsResponse) {
        self.coinsTotal = coins.total
        self.coinsEquivalentKg = coins.equivalentKg
        self.coinsNeededForNetZero = coins.neededForNetZero
    }

    /// Fetches the latest profile from the backend. Safe to call multiple
    /// times; updates in-place.
    func reloadFromServer() async {
        guard await NetworkService.shared.isAuthenticated else { return }
        await MainActor.run { self.isLoadingProfile = true; self.profileError = nil }
        do {
            let profile = try await NetworkService.shared.getProfile()
            let coins   = try await NetworkService.shared.fetchCoins()
            let myGoals = try await NetworkService.shared.fetchMyGoals()
            await MainActor.run {
                self.apply(profile: profile)
                self.apply(coins: coins)
                self.myGoals = myGoals
                self.isLoadingProfile = false
            }
        } catch {
            await MainActor.run {
                self.profileError = error.localizedDescription
                self.isLoadingProfile = false
            }
        }
    }

    /// Fetches the public goal catalog — safe to call without auth.
    func loadCatalog() async {
        do {
            let goals = try await NetworkService.shared.fetchGoals()
            await MainActor.run { self.catalog = goals }
        } catch {
            print("[AppState] loadCatalog failed: \(error)")
        }
    }

    /// Adds a goal to the current user's list. Server returns the new
    /// UserGoal and the add-bonus is already reflected in coinsTotal after
    /// reloadFromServer(), so we refresh after mutation.
    func addGoal(_ goalID: UUID) async {
        do {
            _ = try await NetworkService.shared.addGoal(goalID)
            await reloadFromServer()
        } catch {
            print("[AppState] addGoal failed: \(error)")
        }
    }

    func updateGoal(_ goalID: UUID, status: GoalStatus) async {
        do {
            _ = try await NetworkService.shared.updateGoalStatus(goalID, status: status)
            await reloadFromServer()
        } catch {
            print("[AppState] updateGoalStatus failed: \(error)")
        }
    }

    /// Convenience look-up used by Reduce detail — does the current user
    /// already have this goal in their list?
    func myGoal(for goalID: UUID) -> UserGoal? {
        myGoals.first { $0.goalId == goalID }
    }
}
