import SwiftUI
import SwiftData

struct ExerciseListView: View {
    @Environment(ExerciseStore.self) private var store
    @Query private var favorites: [FavoriteExercise]
    @State private var showFilters = false
    @State private var selectedExercise: Exercise?

    private var favoriteIDs: Set<Int> {
        Set(favorites.map(\.exerciseID))
    }

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            Group {
                if store.isLoading {
                    loadingView
                } else if let error = store.errorMessage {
                    errorView(error)
                } else {
                    exerciseList
                }
            }
            .navigationTitle("Exercises")
            .searchable(
                text: $store.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search 954 exercises..."
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    filterButton
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .navigationDestination(for: Exercise.self) { exercise in
                ExerciseDetailView(exercise: exercise)
            }
        }
    }

    // MARK: Subviews

    private var exerciseList: some View {
        List {
            if store.hasActiveFilters {
                filterSummaryBanner
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            }

            let results = store.filteredExercises
            if results.isEmpty {
                emptyState
                    .listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(results) { exercise in
                        NavigationLink(value: exercise) {
                            ExerciseRowView(
                                exercise: exercise,
                                isFavorite: favoriteIDs.contains(exercise.id)
                            )
                        }
                        .listRowBackground(Color.cardBackground)
                    }
                } header: {
                    Text("\(results.count) exercise\(results.count == 1 ? "" : "s")")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .animation(.default, value: store.filteredExercises.map(\.id))
    }

    private var filterSummaryBanner: some View {
        HStack {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .foregroundStyle(.accentColor)
            Text("\(store.activeFilterCount) filter\(store.activeFilterCount == 1 ? "" : "s") active")
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            Button("Clear") {
                withAnimation { store.clearFilters() }
            }
            .font(.subheadline)
            .foregroundStyle(.red)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.appAccent.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
    }

    private var filterButton: some View {
        Button {
            showFilters = true
        } label: {
            Image(systemName: store.hasActiveFilters
                  ? "line.3.horizontal.decrease.circle.fill"
                  : "line.3.horizontal.decrease.circle")
                .foregroundStyle(store.hasActiveFilters ? .accentColor : .primary)
                .overlay(alignment: .topTrailing) {
                    if store.activeFilterCount > 0 {
                        Text("\(store.activeFilterCount)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(3)
                            .background(Circle().fill(.red))
                            .offset(x: 6, y: -6)
                    }
                }
        }
        .accessibilityLabel(store.hasActiveFilters
            ? "Filters, \(store.activeFilterCount) active"
            : "Filters")
        .accessibilityHint("Tap to open filter options")
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading exercises…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading exercises")
    }

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Unable to Load", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Retry") {
                Task { await store.loadData() }
            }
            .buttonStyle(.bordered)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView.search(text: store.searchText.isEmpty
            ? store.selectedMuscles.first ?? "current filters"
            : store.searchText
        )
    }
}
