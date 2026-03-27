import SwiftUI

struct BadgeView: View {
    let text: String
    let color: Color
    var size: BadgeSize = .regular

    enum BadgeSize {
        case small, regular
        var font: Font { self == .small ? .caption2 : .caption }
        var padding: EdgeInsets {
            self == .small
                ? EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)
                : EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        }
    }

    var body: some View {
        Text(text)
            .font(size.font)
            .fontWeight(.semibold)
            .padding(size.padding)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

struct DifficultyBadge: View {
    let difficulty: String
    var size: BadgeView.BadgeSize = .regular

    var body: some View {
        BadgeView(text: difficulty, color: .difficulty(difficulty), size: size)
    }
}

struct CategoryBadge: View {
    let category: String
    var size: BadgeView.BadgeSize = .regular

    var body: some View {
        BadgeView(text: category, color: .category(category), size: size)
    }
}
