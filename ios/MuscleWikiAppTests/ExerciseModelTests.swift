import Testing
import Foundation
@testable import MuscleWikiApp

@Suite("Exercise Model")
struct ExerciseModelTests {
    let sampleJSON = """
    [{
        "id": 0,
        "exercise_name": "Barbell Curl",
        "videoURL": [
            "https://media.musclewiki.com/front.mp4#t=0.1",
            "https://media.musclewiki.com/side.mp4#t=0.1"
        ],
        "steps": ["Step 1", "Step 2"],
        "Category": "Barbell",
        "Difficulty": "Beginner",
        "Force": "Pull",
        "Grips": "Underhand",
        "target": {
            "Primary": ["Biceps"],
            "Secondary": ["Forearms"]
        },
        "youtubeURL": "https://www.youtube.com/embed/abc",
        "details": "Some details"
    }]
    """.data(using: .utf8)!

    @Test("Decodes exercise from JSON correctly")
    func decodesFromJSON() throws {
        let exercises = try JSONDecoder().decode([Exercise].self, from: sampleJSON)
        #expect(exercises.count == 1)
        let exercise = try #require(exercises.first)
        #expect(exercise.id == 0)
        #expect(exercise.exerciseName == "Barbell Curl")
        #expect(exercise.category == "Barbell")
        #expect(exercise.difficulty == "Beginner")
        #expect(exercise.force == "Pull")
        #expect(exercise.grips == "Underhand")
        #expect(exercise.videoURLs.count == 2)
        #expect(exercise.steps.count == 2)
        #expect(exercise.target.primary == ["Biceps"])
        #expect(exercise.target.secondary == ["Forearms"])
        #expect(exercise.target.tertiary == nil)
    }

    @Test("allMuscles includes all tiers")
    func allMusclesAggregatesTiers() throws {
        let exercises = try JSONDecoder().decode([Exercise].self, from: sampleJSON)
        let exercise = try #require(exercises.first)
        #expect(exercise.allMuscles.contains("Biceps"))
        #expect(exercise.allMuscles.contains("Forearms"))
        #expect(exercise.allMuscles.count == 2)
    }

    @Test("Missing optional fields do not cause decode failure")
    func decodesWithoutOptionals() throws {
        let minimalJSON = """
        [{
            "id": 1,
            "exercise_name": "Push Up",
            "videoURL": [],
            "steps": [],
            "Category": "Bodyweight",
            "Difficulty": "Beginner",
            "Force": "Push",
            "target": { "Primary": ["Chest"] }
        }]
        """.data(using: .utf8)!
        let exercises = try JSONDecoder().decode([Exercise].self, from: minimalJSON)
        let exercise = try #require(exercises.first)
        #expect(exercise.grips == nil)
        #expect(exercise.youtubeURL == nil)
        #expect(exercise.details == nil)
        #expect(exercise.aka == nil)
        #expect(exercise.target.secondary == nil)
    }

    @Test("difficultyColorName returns correct values")
    func difficultyColorNames() throws {
        let exercises = try JSONDecoder().decode([Exercise].self, from: sampleJSON)
        let exercise = try #require(exercises.first)
        #expect(exercise.difficultyColorName == "DifficultyBeginner")
    }
}
