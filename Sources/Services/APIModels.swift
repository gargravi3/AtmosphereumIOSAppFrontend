import Foundation

// DTOs matching the Vapor backend. JSON uses snake_case on both sides.
struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct AuthResponse: Decodable {
    let token: String
    let user: UserResponse
}

struct EmailAvailabilityResponse: Decodable {
    let available: Bool
}

struct UserResponse: Codable {
    let id: UUID
    let email: String
    let firstName: String
    let lastName: String

    var interests: [String]?
    var region: String?
    var industry: String?
    var otherIndustry: String?

    var atmosmHandle: String?
    var country: String?
    var city: String?
    var functionRole: String?

    var transportModes: [String]?
    var kmPerMonth: Double?

    var drivingModeMotorbikePct: Double?
    var drivingModeCarPct: Double?
    var drivingModeTransitPct: Double?
    var drivingModeCyclingPct: Double?
    var drivingModeWalkPct: Double?
    var drivingFuelType: String?
    var officeCommuteKm: Double?

    var flightsPerYear: Double?
    var flightClass: String?

    var flightsEconomyPersonal: Int?
    var flightsEconomyWork: Int?
    var flightsBusinessPersonal: Int?
    var flightsBusinessWork: Int?
    var flightsFirstPersonal: Int?
    var flightsFirstWork: Int?

    var flightsLocalPersonal: Int?
    var flightsLocalWork: Int?
    var flightsRegionalPersonal: Int?
    var flightsRegionalWork: Int?
    var flightsGlobalPersonal: Int?
    var flightsGlobalWork: Int?
    var flightsExtendedPersonal: Int?
    var flightsExtendedWork: Int?

    var foodVegan: Int?
    var foodDairy: Int?
    var foodFish: Int?
    var foodPoultry: Int?
    var foodRedMeat: Int?

    var foodLocal: Int?
    var foodWastePercent: Double?

    var electricityBill: String?
    var heatingBill: String?
    var coolingBill: String?
    var waterBill: String?
    var wfhDays: String?
    var householdSize: Double?

    var recyclePaper: Bool?
    var recyclePlastic: Bool?
    var recycleGlass: Bool?
    var recycleMetal: Bool?
    var recycleFood: Bool?
    var recycleClothes: Bool?
    var recycleFurniture: Bool?
    var recycleElectronics: Bool?

    // Computed carbon footprint (tCO2/yr)
    var tonsDriving: Double?
    var tonsFlights: Double?
    var tonsFood: Double?
    var tonsUtilities: Double?
    var tonsWaste: Double?
    var tonsTotal: Double?

    // Atmosm Coins
    var coinsTotal: Int?
}

struct LeaderboardEntry: Decodable, Identifiable {
    let rank: Int
    let userId: UUID
    let firstName: String
    let lastName: String
    let tonsTotal: Double
    let tonsDriving: Double?
    let tonsFlights: Double?
    let tonsFood: Double?
    let tonsUtilities: Double?
    let tonsWaste: Double?
    let isMe: Bool

    var id: UUID { userId }
    var fullName: String { "\(firstName) \(lastName)" }
}

struct LeaderboardResponse: Decodable {
    let entries: [LeaderboardEntry]
    let myRank: Int?
    let myTonsTotal: Double?
}

enum LeaderboardScope: String {
    case global, country, organization
}

struct ProfileUpdateRequest: Encodable {
    var firstName: String?
    var lastName: String?

    var interests: [String]?
    var region: String?
    var industry: String?
    var otherIndustry: String?

    var atmosmHandle: String?
    var country: String?
    var city: String?
    var functionRole: String?

    var transportModes: [String]?
    var kmPerMonth: Double?

    var drivingModeMotorbikePct: Double?
    var drivingModeCarPct: Double?
    var drivingModeTransitPct: Double?
    var drivingModeCyclingPct: Double?
    var drivingModeWalkPct: Double?
    var drivingFuelType: String?
    var officeCommuteKm: Double?

    var flightsPerYear: Double?
    var flightClass: String?

    var flightsEconomyPersonal: Int?
    var flightsEconomyWork: Int?
    var flightsBusinessPersonal: Int?
    var flightsBusinessWork: Int?
    var flightsFirstPersonal: Int?
    var flightsFirstWork: Int?

    var flightsLocalPersonal: Int?
    var flightsLocalWork: Int?
    var flightsRegionalPersonal: Int?
    var flightsRegionalWork: Int?
    var flightsGlobalPersonal: Int?
    var flightsGlobalWork: Int?
    var flightsExtendedPersonal: Int?
    var flightsExtendedWork: Int?

    var foodVegan: Int?
    var foodDairy: Int?
    var foodFish: Int?
    var foodPoultry: Int?
    var foodRedMeat: Int?

    var foodLocal: Int?
    var foodWastePercent: Double?

    var electricityBill: String?
    var heatingBill: String?
    var coolingBill: String?
    var waterBill: String?
    var wfhDays: String?
    var householdSize: Double?

    var recyclePaper: Bool?
    var recyclePlastic: Bool?
    var recycleGlass: Bool?
    var recycleMetal: Bool?
    var recycleFood: Bool?
    var recycleClothes: Bool?
    var recycleFurniture: Bool?
    var recycleElectronics: Bool?
}

// MARK: - Goals / coins

struct Goal: Decodable, Identifiable, Hashable {
    let id: UUID
    let category: String
    let title: String
    let body: String
    let imageAsset: String
    let coinReward: Int
    let shareText: String?
}

