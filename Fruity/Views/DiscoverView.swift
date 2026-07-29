import SwiftUI
import SwiftData

struct DiscoverView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var logged: [LoggedFruit]
    @Query private var wantToTryList: [WantToTryFruit]

    @State private var searchText = ""
    @State private var selectedRegion: Region?
    @State private var hideAlreadyTried = false
    @State private var wishlistOnly = false

    private var triedFruitIds: Set<String> {
        Set(logged.map(\.fruitId))
    }

    private var wishlistFruitIds: Set<String> {
        Set(wantToTryList.map(\.fruitId))
    }

    private var filteredFruits: [Fruit] {
        FruitCatalog.all
            .filter { fruit in
                (selectedRegion == nil || fruit.region == selectedRegion)
                && (searchText.isEmpty
                    || fruit.name.localizedCaseInsensitiveContains(searchText)
                    || fruit.country.localizedCaseInsensitiveContains(searchText))
                && (!hideAlreadyTried || !triedFruitIds.contains(fruit.id))
                && (!wishlistOnly || wishlistFruitIds.contains(fruit.id))
            }
            .sorted { $0.rarity.rawValue > $1.rarity.rawValue }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            regionChip(nil, label: "All")
                            ForEach(Region.allCases) { region in
                                regionChip(region, label: region.rawValue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    Toggle("Hide fruits I've already tried", isOn: $hideAlreadyTried)
                        .font(.footnote)
                    Toggle("Show only my wishlist 🔖", isOn: $wishlistOnly)
                        .font(.footnote)
                }
                .listRowSeparator(.hidden)

                ForEach(filteredFruits) { fruit in
                    NavigationLink(value: fruit) {
                        FruitRowView(
                            fruit: fruit,
                            isTried: triedFruitIds.contains(fruit.id),
                            isWantToTry: wishlistFruitIds.contains(fruit.id)
                        )
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            toggleWishlist(fruit)
                        } label: {
                            Label(
                                wishlistFruitIds.contains(fruit.id) ? "Remove" : "Want to Try",
                                systemImage: wishlistFruitIds.contains(fruit.id) ? "bookmark.slash.fill" : "bookmark.fill"
                            )
                        }
                        .tint(FruityTheme.accent)
                    }
                }
            }
            .listStyle(.plain)
            .fruityBackground()
            .searchable(text: $searchText, prompt: "Search fruits or countries")
            .navigationTitle("Discover")
            .navigationDestination(for: Fruit.self) { fruit in
                FruitDetailView(fruit: fruit, existingEntry: existingEntry(for: fruit))
            }
        }
    }

    private func existingEntry(for fruit: Fruit) -> LoggedFruit? {
        logged.first { $0.fruitId == fruit.id }
    }

    private func toggleWishlist(_ fruit: Fruit) {
        if let entry = wantToTryList.first(where: { $0.fruitId == fruit.id }) {
            modelContext.delete(entry)
        } else {
            modelContext.insert(WantToTryFruit(fruitId: fruit.id))
        }
    }

    private func regionChip(_ region: Region?, label: String) -> some View {
        let isSelected = selectedRegion == region
        return Text(label)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? AnyShapeStyle(FruityTheme.cardGradient) : AnyShapeStyle(FruityTheme.primary.opacity(0.12)), in: Capsule())
            .foregroundStyle(isSelected ? .white : FruityTheme.primary)
            .onTapGesture { selectedRegion = region }
    }
}
