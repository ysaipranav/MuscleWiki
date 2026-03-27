import SwiftUI

extension Color {
    // MARK: Brand
    static let appAccent = Color("AccentColor")
    static let appBackground = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)

    // MARK: Difficulty
    static let difficultyBeginner = Color.green
    static let difficultyIntermediate = Color.orange
    static let difficultyAdvanced = Color.red

    static func difficulty(_ level: String) -> Color {
        switch level.lowercased() {
        case "beginner": return .difficultyBeginner
        case "intermediate": return .difficultyIntermediate
        case "advanced": return .difficultyAdvanced
        default: return .secondary
        }
    }

    // MARK: Category
    static func category(_ name: String) -> Color {
        switch name.lowercased() {
        case "barbell": return .blue
        case "dumbbells": return .indigo
        case "kettlebells": return .purple
        case "cables": return .cyan
        case "band": return .yellow
        case "machine": return .orange
        case "bodyweight": return .green
        case "yoga", "stretches": return .teal
        case "trx": return .pink
        case "plate": return .brown
        default: return .secondary
        }
    }
}
