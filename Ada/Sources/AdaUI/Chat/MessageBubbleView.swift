import SwiftUI

/// A single message bubble in the chat interface.
/// User messages align right, assistant messages align left with receipts.
struct MessageBubbleView: View {
    let message: AdaMessage

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 60)
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(formattedContent)
                    .font(.body)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(backgroundColor)
                    .foregroundStyle(foregroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                Text(message.createdAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 4)
            }

            if message.role == .assistant {
                Spacer(minLength: 60)
            }
        }
    }

    private var formattedContent: AttributedString {
        (try? AttributedString(markdown: message.content)) ?? AttributedString(message.content)
    }

    private var backgroundColor: Color {
        switch message.role {
        case .user:
            return .accentColor
        case .assistant:
            return Color(.secondarySystemGroupedBackground)
        case .system:
            return Color(.tertiarySystemGroupedBackground)
        }
    }

    private var foregroundColor: Color {
        message.role == .user ? .white : .primary
    }
}

#Preview {
    VStack(spacing: 16) {
        MessageBubbleView(
            message: AdaMessage(role: .user, content: "Dentist next Thursday afternoon, remind me the night before")
        )
        MessageBubbleView(
            message: AdaMessage(role: .assistant, content: "**Schedule dentist visit**\n\n📅 Dentist appointment — Thursday at 2:00 PM\n🔔 Reminder — Wednesday evening\n\n✅ Event created\n✅ Reminder set")
        )
    }
    .padding()
}
