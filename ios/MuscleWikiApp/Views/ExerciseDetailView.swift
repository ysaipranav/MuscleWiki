import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(\.modelContext) private var modelContext
    @Query private var favorites: [FavoriteExercise]

    private var isFavorite: Bool {
        favorites.contains { $0.exerciseID == exercise.id }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Demo video
                if !exercise.videoURLs.isEmpty {
                    VideoPlayerView(urls: exercise.videoURLs)
                        .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 20) {
                    // Attribute badges
                    attributeBadges

                    Divider()

                    // Muscles
                    MuscleGroupSection(target: exercise.target)

                    Divider()

                    // Steps
                    stepsSection

                    // Details
                    if let details = exercise.details, !details.isEmpty {
                        Divider()
                        detailsSection(details)
                    }

                    // YouTube tutorial
                    if let youtubeURL = exercise.youtubeURL, !youtubeURL.isEmpty {
                        Divider()
                        YouTubeSection(embedURL: youtubeURL)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
        .navigationTitle(exercise.exerciseName)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                favoriteButton
            }
        }
        .background(Color.appBackground)
    }

    // MARK: Subviews

    private var attributeBadges: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryBadge(category: exercise.category)
                DifficultyBadge(difficulty: exercise.difficulty)
                BadgeView(text: exercise.force, color: .blue)
                if let grips = exercise.grips, !grips.isEmpty {
                    BadgeView(text: grips, color: .purple)
                }
                if let aka = exercise.aka, !aka.isEmpty {
                    BadgeView(text: "aka \(aka)", color: .secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Category: \(exercise.category), Difficulty: \(exercise.difficulty), Force: \(exercise.force)"
        )
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How To")
                .font(.headline)

            ForEach(Array(exercise.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Color.appAccent))
                        .accessibilityHidden(true)

                    Text(step)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Step \(index + 1): \(step)")
            }
        }
    }

    private func detailsSection(_ details: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Coach Notes")
                .font(.headline)
            Text(details
                .replacingOccurrences(of: "**", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            )
            .font(.body)
            .foregroundStyle(.secondary)
        }
    }

    private var favoriteButton: some View {
        Button {
            toggleFavorite()
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(isFavorite ? .red : .secondary)
                .imageScale(.large)
        }
        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
        .accessibilityHint("Double-tap to \(isFavorite ? "remove from" : "add to") your favorites list")
    }

    // MARK: Actions

    private func toggleFavorite() {
        if let existing = favorites.first(where: { $0.exerciseID == exercise.id }) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(FavoriteExercise(exercise: exercise))
        }
    }
}
