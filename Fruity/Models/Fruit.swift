import Foundation

/// Geographic region used for grouping, filtering, and diversity scoring.
enum Region: String, Codable, CaseIterable, Identifiable {
    case southeastAsia = "Southeast Asia"
    case southAsia = "South Asia"
    case eastAsia = "East Asia"
    case centralAmerica = "Central America"
    case southAmerica = "South America"
    case caribbean = "Caribbean"
    case africa = "Africa"
    case oceania = "Oceania"

    var id: String { rawValue }
}

/// How hard a fruit is to find/try. Drives the rarity stars + passport score.
enum Rarity: Int, Codable, CaseIterable, Comparable {
    case common = 1
    case uncommon = 2
    case rare = 3
    case veryRare = 4
    case legendary = 5

    static func < (lhs: Rarity, rhs: Rarity) -> Bool { lhs.rawValue < rhs.rawValue }

    var label: String {
        switch self {
        case .common: return "Common"
        case .uncommon: return "Uncommon"
        case .rare: return "Rare"
        case .veryRare: return "Very Rare"
        case .legendary: return "Legendary"
        }
    }

    /// XP awarded toward the passport tier when this rarity is logged.
    /// Deliberately non-linear so hunting rare fruits meaningfully outpaces
    /// just logging a lot of common ones.
    var xpValue: Int {
        switch self {
        case .common: return 10
        case .uncommon: return 20
        case .rare: return 35
        case .veryRare: return 55
        case .legendary: return 80
        }
    }

    var stars: String { String(repeating: "⭐️", count: rawValue) }
}

/// Static reference data — the "menu" of exotic fruits. Not user data, so it's
/// just a plain Codable struct rather than a SwiftData model.
struct Fruit: Identifiable, Codable, Hashable {
    let id: String              // stable slug, e.g. "rambutan"
    let name: String
    let scientificName: String
    let emoji: String           // icon shown everywhere today
    let imageAssetName: String? // optional real photo — add to Assets.xcassets and set this to swap in later; nil = fall back to emoji
    let country: String         // primary country of origin
    let region: Region
    let flavorNotes: [String]
    let rarity: Rarity
    let history: String         // origin story / traditional uses
    let funFact: String         // short, punchy trivia line

    /// Convenience so views don't need to check imageAssetName == nil everywhere.
    var hasRealPhoto: Bool { imageAssetName != nil }
}
