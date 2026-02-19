import Foundation
import SwiftData

/// A conversation thread in Ada's chat interface.
@Model
final class AdaConversation {
    var id: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade)
    var messages: [AdaMessage]

    init(title: String = "New Conversation") {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
        self.messages = []
    }
}

/// A single message in a conversation.
@Model
final class AdaMessage {
    var id: UUID
    var role: MessageRole
    var content: String
    var createdAt: Date
    var planID: UUID?

    @Relationship(inverse: \AdaConversation.messages)
    var conversation: AdaConversation?

    init(
        role: MessageRole,
        content: String,
        planID: UUID? = nil
    ) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.createdAt = Date()
        self.planID = planID
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
    case system
}
