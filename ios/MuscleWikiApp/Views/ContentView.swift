import SwiftUI
import CoreSpotlight

struct ContentView: View {
    @Environment(ExerciseStore.self) private var store
    @State private var selectedTab: Tab = .exercises
    @State private var spotlightExerciseID: Int?

    enum Tab: Hashable {
        case exercises, browse, favorites
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ExerciseListView()
                .tabItem {
                    Label("Exercises", systemImage: "list.bullet.rectangle")
                }
                .tag(Tab.exercises)

            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "figure.walk")
                }
                .tag(Tab.browse)

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
                .tag(Tab.favorites)
        }
        .tint(.appAccent)
        // Handle Spotlight deep links
        .onContinueUserActivity(CSSearchableItemActionType) { activity in
            if let id = SpotlightService.exerciseID(from: activity),
               let exercise = store.exercise(withID: id) {
                selectedTab = .exercises
                spotlightExerciseID = exercise.id
            }
        }
    }
}
