import Foundation
import SwiftData

/// Quick-tap flavor/experience tags — richer signal than a star rating alone,
/// and gives sharing more substance ("creamy, instant favorite" says more than "4 stars").
enum FruitTag: String, Codable, CaseIterable {
    case sweet = "Sweet"
    case tart = "Tart"
    case creamy = "Creamy"
    case crunchy = "Crunchy"
    case juicy = "Juicy"
    case funky = "Funky"
    case messy = "Messy to Eat"
    case acquiredTaste = "Acquired Taste"
    case instantFavorite = "Instant Favorite"
}

/// A single entry in the user's personal fruit passport.
/// This is the ONLY thing that needs to persist locally — everything else
/// (the Fruit catalog) is static reference data bundled with the app.
@Model
final class LoggedFruit {
    var id: UUID
    var fruitId: String       // references Fruit.id in the static catalog
    var dateTried: Date
    var rating: Int           // 0 = unrated, 1-5 stars
    var notes: String
    var placeTried: String    // e.g. "street market in Bangkok" — may differ from country of origin
    var isFavorite: Bool
    var wouldTryAgain: Bool
    var tagRawValues: [String] // stored as raw strings for SwiftData compatibility
    var rankIndex: Int         // position in the user's personal drag-to-rank list; lower = better

    var tags: [FruitTag] {
        get { tagRawValues.compactMap(FruitTag.init) }
        set { tagRawValues = newValue.map(\.rawValue) }
    }

    init(
        fruitId: String,
        dateTried: Date = .now,
        rating: Int = 0,
        notes: String = "",
        placeTried: String = "",
        isFavorite: Bool = false,
        wouldTryAgain: Bool = true,
        tags: [FruitTag] = [],
        rankIndex: Int = 0
    ) {
        self.id = UUID()
        self.fruitId = fruitId
        self.dateTried = dateTried
        self.rating = rating
        self.notes = notes
        self.placeTried = placeTried
        self.isFavorite = isFavorite
        self.wouldTryAgain = wouldTryAgain
        self.tagRawValues = tags.map(\.rawValue)
        self.rankIndex = rankIndex
    }
}
