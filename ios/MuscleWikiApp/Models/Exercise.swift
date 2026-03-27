import Foundation

struct Exercise: Codable, Identifiable, Sendable, Hashable {
    let id: Int
    let exerciseName: String
    let videoURLs: [String]
    let steps: [String]
    let category: String
    let difficulty: String
    let force: String
    let grips: String?
    let target: MuscleTarget
    let youtubeURL: String?
    let details: String?
    let aka: String?

    enum CodingKeys: String, CodingKey {
        case id
        case exerciseName = "exercise_name"
        case videoURLs = "videoURL"
        case steps
        case category = "Category"
        case difficulty = "Difficulty"
        case force = "Force"
        case grips = "Grips"
        case target
        case youtubeURL
        case details
        case aka = "Aka"
    }

    // All muscles this exercise targets (any tier)
    var allMuscles: [String] {
        (target.primary + (target.secondary ?? []) + (target.tertiary ?? []))
    }

    // Display difficulty color name
    var difficultyColorName: String {
        switch difficulty.lowercased() {
        case "beginner": return "DifficultyBeginner"
        case "intermediate": return "DifficultyIntermediate"
        case "advanced": return "DifficultyAdvanced"
        default: return "DifficultyBeginner"
        }
    }
}

struct MuscleTarget: Codable, Sendable, Hashable {
    let primary: [String]
    let secondary: [String]?
    let tertiary: [String]?

    enum CodingKeys: String, CodingKey {
        case primary = "Primary"
        case secondary = "Secondary"
        case tertiary = "Tertiary"
    }
}

struct WorkoutAttributes: Codable, Sendable {
    let categories: [String]
    let difficulties: [String]
    let forces: [String]
    let muscles: [String]
}
