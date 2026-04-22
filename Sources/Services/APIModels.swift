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
