import SwiftUI

/// An interactive body diagram that lets the user tap muscle groups to filter exercises.
struct MuscleMapView: View {
    @Environment(ExerciseStore.self) private var store
    @Binding var selectedMuscle: String?

    // Ordered list with display names matching workout-attributes.json
    private let muscleGroups: [MuscleGroup] = [
        MuscleGroup(name: "Chest",      icon: "figure.arms.open", color: .red),
        MuscleGroup(name: "Shoulders",  icon: "figure.mixed.cardio", color: .orange),
        MuscleGroup(name: "Biceps",     icon: "figure.strengthtraining.traditional", color: .yellow),
        MuscleGroup(name: "Triceps",    icon: "figure.strengthtraining.functional", color: .green),
        MuscleGroup(name: "Forearms",   icon: "hand.raised.fill", color: .teal),
        MuscleGroup(name: "Lats",       icon: "figure.cooldown", color: .cyan),
        MuscleGroup(name: "Mid back",   icon: "figure.gymnastics", color: .blue),
        MuscleGroup(name: "Lower back", icon: "figure.barre", color: .indigo),
        MuscleGroup(name: "Traps",      icon: "figure.climbing", color: .purple),
        MuscleGroup(name: "Abdominals", icon: "figure.core.training", color: .pink),
        MuscleGroup(name: "Obliques",   icon: "figure.pilates", color: .red),
        MuscleGroup(name: "Glutes",     icon: "figure.run", color: .orange),
        MuscleGroup(name: "Quads",      icon: "figure.walk", color: .yellow),
        MuscleGroup(name: "Hamstrings", icon: "figure.stairs", color: .green),
        MuscleGroup(name: "Calves",     icon: "figure.step.training", color: .teal),
    ]

    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 160), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(muscleGroups) { group in
                    MuscleGroupTile(
                        group: group,
                        isSelected: selectedMuscle == group.name,
                        exerciseCount: exerciseCount(for: group.name)
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            if selectedMuscle == group.name {
                                selectedMuscle = nil
                                store.selectedMuscles.remove(group.name)
                            } else {
                                selectedMuscle = group.name
                                store.selectedMuscles = [group.name]
                            }
                        }
                    }
                    .accessibilityAddTraits(selectedMuscle == group.name ? .isSelected : [])
                    .accessibilityLabel("\(group.name), \(exerciseCount(for: group.name)) exercises")
                    .accessibilityHint(
                        selectedMuscle == group.name
                            ? "Tap to deselect"
                            : "Tap to filter exercises by this muscle"
                    )
                }
            }
            .padding()
        }
    }

    private func exerciseCount(for muscle: String) -> Int {
        store.exercises.filter { $0.allMuscles.contains(muscle) }.count
    }
}

struct MuscleGroup: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}

struct MuscleGroupTile: View {
    let group: MuscleGroup
    let isSelected: Bool
    let exerciseCount: Int

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: group.icon)
                .font(.title2)
                .foregroundStyle(isSelected ? .white : group.color)
                .frame(height: 36)

            Text(group.name)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundStyle(isSelected ? .white : .primary)

            Text("\(exerciseCount)")
                .font(.caption2)
                .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected ? group.color : Color.cardBackground)
                .shadow(color: isSelected ? group.color.opacity(0.4) : .clear, radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? group.color : Color.clear, lineWidth: 2)
        )
        .animation(.spring(response: 0.25), value: isSelected)
    }
}
