import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(ExerciseStore.self) private var store
    @Query(sort: \FavoriteExercise.savedAt, order: .reverse) private var favorites: [FavoriteExercise]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    emptyState
                } else {
                    favoritesList
                }
            }
            .navigationTitle("Favorites")
        }
    }

    private var favoritesList: some View {
        List {
            Section {
                ForEach(favorites) { favorite in
                    if let exercise = store.exercise(withID: favorite.exerciseID) {
                        NavigationLink(value: exercise) {
                            ExerciseRowView(exercise: exercise, isFavorite: true)
                        }
                        .listRowBackground(Color.cardBackground)
                    }
                }
                .onDelete(perform: deleteFavorites)
            } header: {
                Text("\(favorites.count) saved exercise\(favorites.count == 1 ? "" : "s")")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: Exercise.self) { exercise in
            ExerciseDetailView(exercise: exercise)
        }
        .toolbar {
            EditButton()
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Favorites Yet",
            systemImage: "heart.slash",
            description: Text("Tap the heart icon on any exercise to save it here.")
        )
    }

    private func deleteFavorites(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(favorites[index])
        }
    }
}
