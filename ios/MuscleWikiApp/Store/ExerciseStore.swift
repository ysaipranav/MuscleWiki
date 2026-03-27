import Observation
import Foundation

@Observable
@MainActor
final class ExerciseStore {
    // MARK: State

    private(set) var exercises: [Exercise] = []
    private(set) var attributes: WorkoutAttributes = .empty
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: Filter state

    var selectedCategories: Set<String> = []
    var selectedDifficulties: Set<String> = []
    var selectedForces: Set<String> = []
    var selectedMuscles: Set<String> = []
    var searchText = ""

    // MARK: Computed

    var filteredExercises: [Exercise] {
        exercises.filter { exercise in
            let matchesSearch = searchText.isEmpty
                || exercise.exerciseName.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategories.isEmpty
                || selectedCategories.contains(exercise.category)
            let matchesDifficulty = selectedDifficulties.isEmpty
                || selectedDifficulties.contains(exercise.difficulty)
            let matchesForce = selectedForces.isEmpty
                || selectedForces.contains(exercise.force)
            let matchesMuscle = selectedMuscles.isEmpty
                || !selectedMuscles.isDisjoint(with: exercise.allMuscles)
            return matchesSearch && matchesCategory && matchesDifficulty
                && matchesForce && matchesMuscle
        }
    }

    var hasActiveFilters: Bool {
        !selectedCategories.isEmpty
            || !selectedDifficulties.isEmpty
            || !selectedForces.isEmpty
            || !selectedMuscles.isEmpty
    }

    var activeFilterCount: Int {
        selectedCategories.count
            + selectedDifficulties.count
            + selectedForces.count
            + selectedMuscles.count
    }

    // MARK: Actions

    func loadData() async {
        guard exercises.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            async let exercisesTask = DataService.shared.loadExercises()
            async let attributesTask = DataService.shared.loadAttributes()
            (exercises, attributes) = try await (exercisesTask, attributesTask)
            Task.detached(priority: .background) { [exercises = self.exercises] in
                await SpotlightService.shared.indexExercises(exercises)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func clearFilters() {
        selectedCategories.removeAll()
        selectedDifficulties.removeAll()
        selectedForces.removeAll()
        selectedMuscles.removeAll()
    }

    func exercise(withID id: Int) -> Exercise? {
        exercises.first { $0.id == id }
    }

    // MARK: Testing support

    /// Injects exercises directly, bypassing async loading. For unit tests only.
    func injectForTesting(exercises: [Exercise]) {
        self.exercises = exercises
    }
}

extension WorkoutAttributes {
    static let empty = WorkoutAttributes(
        categories: [],
        difficulties: [],
        forces: [],
        muscles: []
    )
}
