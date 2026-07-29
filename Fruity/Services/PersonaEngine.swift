import Foundation

/// The passport "level" — drives the avatar and title shown on the Passport tab.
/// Progression is XP-based rather than a raw fruit count, so trying rarer
/// fruits advances you faster than logging the same common ones repeatedly.
enum PersonaTier: Int, CaseIterable {
    case seedling = 0
    case explorer = 1
    case adventurer = 2
    case connoisseur = 3
    case legend = 4

    /// Minimum XP required to reach this tier.
    var minXP: Int {
        switch self {
        case .seedling: return 0
        case .explorer: return 120
        case .adventurer: return 350
        case .connoisseur: return 700
        case .legend: return 1300
        }
    }

    var title: String {
        switch self {
        case .seedling: return "Fruit Curious"
        case .explorer: return "Fruit Explorer"
        case .adventurer: return "Fruit Adventurer"
        case .connoisseur: return "Fruit Connoisseur"
        case .legend: return "Fruit Legend"
        }
    }

    var avatarEmoji: String {
        switch self {
        case .seedling: return "🌱"
        case .explorer: return "🧭"
        case .adventurer: return "🌍"
        case .connoisseur: return "🍽️"
        case .legend: return "👑"
        }
    }
}

struct PassportStats {
    let totalTried: Int
    let totalXP: Int
    let uniqueCountries: Int
    let uniqueRegions: Int
    let averageRarity: Double
    let tier: PersonaTier
    let nextTier: PersonaTier?
    let xpToNextTier: Int
}

enum PersonaEngine {
    static func stats(logged: [LoggedFruit], catalog: [Fruit] = FruitCatalog.all) -> PassportStats {
        let fruitsById = Dictionary(uniqueKeysWithValues: catalog.map { ($0.id, $0) })
        let triedFruits = logged.compactMap { fruitsById[$0.fruitId] }

        let uniqueCountries = Set(triedFruits.map(\.country)).count
        let uniqueRegions = Set(triedFruits.map(\.region)).count
        let avgRarity = triedFruits.isEmpty
            ? 0
            : Double(triedFruits.reduce(0) { $0 + $1.rarity.rawValue }) / Double(triedFruits.count)

        let totalXP = triedFruits.reduce(0) { $0 + $1.rarity.xpValue }
        let tier = PersonaTier.allCases.last { totalXP >= $0.minXP } ?? .seedling
        let nextTier = PersonaTier.allCases.first { $0.minXP > totalXP }
        let xpToNext = nextTier.map { $0.minXP - totalXP } ?? 0

        return PassportStats(
            totalTried: logged.count,
            totalXP: totalXP,
            uniqueCountries: uniqueCountries,
            uniqueRegions: uniqueRegions,
            averageRarity: avgRarity,
            tier: tier,
            nextTier: nextTier,
            xpToNextTier: xpToNext
        )
    }
}
