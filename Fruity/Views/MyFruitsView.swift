import SwiftUI
import SwiftData

struct MyFruitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LoggedFruit.dateTried, order: .reverse) private var logged: [LoggedFruit]

    @State private var showLogSheet = false
    @State private var viewMode: ViewMode = .timeline

    enum ViewMode: String, CaseIterable {
        case timeline = "Timeline"
        case ranked = "Ranked"
    }

    private var sortedByRank: [LoggedFruit] {
        logged.sorted { $0.rankIndex < $1.rankIndex }
    }

    var body: some View {
        NavigationStack {
            Group {
                if logged.isEmpty {
                    ContentUnavailableView(
                        "Your passport is empty",
                        systemImage: "leaf",
                        description: Text("Tap + and log the first exotic fruit you've tried — every passport starts with one bite 🍓")
                    )
                } else {
                    VStack(spacing: 0) {
                        Picker("View", selection: $viewMode) {
                            ForEach(ViewMode.allCases, id: \.self) { Text($0.rawValue) }
                        }
                        .pickerStyle(.segmented)
                        .padding()

                        if viewMode == .timeline {
                            timelineList
                        } else {
                            rankedList
                        }
                    }
                    .fruityBackground()
                }
            }
            .navigationTitle("My Fruits")
            .navigationDestination(for: LoggedFruit.self) { entry in
                if let fruit = FruitCatalog.find(entry.fruitId) {
                    FruitDetailView(fruit: fruit, existingEntry: entry)
                }
            }
            .toolbar {
                if viewMode == .ranked && !logged.isEmpty {
                    ToolbarItem(placement: .topBarLeading) { EditButton() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showLogSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showLogSheet) {
                LogFruitView(fruit: nil)
            }
        }
    }

    private var timelineList: some View {
        List {
            ForEach(logged) { entry in
                if let fruit = FruitCatalog.find(entry.fruitId) {
                    NavigationLink(value: entry) {
                        FruitRowView(
                            fruit: fruit,
                            isTried: true,
                            isFavorite: entry.isFavorite,
                            subtitle: rowSubtitle(for: entry)
                        )
                    }
                }
            }
            .onDelete(perform: deleteFromTimeline)
        }
        .listStyle(.plain)
    }

    private var rankedList: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Drag to reorder — your #1 is your best exotic fruit ever.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            List {
                ForEach(Array(sortedByRank.enumerated()), id: \.element.id) { index, entry in
                    if let fruit = FruitCatalog.find(entry.fruitId) {
                        NavigationLink(value: entry) {
                            FruitRowView(
                                fruit: fruit,
                                isTried: true,
                                isFavorite: entry.isFavorite,
                                subtitle: rowSubtitle(for: entry),
                                rankNumber: index + 1
                            )
                        }
                    }
                }
                .onMove(perform: moveRanked)
            }
            .listStyle(.plain)
        }
    }

    private func rowSubtitle(for entry: LoggedFruit) -> String {
        var parts = [entry.dateTried.formatted(date: .abbreviated, time: .omitted)]
        if entry.rating > 0 {
            parts.append(String(repeating: "★", count: entry.rating))
        }
        return parts.joined(separator: " · ")
    }

    private func deleteFromTimeline(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(logged[index])
        }
    }

    private func moveRanked(from source: IndexSet, to destination: Int) {
        var items = sortedByRank
        items.move(fromOffsets: source, toOffset: destination)
        for (index, item) in items.enumerated() {
            item.rankIndex = index
        }
    }
}
