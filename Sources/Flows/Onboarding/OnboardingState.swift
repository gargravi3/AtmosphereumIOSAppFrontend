import SwiftUI

@Observable
final class OnboardingState {
    // Signup
    var email: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var password: String = ""
    var confirmPassword: String = ""

    // API / network
    var isSubmitting: Bool = false
    var signupError: String? = nil

    // Interests
    var selectedInterests: Set<String> = []

    // Region
    var selectedRegion: String? = nil

    // Industry
    var selectedIndustry: String? = nil
    var otherIndustry: String? = nil

    // Tell Us More
    var atmosmHandle: String = ""
    var country: String? = nil
    var city: String? = nil
    var function: String? = nil

    // Driving
    var transportModes: Set<String> = []
    var kilometersPerMonth: Double = 1000

    // Driving — refine
    var drivingModeMotorbikePct: Double = 20
    var drivingModeCarPct:       Double = 20
    var drivingModeTransitPct:   Double = 20
    var drivingModeCyclingPct:   Double = 20
    var drivingModeWalkPct:      Double = 20
    var drivingFuelType: String? = nil   // Diesel / Petrol/Gasoline / EV / Hybrid / CNG/LPG
    var officeCommuteKm: Double = 1000

    // Flights
    var flightsPerYear: Double = 2
    var flightClass: String = "Economy"

    // Flights — refine (class x purpose matrix)
    var flightsEconomyPersonal: Int = 0
    var flightsEconomyWork:     Int = 0
    var flightsBusinessPersonal: Int = 0
    var flightsBusinessWork:     Int = 0
    var flightsFirstPersonal:    Int = 0
    var flightsFirstWork:        Int = 0

    // Flights — refine (duration x purpose matrix)
    var flightsLocalPersonal:     Int = 0
    var flightsLocalWork:         Int = 0
    var flightsRegionalPersonal:  Int = 0
    var flightsRegionalWork:      Int = 0
    var flightsGlobalPersonal:    Int = 0
    var flightsGlobalWork:        Int = 0
    var flightsExtendedPersonal:  Int = 0   // ">10 hours"
    var flightsExtendedWork:      Int = 0

    // Food (0=Never, 1=Sometimes, 2=Mostly, 3=Always)
    var foodVegan: Int = 2
    var foodDairy: Int = 1
    var foodFish: Int = 1
    var foodPoultry: Int = 1
    var foodRedMeat: Int = 1

    // Food — refine
    var foodLocal: Int = 1                // Never / Sometimes / Mostly / Always
    var foodWastePercent: Double = 20     // 0-80%

    // Tracker-screen visit flags. Used to decide whether to include a
    // category's data in the PUT payload. Pure state defaults look the same
    // as filled-in defaults, so these flags are how we tell them apart.
    // See OnboardingCoordinator — each tracker screen sets its flag to true
    // on Next.
    var didVisitDriving: Bool = false
    var didVisitFlights: Bool = false
    var didVisitFood: Bool = false
    var didVisitUtilities: Bool = false
    var didVisitWaste: Bool = false

    // Utilities
    var electricityBill: String = ""
    var heatingBill: String = ""
    var coolingBill: String = ""
    var waterBill: String = ""
    var wfhDays: String = ""
    var householdSize: Double = 5

    // Waste (recycling)
    var recyclePaper: Bool? = true
    var recyclePlastic: Bool? = nil
    var recycleGlass: Bool? = nil
    var recycleMetal: Bool? = nil
    var recycleFood: Bool? = nil
    var recycleClothes: Bool? = nil
    var recycleFurniture: Bool? = nil
    var recycleElectronics: Bool? = nil

    var passwordStrength: Int {
        PasswordStrengthBar.evaluate(password)
    }

