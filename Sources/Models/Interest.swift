import Foundation

struct Interest: Identifiable, Hashable {
    let id: String
    let title: String
    let systemIcon: String
    let assetImage: String?

    static let all: [Interest] = [
        .init(id: "clean_water",   title: "Clean Water and Sanitation",             systemIcon: "drop.fill",              assetImage: "InterestCleanWater"),
        .init(id: "clean_energy",  title: "Affordable and Clean Energy",            systemIcon: "bolt.fill",              assetImage: "InterestEnergy"),
        .init(id: "industry",      title: "Industry, Innovation and Infrastructure", systemIcon: "building.2.fill",        assetImage: "InterestIndustry"),
        .init(id: "cities",        title: "Sustainable Cities and Communities",     systemIcon: "building.columns.fill",  assetImage: "InterestCities"),
        .init(id: "consumption",   title: "Responsible Consumption and Production", systemIcon: "arrow.3.trianglepath",   assetImage: nil),
        .init(id: "climate",       title: "Climate Action",                         systemIcon: "leaf.fill",              assetImage: "InterestClimate"),
        .init(id: "below_water",   title: "Life Below Water",                       systemIcon: "fish.fill",              assetImage: "InterestBelowWater"),
        .init(id: "on_land",       title: "Life on Land",                           systemIcon: "tree.fill",              assetImage: "InterestOnLand"),
        .init(id: "peace",         title: "Peace, Justice and Strong Institutions", systemIcon: "scalemass.fill",         assetImage: nil)
    ]
}
