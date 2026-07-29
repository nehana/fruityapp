import SwiftUI

/// Shows the fruit's real photo if one has been added to Assets.xcassets,
/// otherwise falls back to the emoji icon. Swap in photos anytime by setting
/// `imageAssetName` on the Fruit entry in FruitCatalog.swift — no view code changes needed.
struct FruitIconView: View {
    let fruit: Fruit
    var diameter: CGFloat = 48
    var emojiSize: CGFloat = 34

    var body: some View {
        Group {
            if let assetName = fruit.imageAssetName {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(fruit.emoji)
                    .font(.system(size: emojiSize))
            }
        }
        .frame(width: diameter, height: diameter)
        .background(FruityTheme.secondary.opacity(0.15), in: Circle())
        .clipShape(Circle())
    }
}

/// Small pill showing rarity stars + label, color-coded by tier so rare
/// finds visually stand out instead of looking the same as common ones.
struct RarityBadge: View {
    let rarity: Rarity

    var body: some View {
        Text("\(rarity.stars) \(rarity.label)")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(FruityTheme.rarityColor(rarity))
            .background(FruityTheme.rarityColor(rarity).opacity(0.15), in: Capsule())
    }
}

/// A single row in a fruit list — used in Discover, My Fruits, and Rankings.
struct FruitRowView: View {
    let fruit: Fruit
    var isTried: Bool = false
    var isFavorite: Bool = false
    var isWantToTry: Bool = false
    var subtitle: String? = nil
    var rankNumber: Int? = nil

    var body: some View {
        HStack(spacing: 12) {
            if let rankNumber {
                Text("#\(rankNumber)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(FruityTheme.primary)
                    .frame(width: 28)
            }

            FruitIconView(fruit: fruit, diameter: 48, emojiSize: 34)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(fruit.name)
                        .font(.headline)
                    if isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(FruityTheme.primary)
                            .font(.caption)
                    }
                    if isTried {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                    if isWantToTry {
                        Image(systemName: "bookmark.fill")
                            .foregroundStyle(FruityTheme.accent)
                            .font(.caption)
                    }
                }
                Text(subtitle ?? "\(fruit.country) · \(fruit.region.rawValue)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            RarityBadge(rarity: fruit.rarity)
        }
        .padding(.vertical, 4)
    }
}

/// Tappable 1-5 star rating control used in LogFruitView.
struct StarRatingView: View {
    @Binding var rating: Int
    var maxRating: Int = 5

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundStyle(FruityTheme.secondary)
                    .font(.title2)
                    .onTapGesture {
                        rating = (rating == star) ? 0 : star
                    }
            }
        }
    }
}
