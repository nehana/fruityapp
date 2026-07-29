import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PassportView()
                .tabItem { Label("Passport", systemImage: "person.crop.circle.fill") }

            MyFruitsView()
                .tabItem { Label("My Fruits", systemImage: "checklist") }

            DiscoverView()
                .tabItem { Label("Discover", systemImage: "map.fill") }
        }
        .tint(FruityTheme.primary)
        .fontDesign(.rounded)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: LoggedFruit.self, inMemory: true)
}
