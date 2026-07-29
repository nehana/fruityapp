import SwiftUI
import SwiftData

struct PassportView: View {
    @Query(sort: \LoggedFruit.dateTried, order: .reverse) private var logged: [LoggedFruit]

    // MVP: hardcoded local display name. Could become a @AppStorage setting later.
    @AppStorage("fruityUsername") private var username: String = "Fruit Friend"

    @State private var renderedImage: Image?
    @State private var showCopiedToast = false
    @State private var showSettings = false

    private var stats: PassportStats {
        PersonaEngine.stats(logged: logged)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    PassportCardView(stats: stats, username: username)
                        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
                        .padding(.top, 8)

                    if let nextTier = stats.nextTier {
                        VStack(spacing: 6) {
                            Text("\(stats.xpToNextTier) XP to become a \(nextTier.title)")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(.secondary)
                            Text("Rarer fruits earn more XP ✨")
                                .font(.caption2)
                                .foregroundStyle(.secondary.opacity(0.8))
                            ProgressView(value: progressToNextTier)
                                .tint(FruityTheme.primary)
                                .padding(.horizontal, 32)
                        }
                    } else {
                        Text("You've reached the top tier — Fruit Legend! 👑")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 12) {
                        ShareLink(
                            item: renderedCardImage(),
                            preview: SharePreview("My Fruity Passport", image: renderedCardImage())
                        ) {
                            Label("Share Card", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(FruityTheme.primary)

                        Button {
                            copyAsText()
                        } label: {
                            Label("Copy as Text", systemImage: "doc.on.doc")
                        }
                        .buttonStyle(.bordered)
                    }

                    if showCopiedToast {
                        Text("Copied to clipboard ✅")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .transition(.opacity)
                    }

                    if !logged.isEmpty {
                        topPickSection
                        achievementsSection
                        recentSection
                    }
                }
                .padding()
            }
            .fruityBackground()
            .navigationTitle("Passport")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    private var topPickSection: some View {
        Group {
            if let topEntry = logged.min(by: { $0.rankIndex < $1.rankIndex }),
               let topFruit = FruitCatalog.find(topEntry.fruitId) {
                HStack(spacing: 12) {
                    Text("👑")
                        .font(.system(size: 28))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Your #1 Fruit")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(topFruit.name)
                            .font(.headline)
                    }
                    Spacer()
                    let favoritesCount = logged.filter(\.isFavorite).count
                    if favoritesCount > 0 {
                        VStack(spacing: 2) {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(FruityTheme.primary)
                            Text("\(favoritesCount)")
                                .font(.caption.weight(.semibold))
                        }
                    }
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Achievements")
                .font(.headline)
                .padding(.leading, 4)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 78))], spacing: 12) {
                ForEach(AchievementEngine.achievements(for: logged)) { badge in
                    VStack(spacing: 6) {
                        Image(systemName: badge.icon)
                            .font(.title2)
                            .frame(width: 52, height: 52)
                            .background(
                                badge.isUnlocked ? FruityTheme.cardGradient : LinearGradient(colors: [.gray.opacity(0.2)], startPoint: .top, endPoint: .bottom),
                                in: Circle()
                            )
                            .foregroundStyle(badge.isUnlocked ? .white : .secondary)
                        Text(badge.title)
                            .font(.caption2.weight(.medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(badge.isUnlocked ? .primary : .secondary)
                    }
                    .opacity(badge.isUnlocked ? 1 : 0.5)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recently Tried")
                .font(.headline)
                .padding(.leading, 4)

            ForEach(logged.prefix(5)) { entry in
                if let fruit = FruitCatalog.find(entry.fruitId) {
                    FruitRowView(fruit: fruit, isTried: true, subtitle: entry.dateTried.formatted(date: .abbreviated, time: .omitted))
                        .padding(.horizontal, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var progressToNextTier: Double {
        guard let next = stats.nextTier else { return 1 }
        let currentMin = stats.tier.minXP
        let span = max(next.minXP - currentMin, 1)
        return Double(stats.totalXP - currentMin) / Double(span)
    }

    /// Renders the passport card to a static Image for ShareLink.
    /// For true "copy image" support, wrap this in a UIActivityViewController
    /// via UIViewControllerRepresentable if you want the OS copy-image action too.
    private func renderedCardImage() -> Image {
        let renderer = ImageRenderer(content: PassportCardView(stats: stats, username: username))
        renderer.scale = UIScreen.main.scale
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "photo")
    }

    private func copyAsText() {
        let text = """
        🍓 \(username)'s Fruity Passport
        \(stats.tier.avatarEmoji) \(stats.tier.title) (\(stats.totalXP) XP)
        Fruits tried: \(stats.totalTried)
        Countries: \(stats.uniqueCountries) · Regions: \(stats.uniqueRegions)
        """
        UIPasteboard.general.string = text
        withAnimation { showCopiedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation { showCopiedToast = false }
        }
    }
}
