import Testing
import Foundation
@testable import MuscleWikiApp

@Suite("DataService")
struct DataServiceTests {
    @Test("Loads exercises from bundle")
    func loadsExercisesFromBundle() async throws {
        let exercises = try await DataService.shared.loadExercises()
        #expect(!exercises.isEmpty)
        #expect(exercises.count > 900, "Expected 900+ exercises, got \(exercises.count)")
    }

    @Test("Loads attributes from bundle")
    func loadsAttributesFromBundle() async throws {
        let attributes = try await DataService.shared.loadAttributes()
        #expect(!attributes.categories.isEmpty)
        #expect(!attributes.difficulties.isEmpty)
        #expect(!attributes.forces.isEmpty)
        #expect(!attributes.muscles.isEmpty)
        #expect(attributes.difficulties.contains("Beginner"))
        #expect(attributes.difficulties.contains("Intermediate"))
        #expect(attributes.difficulties.contains("Advanced"))
    }

    @Test("All exercises have non-empty required fields")
    func allExercisesHaveRequiredFields() async throws {
        let exercises = try await DataService.shared.loadExercises()
        for exercise in exercises {
            #expect(!exercise.exerciseName.isEmpty, "Exercise \(exercise.id) has empty name")
            #expect(!exercise.category.isEmpty, "Exercise \(exercise.id) has empty category")
            #expect(!exercise.difficulty.isEmpty, "Exercise \(exercise.id) has empty difficulty")
            #expect(!exercise.target.primary.isEmpty,
                    "Exercise \(exercise.id) has no primary muscle")
        }
    }

    @Test("Exercise IDs are unique")
    func exerciseIDsAreUnique() async throws {
        let exercises = try await DataService.shared.loadExercises()
        let ids = exercises.map(\.id)
        let uniqueIDs = Set(ids)
        #expect(ids.count == uniqueIDs.count)
    }
}
