import Foundation
import Observation

/// Drives a Beli-style "which did you like better?" comparison flow to insert
/// a newly logged fruit into the user's personal ranked list via binary search.
/// Runs entirely locally, no backend needed — O(log n) comparisons instead of
/// comparing against every fruit, so even a big list only takes a handful of taps.
@Observable
final class RankingSession {
    let newFruit: Fruit

    /// Existing ranked entries, best (index 0) to worst. Does NOT include the new entry.
    private let rankedOthers: [LoggedFruit]
    private let rankedOtherFruits: [Fruit]

    private var lo: Int
    private var hi: Int

    private(set) var comparisonsMade = 0

    init(newFruit: Fruit, existingRankedBestFirst: [LoggedFruit]) {
        self.newFruit = newFruit
        self.rankedOthers = existingRankedBestFirst
        self.rankedOtherFruits = existingRankedBestFirst.compactMap { FruitCatalog.find($0.fruitId) }
        self.lo = 0
        self.hi = existingRankedBestFirst.count
    }

    var isResolved: Bool { lo >= hi }

    private var comparisonIndex: Int? {
        guard !isResolved, hi <= rankedOtherFruits.count else { return nil }
        return (lo + hi) / 2
    }

    var currentComparisonFruit: Fruit? {
        guard let idx = comparisonIndex else { return nil }
        return rankedOtherFruits[idx]
    }

    /// Rough "Round X of ~Y" estimate for progress display.
    var estimatedTotalComparisons: Int {
        max(1, Int(ceil(log2(Double(rankedOthers.count + 1)))))
    }

    /// User preferred the new fruit over the current comparison fruit.
    func chooseNewFruitBetter() {
        guard let idx = comparisonIndex else { return }
        hi = idx
        comparisonsMade += 1
    }

    /// User preferred the already-ranked fruit.
    func chooseExistingFruitBetter() {
        guard let idx = comparisonIndex else { return }
        lo = idx + 1
        comparisonsMade += 1
    }

    /// Final 0-based insertion position among rankedOthers (0 = new best-ever fruit).
    var finalPosition: Int { lo }

    /// Applies the resolved position: inserts the new entry into the ranked
    /// order and reassigns sequential rankIndex values to everyone affected.
    func applyRanking(newEntry: LoggedFruit) {
        var items = rankedOthers
        items.insert(newEntry, at: finalPosition)
        for (index, item) in items.enumerated() {
            item.rankIndex = index
        }
    }
}
