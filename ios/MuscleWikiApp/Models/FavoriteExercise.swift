import Foundation
import SwiftData

@Model
final class FavoriteExercise {
    @Attribute(.unique) var exerciseID: Int
    var exerciseName: String
    var category: String
    var difficulty: String
    var savedAt: Date

    init(exercise: Exercise) {
        self.exerciseID = exercise.id
        self.exerciseName = exercise.exerciseName
        self.category = exercise.category
        self.difficulty = exercise.difficulty
        self.savedAt = .now
    }
}
