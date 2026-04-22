import Foundation

struct Region: Identifiable, Hashable {
    let id: String
    let title: String
    let systemIcon: String
    let assetImage: String?

    static let all: [Region] = [
        .init(id: "asia",           title: "Asia",          systemIcon: "globe.asia.australia.fill", assetImage: "RegionAsia"),
        .init(id: "middle_east",    title: "Middle East",   systemIcon: "globe",                     assetImage: "RegionMiddleEast"),
        .init(id: "europe",         title: "Europe",        systemIcon: "globe.europe.africa.fill",  assetImage: "RegionEurope"),
        .init(id: "north_america",  title: "North America", systemIcon: "globe.americas.fill",       assetImage: "RegionNorthAmerica"),
        .init(id: "africa",         title: "Africa",        systemIcon: "globe.europe.africa.fill",  assetImage: nil),
        .init(id: "south_america",  title: "South America", systemIcon: "globe.americas.fill",       assetImage: "RegionSouthAmerica")
    ]
}
