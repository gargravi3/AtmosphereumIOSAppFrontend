import Foundation

struct Industry: Identifiable, Hashable {
    let id: String
    let title: String
    let systemIcon: String
    let assetImage: String?

    static let featured: [Industry] = [
        .init(id: "retail",   title: "Retail",   systemIcon: "bag.fill",       assetImage: "IndustryRetail"),
        .init(id: "aviation", title: "Aviation", systemIcon: "airplane",       assetImage: "IndustryAviation"),
        .init(id: "services", title: "Services", systemIcon: "gearshape.fill", assetImage: "IndustryServices"),
        .init(id: "food",     title: "Food",     systemIcon: "fork.knife",     assetImage: "IndustryFood")
    ]

    static let others: [String] = [
        "Construction",
        "Education",
        "Finance",
        "Healthcare",
        "Manufacturing",
        "Technology",
        "Transportation"
    ]
}
