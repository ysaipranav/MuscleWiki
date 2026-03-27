import SwiftUI
import CoreSpotlight

struct ContentView: View {
    @Environment(ExerciseStore.self) private var store
    @State private var selectedTab: Tab = .exercises
    @State private var spotlightExerciseID: Int?
    @State private var networkMonitor = NetworkMonitor.shared

    enum Tab: Hashable {
        case exercises, browse, favorites
    }

    var body: some View {
        ZStack(alignment: .top) {
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

            // Offline banner — slides in from top when disconnected
            if !networkMonitor.isConnected {
                OfflineBanner()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.spring(response: 0.35), value: networkMonitor.isConnected)
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

struct OfflineBanner: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
            Text("No internet connection · Exercise data still available")
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.9))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Offline. Exercise data is still available but videos require a connection.")
    }
}