    var isSignupValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        Self.isLikelyEmail(email) &&
        password.count >= 8 &&
        password == confirmPassword
    }

    static func isLikelyEmail(_ s: String) -> Bool {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let at = t.firstIndex(of: "@"), at != t.startIndex else { return false }
        let domain = t[t.index(after: at)...]
        return domain.contains(".") && !domain.hasPrefix(".") && !domain.hasSuffix(".")
    }

    var hasEnoughInterests: Bool { selectedInterests.count >= 4 }

    // Build a PUT /profile payload from the current onboarding state.
    //
    // Each tracker category is gated by its didVisit* flag — we only send
    // a category's data once the user has actually stepped past that screen,
    // otherwise defaults would look like real input and the backend's
    // country-baseline fallback (for "Do this later") would never kick in.
    func profileUpdatePayload() -> ProfileUpdateRequest {
        var req = ProfileUpdateRequest()

        req.firstName = firstName.isEmpty ? nil : firstName
        req.lastName  = lastName.isEmpty  ? nil : lastName
        req.interests = selectedInterests.isEmpty ? nil : Array(selectedInterests)
        req.region    = selectedRegion
        req.industry  = selectedIndustry
        req.otherIndustry = otherIndustry
        req.atmosmHandle = atmosmHandle.isEmpty ? nil : atmosmHandle
        req.country = country
        req.city = city
        req.functionRole = function

        if didVisitDriving {
            req.transportModes = Array(transportModes)
            req.kmPerMonth = kilometersPerMonth
            // Driving refine — ship as a package once the user has visited
            // driving; a non-nil value is how the backend decides to use the
            // refined mode-% formula.
            req.drivingModeMotorbikePct = drivingModeMotorbikePct
            req.drivingModeCarPct       = drivingModeCarPct
            req.drivingModeTransitPct   = drivingModeTransitPct
            req.drivingModeCyclingPct   = drivingModeCyclingPct
            req.drivingModeWalkPct      = drivingModeWalkPct
            req.drivingFuelType         = drivingFuelType
            req.officeCommuteKm         = officeCommuteKm
        }

        if didVisitFlights {
            req.flightsPerYear = flightsPerYear
            req.flightClass = flightClass
            req.flightsEconomyPersonal  = flightsEconomyPersonal
            req.flightsEconomyWork      = flightsEconomyWork
            req.flightsBusinessPersonal = flightsBusinessPersonal
            req.flightsBusinessWork     = flightsBusinessWork
            req.flightsFirstPersonal    = flightsFirstPersonal
            req.flightsFirstWork        = flightsFirstWork
            req.flightsLocalPersonal    = flightsLocalPersonal
            req.flightsLocalWork        = flightsLocalWork
            req.flightsRegionalPersonal = flightsRegionalPersonal
            req.flightsRegionalWork     = flightsRegionalWork
            req.flightsGlobalPersonal   = flightsGlobalPersonal
            req.flightsGlobalWork       = flightsGlobalWork
            req.flightsExtendedPersonal = flightsExtendedPersonal
            req.flightsExtendedWork     = flightsExtendedWork
        }

        if didVisitFood {
            req.foodVegan = foodVegan
            req.foodDairy = foodDairy
            req.foodFish = foodFish
            req.foodPoultry = foodPoultry
            req.foodRedMeat = foodRedMeat
            req.foodLocal = foodLocal
            req.foodWastePercent = foodWastePercent
        }

        if didVisitUtilities {
            req.electricityBill = electricityBill.isEmpty ? nil : electricityBill
            req.heatingBill     = heatingBill.isEmpty ? nil : heatingBill
            req.coolingBill     = coolingBill.isEmpty ? nil : coolingBill
            req.waterBill       = waterBill.isEmpty ? nil : waterBill
            req.wfhDays         = wfhDays.isEmpty ? nil : wfhDays
            req.householdSize   = householdSize
        }

        if didVisitWaste {
            req.recyclePaper       = recyclePaper
            req.recyclePlastic     = recyclePlastic
            req.recycleGlass       = recycleGlass
            req.recycleMetal       = recycleMetal
            req.recycleFood        = recycleFood
            req.recycleClothes     = recycleClothes
            req.recycleFurniture   = recycleFurniture
            req.recycleElectronics = recycleElectronics
        }

        return req
    }

    // Fire-and-forget profile sync. Skips silently if we're not logged in
    // or the backend is unreachable — onboarding UX should not block.
    func syncProfile() {
        Task { await syncProfileAwait() }
    }

    /// Awaitable version — used at the end of onboarding so the Home screen
    /// loads the freshly-computed footprint instead of racing the PUT.
    @discardableResult
    func syncProfileAwait() async -> UserResponse? {
        guard await NetworkService.shared.isAuthenticated else { return nil }
        do {
            return try await NetworkService.shared.updateProfile(profileUpdatePayload())
        } catch {
            print("[OnboardingState] profile sync failed: \(error)")
            return nil
        }
    }
}

enum OnboardingStep: Hashable {
    case terms
    case interests
    case region
    case industry
    case tellUsMore
    case trackerIntro   // "Welcome to Atmosphereum" — second Tell Us More screen
    case driving
    case flights
    case food
    case utilities
    case waste
    case done
}

enum TrackerCategory: String, CaseIterable, Hashable {
    case driving, flights, food, utilities, waste
    case industry // placeholder for the "bag" icon in the tracker

    var systemIcon: String {
        switch self {
        case .driving:   return "car.fill"
        case .flights:   return "airplane"
        case .food:      return "fork.knife"
        case .utilities: return "bolt.fill"
        case .industry:  return "bag.fill"
        case .waste:     return "trash.fill"
        }
    }

    // Full order as shown in Figma tracker
    static let order: [TrackerCategory] = [.driving, .flights, .food, .utilities, .industry, .waste]
}
