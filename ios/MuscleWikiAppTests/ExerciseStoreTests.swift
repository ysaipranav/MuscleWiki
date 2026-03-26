import Testing
import Foundation
@testable import MuscleWikiApp

@Suite("ExerciseStore Filtering")
@MainActor
struct ExerciseStoreTests {
    func makeStore(with exercises: [Exercise]) -> ExerciseStore {
        let store = ExerciseStore()
        // Inject test data via the internal setter pattern
        store.injectForTesting(exercises: exercises)
        return store
    }

    func makeExercise(
        id: Int = 0,
        name: String = "Test",
        category: String = "Barbell",
        difficulty: String = "Beginner",
        force: String = "Pull",
        primary: [String] = ["Biceps"]
    ) -> Exercise {
        Exercise(
            id: id,
            exerciseName: name,
            videoURLs: [],
            steps: [],
            category: category,
            difficulty: difficulty,
            force: force,
            grips: nil,
            target: MuscleTarget(primary: primary, secondary: nil, tertiary: nil),
            youtubeURL: nil,
            details: nil,
            aka: nil
        )
    }

    @Test("Returns all exercises when no filters active")
    func noFilterReturnsAll() {
        let exercises = [
            makeExercise(id: 0, name: "A"),
            makeExercise(id: 1, name: "B"),
        ]
        let store = makeStore(with: exercises)
        #expect(store.filteredExercises.count == 2)
    }

    @Test("Search text filters by name")
    func searchFiltersByName() {
        let exercises = [
            makeExercise(id: 0, name: "Barbell Curl"),
            makeExercise(id: 1, name: "Push Up"),
        ]
        let store = makeStore(with: exercises)
        store.searchText = "curl"
        #expect(store.filteredExercises.count == 1)
        #expect(store.filteredExercises.first?.exerciseName == "Barbell Curl")
    }

    @Test("Search is case insensitive")
    func searchIsCaseInsensitive() {
        let exercises = [makeExercise(id: 0, name: "Barbell Curl")]
        let store = makeStore(with: exercises)
        store.searchText = "BARBELL"
        #expect(store.filteredExercises.count == 1)
    }

    @Test("Category filter returns only matching exercises")
    func categoryFilter() {
        let exercises = [
            makeExercise(id: 0, category: "Barbell"),
            makeExercise(id: 1, category: "Dumbbells"),
        ]
        let store = makeStore(with: exercises)
        store.selectedCategories = ["Barbell"]
        #expect(store.filteredExercises.count == 1)
        #expect(store.filteredExercises.first?.category == "Barbell")
    }

    @Test("Difficulty filter returns only matching exercises")
    func difficultyFilter() {
        let exercises = [
            makeExercise(id: 0, difficulty: "Beginner"),
            makeExercise(id: 1, difficulty: "Advanced"),
        ]
        let store = makeStore(with: exercises)
        store.selectedDifficulties = ["Advanced"]
        #expect(store.filteredExercises.count == 1)
    }

    @Test("Muscle filter matches primary and secondary muscles")
    func muscleFilterMatchesAllTiers() {
        let bicepExercise = makeExercise(id: 0, primary: ["Biceps"])
        let tricepExercise = Exercise(
            id: 1, exerciseName: "Tricep Ext", videoURLs: [], steps: [],
            category: "Cable", difficulty: "Beginner", force: "Push", grips: nil,
            target: MuscleTarget(primary: ["Triceps"], secondary: ["Forearms"], tertiary: nil),
            youtubeURL: nil, details: nil, aka: nil
        )
        let store = makeStore(with: [bicepExercise, tricepExercise])
        store.selectedMuscles = ["Forearms"]
        // Only the tricep exercise has Forearms as secondary
        #expect(store.filteredExercises.count == 1)
        #expect(store.filteredExercises.first?.id == 1)
    }

    @Test("Multiple filters are ANDed together")
    func multipleFiltersAreAnded() {
        let exercises = [
            makeExercise(id: 0, category: "Barbell", difficulty: "Beginner"),
            makeExercise(id: 1, category: "Barbell", difficulty: "Advanced"),
            makeExercise(id: 2, category: "Dumbbells", difficulty: "Beginner"),
        ]
        let store = makeStore(with: exercises)
        store.selectedCategories = ["Barbell"]
        store.selectedDifficulties = ["Beginner"]
        #expect(store.filteredExercises.count == 1)
        #expect(store.filteredExercises.first?.id == 0)
    }

    @Test("clearFilters resets all filter state")
    func clearFiltersResetsAll() {
        let store = makeStore(with: [makeExercise()])
        store.selectedCategories = ["Barbell"]
        store.selectedDifficulties = ["Beginner"]
        store.selectedForces = ["Pull"]
        store.selectedMuscles = ["Biceps"]
        store.clearFilters()
        #expect(store.selectedCategories.isEmpty)
        #expect(store.selectedDifficulties.isEmpty)
        #expect(store.selectedForces.isEmpty)
        #expect(store.selectedMuscles.isEmpty)
        #expect(!store.hasActiveFilters)
    }

    @Test("activeFilterCount sums all active filters")
    func activeFilterCount() {
        let store = makeStore(with: [])
        store.selectedCategories = ["Barbell", "Dumbbells"]
        store.selectedDifficulties = ["Beginner"]
        #expect(store.activeFilterCount == 3)
    }
}
