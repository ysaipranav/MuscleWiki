import SwiftUI
import SwiftData

@main
struct MuscleWikiApp: App {
    @State private var store = ExerciseStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .modelContainer(for: FavoriteExercise.self)
                .task {
                    await store.loadData()
                }
        }
    }
}
