import SwiftUI

/// A tappable suggestion chip used in the chat empty state.
struct SuggestionChip: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        SuggestionChip(title: "Plan my week", icon: "calendar") {}
        SuggestionChip(title: "Scan document", icon: "doc.text.viewfinder") {}
    }
}
