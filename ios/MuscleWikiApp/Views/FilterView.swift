import SwiftUI

struct FilterView: View {
    @Environment(ExerciseStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            Form {
                filterSection(
                    title: "Category",
                    options: store.attributes.categories,
                    selected: $store.selectedCategories,
                    colorFor: { Color.category($0) }
                )

                filterSection(
                    title: "Difficulty",
                    options: store.attributes.difficulties,
                    selected: $store.selectedDifficulties,
                    colorFor: { Color.difficulty($0) }
                )

                filterSection(
                    title: "Force",
                    options: store.attributes.forces,
                    selected: $store.selectedForces,
                    colorFor: { _ in .accentColor }
                )

                filterSection(
                    title: "Muscle Group",
                    options: store.attributes.muscles,
                    selected: $store.selectedMuscles,
                    colorFor: { _ in .secondary }
                )
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        store.clearFilters()
                    }
                    .disabled(!store.hasActiveFilters)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    @ViewBuilder
    private func filterSection(
        title: String,
        options: [String],
        selected: Binding<Set<String>>,
        colorFor: @escaping (String) -> Color
    ) -> some View {
        Section(title) {
            ForEach(options, id: \.self) { option in
                Toggle(isOn: Binding(
                    get: { selected.wrappedValue.contains(option) },
                    set: { isOn in
                        if isOn { selected.wrappedValue.insert(option) }
                        else { selected.wrappedValue.remove(option) }
                    }
                )) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(colorFor(option))
                            .frame(width: 10, height: 10)
                        Text(option)
                    }
                }
                .tint(.accentColor)
                .accessibilityLabel("\(option) filter, \(selected.wrappedValue.contains(option) ? "on" : "off")")
            }
        }
    }
}
