import SwiftUI

struct MuscleChipView: View {
    let muscle: String
    let tier: MuscleTier

    enum MuscleTier: String {
        case primary = "Primary"
        case secondary = "Secondary"
        case tertiary = "Tertiary"

        var color: Color {
            switch self {
            case .primary: return .red
            case .secondary: return .orange
            case .tertiary: return .yellow
            }
        }

        var icon: String {
            switch self {
            case .primary: return "flame.fill"
            case .secondary: return "flame"
            case .tertiary: return "circle.fill"
            }
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: tier.icon)
                .font(.caption2)
                .foregroundStyle(tier.color)
            Text(muscle)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(tier.color.opacity(0.12))
        .foregroundStyle(.primary)
        .clipShape(Capsule())
    }
}

struct MuscleGroupSection: View {
    let target: MuscleTarget

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Muscles Worked")
                .font(.headline)

            if !target.primary.isEmpty {
                muscleTierRow(muscles: target.primary, tier: .primary)
            }
            if let secondary = target.secondary, !secondary.isEmpty {
                muscleTierRow(muscles: secondary, tier: .secondary)
            }
            if let tertiary = target.tertiary, !tertiary.isEmpty {
                muscleTierRow(muscles: tertiary, tier: .tertiary)
            }
        }
    }

    private func muscleTierRow(muscles: [String], tier: MuscleChipView.MuscleTier) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(tier.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .kerning(0.5)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(muscles, id: \.self) { muscle in
                        MuscleChipView(muscle: muscle, tier: tier)
                    }
                }
            }
        }
    }
}
