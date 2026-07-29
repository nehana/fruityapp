import SwiftUI
import SwiftData

struct FruitDetailView: View {
    let fruit: Fruit
    var existingEntry: LoggedFruit? = nil

    @Environment(\.modelContext) private var modelContext
    @Query private var wantToTryList: [WantToTryFruit]
    @State private var showLogSheet = false

    private var isWantToTry: Bool {
        wantToTryList.contains { $0.fruitId == fruit.id }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    FruitIconView(fruit: fruit, diameter: 140, emojiSize: 90)
                    Spacer()
                }
                .padding(.top, 12)

                VStack(alignment: .leading, spacing: 6) {
                    Text(fruit.name)
                        .font(.largeTitle.bold())
                    Text(fruit.scientificName)
                        .font(.subheadline)
                        .italic()
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 10) {
                    Label(fruit.country, systemImage: "mappin.and.ellipse")
                    Label(fruit.region.rawValue, systemImage: "globe")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)

                RarityBadge(rarity: fruit.rarity)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Flavor Notes")
                        .font(.headline)
                    HStack {
                        ForEach(fruit.flavorNotes, id: \.self) { note in
                            Text(note)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(.thinMaterial, in: Capsule())
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("History & Uses")
                        .font(.headline)
                    Text(fruit.history)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Fun Fact")
                        .font(.headline)
                    Text(fruit.funFact)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                if let existingEntry {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Text("Your Entry")
                                .font(.headline)
                            if existingEntry.isFavorite {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(FruityTheme.primary)
                                    .font(.caption)
                            }
                        }
                        if existingEntry.rating > 0 {
                            Text(String(repeating: "★", count: existingEntry.rating))
                                .foregroundStyle(FruityTheme.secondary)
                        }
                        if !existingEntry.tags.isEmpty {
                            HStack {
                                ForEach(existingEntry.tags, id: \.self) { tag in
                                    Text(tag.rawValue)
                                        .font(.caption2.weight(.medium))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(FruityTheme.accent.opacity(0.15), in: Capsule())
                                        .foregroundStyle(FruityTheme.accent)
                                }
                            }
                        }
                        Label(
                            existingEntry.wouldTryAgain ? "Would try again" : "Wouldn't try again",
                            systemImage: existingEntry.wouldTryAgain ? "hand.thumbsup.fill" : "hand.thumbsdown.fill"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        if !existingEntry.notes.isEmpty {
                            Text(existingEntry.notes)
                                .foregroundStyle(.secondary)
                        }
                        Text("Tried on \(existingEntry.dateTried.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }

                Button {
                    showLogSheet = true
                } label: {
                    Label(existingEntry != nil ? "Edit My Entry" : "Log This Fruit", systemImage: existingEntry != nil ? "pencil" : "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(FruityTheme.primary)
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if existingEntry == nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        toggleWishlist()
                    } label: {
                        Image(systemName: isWantToTry ? "bookmark.fill" : "bookmark")
                    }
                }
            }
        }
        .sheet(isPresented: $showLogSheet) {
            LogFruitView(fruit: fruit, existingEntry: existingEntry)
        }
    }

    private func toggleWishlist() {
        if let entry = wantToTryList.first(where: { $0.fruitId == fruit.id }) {
            modelContext.delete(entry)
        } else {
            modelContext.insert(WantToTryFruit(fruitId: fruit.id))
        }
    }
}
