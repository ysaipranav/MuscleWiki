import SwiftUI

struct ExerciseRowView: View {
    let exercise: Exercise
    var isFavorite: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Category color indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.category(exercise.category))
                .frame(width: 4)
                .frame(maxHeight: 52)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(exercise.exerciseName)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    if isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                HStack(spacing: 6) {
                    CategoryBadge(category: exercise.category, size: .small)
                    DifficultyBadge(difficulty: exercise.difficulty, size: .small)
                    if let firstMuscle = exercise.target.primary.first {
                        Text(firstMuscle)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(exercise.exerciseName), \(exercise.category), \(exercise.difficulty)"
        )
        .accessibilityHint("Tap to view exercise details")
    }
}
