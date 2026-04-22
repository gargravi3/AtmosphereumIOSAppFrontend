import Foundation

// Centralized runtime config. Override via Info.plist key `API_BASE_URL`
// so you can point at localhost in Debug and the Render URL in Release.
enum AppConfig {
    static let apiBaseURL: URL = {
        if let str = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           !str.isEmpty,
           let url = URL(string: str) {
            return url
        }
        // Dev default: Vapor backend running on the host machine.
        // Simulator can reach host via localhost; a device would need your LAN IP.
        return URL(string: "http://127.0.0.1:8080")!
    }()
}
