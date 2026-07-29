import Foundation
import SwiftData

/// A fruit the user has bookmarked to try later — a "want to read" shelf,
/// not a completed log entry. Separate from LoggedFruit so Discover can
/// track intent to try without implying it's been eaten yet.
@Model
final class WantToTryFruit {
    var id: UUID
    var fruitId: String
    var dateAdded: Date

    init(fruitId: String, dateAdded: Date = .now) {
        self.id = UUID()
        self.fruitId = fruitId
        self.dateAdded = dateAdded
    }
}
