import SwiftUI

/// Central place for Fruity's visual identity. Change values here to
/// re-theme the whole app instead of hunting through every view.
enum FruityTheme {
    static let primary = Color(red: 0.94, green: 0.38, blue: 0.30)     // coral
    static let secondary = Color(red: 0.98, green: 0.66, blue: 0.24)   // mango
    static let accent = Color(red: 0.11, green: 0.42, blue: 0.40)      // deep teal
    static let background = Color(red: 0.99, green: 0.97, blue: 0.92)  // warm cream

    static let cardGradient = LinearGradient(
        colors: [primary, secondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func rarityColor(_ rarity: Rarity) -> Color {
        switch rarity {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .veryRare: return .purple
        case .legendary: return secondary
        }
    }
}

extension View {
    /// Consistent warm background for scrollable screens.
    func fruityBackground() -> some View {
        self.scrollContentBackground(.hidden)
            .background(FruityTheme.background)
    }
}
