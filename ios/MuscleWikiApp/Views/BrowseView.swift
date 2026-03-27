import SwiftUI

struct BrowseView: View {
    @Environment(ExerciseStore.self) private var store
    @State private var selectedMuscle: String?

    var body: some View {
        NavigationStack {
            MuscleMapView(selectedMuscle: $selectedMuscle)
                .navigationTitle("Browse by Muscle")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    if selectedMuscle != nil {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Clear") {
                                withAnimation {
                                    selectedMuscle = nil
                                    store.selectedMuscles.removeAll()
                                }
                            }
                        }
                    }
                }
                .navigationDestination(for: Exercise.self) { exercise in
                    ExerciseDetailView(exercise: exercise)
                }
        }
    }
}
