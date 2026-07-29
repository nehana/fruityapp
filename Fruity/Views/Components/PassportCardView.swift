import SwiftUI

/// The visual "passport card" — shown inline on the Passport tab, and also
/// rendered to a UIImage for sharing/copying via ImageRenderer.
struct PassportCardView: View {
    let stats: PassportStats
    let username: String

    var body: some View {
        VStack(spacing: 16) {
            Text(stats.tier.avatarEmoji)
                .font(.system(size: 64))
                .frame(width: 110, height: 110)
                .background(.white.opacity(0.18), in: Circle())

            VStack(spacing: 4) {
                Text(username)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                Text(stats.tier.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
                Text("\(stats.totalXP) XP")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
            }

            HStack(spacing: 24) {
                statBlock(value: "\(stats.totalTried)", label: "Fruits")
                statBlock(value: "\(stats.uniqueCountries)", label: "Countries")
                statBlock(value: "\(stats.uniqueRegions)", label: "Regions")
            }

            Text("🍓 Fruity Passport")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(28)
        .frame(width: 320)
        .background(
            LinearGradient(
                colors: [FruityTheme.primary, FruityTheme.secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.75))
        }
    }
}
