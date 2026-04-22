import Foundation

// Thin REST client backed by URLSession. snake_case <-> camelCase conversion
// is configured once so Swift-side models use idiomatic names.
actor NetworkService {
    static let shared = NetworkService()

    private let session: URLSession
    private let baseURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private init() {
        self.session = URLSession(configuration: .default)
        self.baseURL = AppConfig.apiBaseURL

        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        e.dateEncodingStrategy = .iso8601
        self.encoder = e

        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        self.decoder = d
    }

    // MARK: - Auth

    func register(_ body: RegisterRequest) async throws -> AuthResponse {
        let res: AuthResponse = try await send("POST", path: "/auth/register", body: body, auth: false)
        KeychainHelper.saveToken(res.token)
        return res
    }

    func login(_ body: LoginRequest) async throws -> AuthResponse {
        let res: AuthResponse = try await send("POST", path: "/auth/login", body: body, auth: false)
        KeychainHelper.saveToken(res.token)
        return res
    }

    func logout() {
        KeychainHelper.clearToken()
    }

    var isAuthenticated: Bool {
        KeychainHelper.loadToken() != nil
    }

    // MARK: - Profile

    func getProfile() async throws -> UserResponse {
        try await send("GET", path: "/profile", body: Optional<Empty>.none, auth: true)
    }

    @discardableResult
    func updateProfile(_ body: ProfileUpdateRequest) async throws -> UserResponse {
        try await send("PUT", path: "/profile", body: body, auth: true)
    }

    // MARK: - Leaderboard

    func fetchLeaderboard(scope: LeaderboardScope = .global, limit: Int = 20) async throws -> LeaderboardResponse {
        let path = "/leaderboard?scope=\(scope.rawValue)&limit=\(limit)"
        return try await send("GET", path: path, body: Optional<Empty>.none, auth: true)
    }

    // MARK: - Goals / Coins

    func fetchGoals() async throws -> [Goal] {
        try await send("GET", path: "/goals", body: Optional<Empty>.none, auth: false)
    }

    func fetchMyGoals() async throws -> [UserGoal] {
        try await send("GET", path: "/goals/mine", body: Optional<Empty>.none, auth: true)
    }

    @discardableResult
    func addGoal(_ goalID: UUID) async throws -> UserGoal {
        try await send("POST", path: "/goals/\(goalID.uuidString)/add",
                       body: Optional<Empty>.none, auth: true)
    }

    @discardableResult
    func updateGoalStatus(_ goalID: UUID, status: GoalStatus) async throws -> UserGoal {
        try await send("PUT", path: "/goals/\(goalID.uuidString)/status",
                       body: UpdateGoalStatusRequest(status: status.rawValue), auth: true)
    }

    func fetchCoins() async throws -> CoinsResponse {
        try await send("GET", path: "/coins", body: Optional<Empty>.none, auth: true)
    }

    // MARK: - Core

    private struct Empty: Encodable {}

    private func send<B: Encodable, R: Decodable>(
        _ method: String,
        path: String,
        body: B?,
        auth: Bool
    ) async throws -> R {
        // Concatenate so that paths with query strings (e.g. "/leaderboard?scope=global")
        // are preserved correctly. appendingPathComponent would percent-encode the "?".
        let base = baseURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let prefixedPath = path.hasPrefix("/") ? path : "/\(path)"
        guard let url = URL(string: base + prefixedPath) else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        if auth {
            guard let token = KeychainHelper.loadToken() else {
                throw APIError.httpStatus(401, "Not logged in")
            }
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            req.httpBody = try encoder.encode(body)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: req)
        } catch {
            throw APIError.transport(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.transport("No HTTP response")
        }

        if (200..<300).contains(http.statusCode) {
            do {
                return try decoder.decode(R.self, from: data)
            } catch {
                throw APIError.decoding(String(describing: error))
            }
        }

        // Try to surface the server's "reason" string.
        let reason = (try? decoder.decode(APIErrorBody.self, from: data))?.reason
            ?? String(data: data, encoding: .utf8)
        throw APIError.httpStatus(http.statusCode, reason)
    }
}
