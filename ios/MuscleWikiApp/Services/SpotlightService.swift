import CoreSpotlight
import Foundation

actor SpotlightService {
    static let shared = SpotlightService()
    private init() {}

    private let domainIdentifier = "com.musclewiki.app.exercises"

    func indexExercises(_ exercises: [Exercise]) async {
        let items: [CSSearchableItem] = exercises.map { exercise in
            let attrs = CSSearchableItemAttributeSet(contentType: .text)
            attrs.title = exercise.exerciseName
            attrs.contentDescription = [
                exercise.category,
                exercise.difficulty,
                exercise.target.primary.joined(separator: ", ")
            ].joined(separator: " · ")
            attrs.keywords = [exercise.category, exercise.difficulty, exercise.force]
                + exercise.allMuscles

            return CSSearchableItem(
                uniqueIdentifier: "exercise-\(exercise.id)",
                domainIdentifier: domainIdentifier,
                attributeSet: attrs
            )
        }

        do {
            try await CSSearchableIndex.default().indexSearchableItems(items)
        } catch {
            // Spotlight indexing is best-effort; silently fail
        }
    }

    func deleteIndex() async {
        try? await CSSearchableIndex.default().deleteSearchableItems(
            withDomainIdentifiers: [domainIdentifier]
        )
    }

    /// Parses a Spotlight continuation user activity into an exercise ID.
    static func exerciseID(from userActivity: NSUserActivity) -> Int? {
        guard userActivity.activityType == CSSearchableItemActionType,
              let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
              id.hasPrefix("exercise-"),
              let exerciseID = Int(id.dropFirst("exercise-".count))
        else { return nil }
        return exerciseID
    }
}