struct UserGoal: Codable, Identifiable, Hashable {
    let id: UUID
    let goalId: UUID
    let category: String
    let title: String
    let body: String
    let imageAsset: String
    let coinReward: Int
    let shareText: String?
    var status: String             // "added" | "in_progress" | "complete"
    var coinsEarned: Int
    let addedAt: Date?
    var completedAt: Date?
}

enum GoalStatus: String {
    case added
    case inProgress = "in_progress"
    case complete
}

struct UpdateGoalStatusRequest: Encodable {
    let status: String
}

struct CoinsResponse: Decodable {
    let total: Int
    let equivalentKg: Int
    let neededForNetZero: Int
    let annualTons: Double?
}

// MARK: - Match-day Fan Page

struct MatchDayLogRequest: Encodable {
    let club: String?
    let matchDate: Date?
    let transport: String
    let distanceKm: Double
    let foodChoice: String
    let recycled: Bool
    let reusableCup: Bool
}

struct MatchDayLogResponse: Decodable {
    let id: UUID
    let matchDate: Date
    let transport: String
    let distanceKm: Double
    let foodChoice: String
    let recycled: Bool
    let reusableCup: Bool
    let kgEmitted: Double
    let coinsEarned: Int
    let newTonsTotal: Double
    let newCoinsTotal: Int
}

struct MatchDayEntry: Decodable, Identifiable, Hashable {
    let id: UUID
    let matchDate: Date
    let transport: String
    let distanceKm: Double
    let foodChoice: String
    let recycled: Bool
    let reusableCup: Bool
    let kgEmitted: Double
    let coinsEarned: Int
}

struct MatchDaySummary: Decodable, Equatable {
    let matchCount: Int
    let totalKgEmitted: Double
    let totalKgSaved: Double
    let totalCoinsEarned: Int
    let lastMatchDate: Date?
    let averageKgPerMatch: Double
}

// User-facing names mirroring the backend's MatchTransport/MatchFood enums.
enum MatchTransport: String, CaseIterable, Hashable {
    case walk, bike, bus, train, car, rideshare
    var displayName: String {
        switch self {
        case .walk:      return "Walk"
        case .bike:      return "Bike"
        case .bus:       return "Bus"
        case .train:     return "Train"
        case .car:       return "Car"
        case .rideshare: return "Rideshare"
        }
    }
    var systemIcon: String {
        switch self {
        case .walk:      return "figure.walk"
        case .bike:      return "bicycle"
        case .bus:       return "bus.fill"
        case .train:     return "tram.fill"
        case .car:       return "car.fill"
        case .rideshare: return "car.2.fill"
        }
    }
}

enum MatchFood: String, CaseIterable, Hashable {
    case none
    case plantBased = "plant_based"
    case veggie
    case meat

    var displayName: String {
        switch self {
        case .none:       return "Skipped food"
        case .plantBased: return "Plant-based"
        case .veggie:     return "Veggie"
        case .meat:       return "Meat"
        }
    }

    /// Short subtitle shown under the card so users understand what
    /// each choice covers without having to guess.
    var helperText: String {
        switch self {
        case .none:       return "Didn't grab anything"
        case .plantBased: return "No meat or dairy"
        case .veggie:     return "Dairy or cheese, no meat"
        case .meat:       return "Burger, pie, chicken, sausage"
        }
    }

    var systemIcon: String {
        switch self {
        case .none:       return "xmark.circle"
        case .plantBased: return "leaf.fill"
        case .veggie:     return "fork.knife"
        case .meat:       return "flame.fill"
        }
    }

    /// Tint used on the card icon. Kept in sync with the existing
    /// chart palette so the page doesn't introduce new colours.
    var tint: String {   // hex string — converted at use-site
        switch self {
        case .none:       return "#555555"        // neutral grey
        case .plantBased: return "#3FC68F"        // chartGreen
        case .veggie:     return "#F2A75C"        // chartOrange
        case .meat:       return "#F46B5E"        // chartRed
        }
    }
}

// Rough-distance bucket for the travel step. Fans rarely know their
// exact round-trip km — these four buckets cover every realistic case.
enum MatchDistanceBucket: String, CaseIterable, Hashable, Identifiable {
    case local       // <5km
    case nearby      // 5-15km
    case acrossTown  // 15-30km
    case longTrip    // 30km+

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .local:       return "Local"
        case .nearby:      return "Nearby"
        case .acrossTown:  return "Across town"
        case .longTrip:    return "Long trip"
        }
    }

    var helperText: String {
        switch self {
        case .local:       return "Under 5 km"
        case .nearby:      return "5 to 15 km"
        case .acrossTown:  return "15 to 30 km"
        case .longTrip:    return "Over 30 km"
        }
    }

    /// Midpoint km value sent over the wire — good enough for the
    /// emission calc since the buckets are coarse by design.
    var representativeKm: Double {
        switch self {
        case .local:       return 2.5
        case .nearby:      return 10.0
        case .acrossTown:  return 22.5
        case .longTrip:    return 40.0
        }
    }
}

struct APIErrorBody: Decodable {
    let error: Bool?
    let reason: String?
}

enum APIError: LocalizedError {
    case invalidURL
    case httpStatus(Int, String?)
    case decoding(String)
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:            return "Invalid URL."
        case .httpStatus(_, let m?): return m
        case .httpStatus(let s, _):  return "HTTP \(s)"
        case .decoding(let m):       return "Decoding error: \(m)"
        case .transport(let m):      return m
        }
    }
}
