import SwiftUI
import SwiftData

/// Handles two cases:
/// 1. `fruit` is nil — user taps + on My Fruits, must first pick which fruit
/// 2. `fruit` is provided — user tapped "Log this fruit" from Discover/Detail
///
/// After saving a brand-new entry (not an edit), this walks the user through
/// a quick pairwise ranking flow before celebrating and dismissing.
struct LogFruitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var logged: [LoggedFruit]
    @Query private var wantToTryList: [WantToTryFruit]

    let fruit: Fruit?
    var existingEntry: LoggedFruit? = nil

    private enum Stage { case form, ranking, celebrate }

    @State private var stage: Stage = .form
    @State private var selectedFruit: Fruit?
    @State private var dateTried: Date = .now
    @State private var rating: Int = 0
    @State private var notes: String = ""
    @State private var placeTried: String = ""
    @State private var isFavorite: Bool = false
    @State private var wouldTryAgain: Bool = true
    @State private var selectedTags: Set<FruitTag> = []
    @State private var searchText: String = ""
    @State private var showConfetti = false

    @State private var rankingSession: RankingSession?
    @State private var pendingEntry: LoggedFruit?
    @State private var finalRankDisplay = 1
    @State private var totalRankedCount = 1
    @State private var xpEarned = 0

    init(fruit: Fruit?, existingEntry: LoggedFruit? = nil) {
        self.fruit = fruit
        self.existingEntry = existingEntry
        _selectedFruit = State(initialValue: fruit)
    }

    private var filteredCatalog: [Fruit] {
        guard !searchText.isEmpty else { return FruitCatalog.all }
        return FruitCatalog.all.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                switch stage {
                case .form: formView
                case .ranking: rankingView
                case .celebrate: celebrateView
                }
            }
            .overlay(ConfettiView(trigger: $showConfetti))
            .navigationTitle(navigationTitleText)
            .toolbar {
                if stage == .form {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { save() }
                            .disabled(selectedFruit == nil)
                    }
                }
            }
            .onAppear(perform: prefillIfEditing)
        }
        .interactiveDismissDisabled(stage != .form)
    }

    private var navigationTitleText: String {
        switch stage {
        case .form: return existingEntry != nil ? "Edit Entry" : "Log a Fruit"
        case .ranking: return "Rank It"
        case .celebrate: return "Nice!"
        }
    }

    // MARK: - Form stage

    private var formView: some View {
        Form {
            if selectedFruit == nil {
                Section("Which fruit did you try?") {
                    TextField("Search fruits", text: $searchText)
                    ForEach(filteredCatalog) { candidate in
                        Button {
                            selectedFruit = candidate
                        } label: {
                            FruitRowView(fruit: candidate)
                        }
                        .tint(.primary)
                    }
                }
            } else if let selected = selectedFruit {
                Section {
                    FruitRowView(fruit: selected)
                    if fruit == nil {
                        Button("Choose a different fruit", role: .destructive) {
                            selectedFruit = nil
                        }
                    }
                }

                Section("Details") {
                    DatePicker("Date tried", selection: $dateTried, displayedComponents: .date)
                    TextField("Where? (e.g. Bangkok market)", text: $placeTried)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rating")
                        StarRatingView(rating: $rating)
                    }
                    Toggle("⭐️ Mark as a favorite", isOn: $isFavorite)
                    Toggle("Would try again", isOn: $wouldTryAgain)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(FruitTag.allCases, id: \.self) { tag in
                            tagChip(tag)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("How was it?")
                }

                if existingEntry == nil {
                    Section {
                        Label("\(selected.rarity.label) fruits earn more XP toward your next tier.", systemImage: "sparkles")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func tagChip(_ tag: FruitTag) -> some View {
        let isSelected = selectedTags.contains(tag)
        return Text(tag.rawValue)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(isSelected ? AnyShapeStyle(FruityTheme.cardGradient) : AnyShapeStyle(Color.gray.opacity(0.15)), in: Capsule())
            .foregroundStyle(isSelected ? .white : .primary)
            .onTapGesture {
                if isSelected { selectedTags.remove(tag) } else { selectedTags.insert(tag) }
            }
    }

    // MARK: - Ranking stage

    private var rankingView: some View {
        VStack(spacing: 20) {
            Spacer()

            if let session = rankingSession {
                Text("Which did you enjoy more?")
                    .font(.title3.bold())
                Text("Round \(session.comparisonsMade + 1) of ~\(session.estimatedTotalComparisons)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                VStack(spacing: 14) {
                    comparisonButton(fruit: session.newFruit, isNew: true) {
                        session.chooseNewFruitBetter()
                        checkIfResolved()
                    }

                    Text("vs")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)

                    if let existingFruit = session.currentComparisonFruit {
                        comparisonButton(fruit: existingFruit, isNew: false) {
                            session.chooseExistingFruitBetter()
                            checkIfResolved()
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
    }

    private func comparisonButton(fruit: Fruit, isNew: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                FruitIconView(fruit: fruit, diameter: 48, emojiSize: 32)
                VStack(alignment: .leading, spacing: 2) {
                    if isNew {
                        Text("NEW")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(FruityTheme.primary)
                    }
                    Text(fruit.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(
                isNew ? FruityTheme.primary.opacity(0.1) : Color.gray.opacity(0.08),
                in: RoundedRectangle(cornerRadius: 16)
            )
        }
        .buttonStyle(.plain)
    }

    private func checkIfResolved() {
        guard let session = rankingSession, let entry = pendingEntry else { return }
        if session.isResolved {
            session.applyRanking(newEntry: entry)
            finalRankDisplay = session.finalPosition + 1
            totalRankedCount = logged.count + 1
            triggerCelebration()
        }
    }

    // MARK: - Celebrate stage

    private var celebrateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(selectedFruit?.emoji ?? "🎉")
                .font(.system(size: 64))
            Text("Logged!")
                .font(.title2.bold())
            if totalRankedCount > 1 {
                Text("Ranked #\(finalRankDisplay) of \(totalRankedCount) in your passport")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text("+\(xpEarned) XP")
                .font(.headline)
                .foregroundStyle(FruityTheme.secondary)
            Spacer()
        }
        .padding()
    }

    // MARK: - Save flow

    private func prefillIfEditing() {
        guard let existingEntry else { return }
        dateTried = existingEntry.dateTried
        rating = existingEntry.rating
        notes = existingEntry.notes
        placeTried = existingEntry.placeTried
        isFavorite = existingEntry.isFavorite
        wouldTryAgain = existingEntry.wouldTryAgain
        selectedTags = Set(existingEntry.tags)
    }

    private func save() {
        guard let selectedFruit else { return }

        if let existingEntry {
            existingEntry.dateTried = dateTried
            existingEntry.rating = rating
            existingEntry.notes = notes
            existingEntry.placeTried = placeTried
            existingEntry.isFavorite = isFavorite
            existingEntry.wouldTryAgain = wouldTryAgain
            existingEntry.tags = Array(selectedTags)
            dismiss()
            return
        }

        // Snapshot the current ranked order BEFORE inserting the new entry,
        // so the ranking session compares against a stable list.
        let rankedOthers = logged.sorted { $0.rankIndex < $1.rankIndex }

        let entry = LoggedFruit(
            fruitId: selectedFruit.id,
            dateTried: dateTried,
            rating: rating,
            notes: notes,
            placeTried: placeTried,
            isFavorite: isFavorite,
            wouldTryAgain: wouldTryAgain,
            tags: Array(selectedTags),
            rankIndex: rankedOthers.count
        )
        modelContext.insert(entry)
        pendingEntry = entry
        xpEarned = selectedFruit.rarity.xpValue

        if let wishlistEntry = wantToTryList.first(where: { $0.fruitId == selectedFruit.id }) {
            modelContext.delete(wishlistEntry)
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)

        if rankedOthers.isEmpty {
            finalRankDisplay = 1
            totalRankedCount = 1
            triggerCelebration()
        } else {
            rankingSession = RankingSession(newFruit: selectedFruit, existingRankedBestFirst: rankedOthers)
            withAnimation { stage = .ranking }
        }
    }

    private func triggerCelebration() {
        withAnimation { stage = .celebrate }
        withAnimation { showConfetti = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            dismiss()
        }
    }
}
