import Foundation

struct Achievement: Identifiable {
    let id: String
    let title: String
    let icon: String  // SF Symbol name
    let isUnlocked: Bool
}

enum AchievementEngine {
    static func achievements(for logged: [LoggedFruit], catalog: [Fruit] = FruitCatalog.all) -> [Achievement] {
        let fruitsById = Dictionary(uniqueKeysWithValues: catalog.map { ($0.id, $0) })
        let tried = logged.compactMap { fruitsById[$0.fruitId] }
        let countries = Set(tried.map(\.country))
        let regions = Set(tried.map(\.region))
        let hasVeryRareOrHigher = tried.contains { $0.rarity.rawValue >= Rarity.veryRare.rawValue }
        let hasLegendary = tried.contains { $0.rarity == .legendary }

        return [
            Achievement(id: "first_bite", title: "First Bite", icon: "leaf.fill", isUnlocked: tried.count >= 1),
            Achievement(id: "fruit_fan", title: "Fruit Fan", icon: "star.fill", isUnlocked: tried.count >= 5),
            Achievement(id: "world_traveler", title: "World Traveler", icon: "airplane", isUnlocked: countries.count >= 5),
            Achievement(id: "region_hopper", title: "Region Hopper", icon: "globe.americas.fill", isUnlocked: regions.count >= 4),
            Achievement(id: "globe_trotter", title: "Globe Trotter", icon: "globe", isUnlocked: regions.count >= Region.allCases.count),
            Achievement(id: "brave_tongue", title: "Brave Tongue", icon: "flame.fill", isUnlocked: hasVeryRareOrHigher),
            Achievement(id: "legend_hunter", title: "Legend Hunter", icon: "crown.fill", isUnlocked: hasLegendary),
            Achievement(id: "connoisseur", title: "True Connoisseur", icon: "trophy.fill", isUnlocked: tried.count >= 30),
        ]
    }
}
