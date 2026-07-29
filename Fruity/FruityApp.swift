import SwiftUI
import SwiftData

@main
struct FruityApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [LoggedFruit.self, WantToTryFruit.self])
    }
}
