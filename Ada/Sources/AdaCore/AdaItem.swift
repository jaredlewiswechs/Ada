import Foundation
import SwiftData

/// A unified item in Ada — can represent a task, event, note, or checklist.
/// This is the core unit of work that Ada manages for the user.
@Model
final class AdaItem {
    var id: UUID
    var title: String
    var detail: String
    var kind: AdaItemKind
    var status: AdaItemStatus
    var priority: AdaItemPriority
    var createdAt: Date
    var updatedAt: Date
    var dueDate: Date?
    var completedAt: Date?
    var location: String?
    var people: [String]
    var tags: [String]
    var sourceText: String?
    var parentPlanID: UUID?

    @Relationship(inverse: \AdaPlan.items)
    var plan: AdaPlan?

    init(
        title: String,
        detail: String = "",
        kind: AdaItemKind = .task,
        status: AdaItemStatus = .pending,
        priority: AdaItemPriority = .normal,
        dueDate: Date? = nil,
        location: String? = nil,
        people: [String] = [],
        tags: [String] = [],
        sourceText: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.detail = detail
        self.kind = kind
        self.status = status
        self.priority = priority
        self.createdAt = Date()
        self.updatedAt = Date()
        self.dueDate = dueDate
        self.location = location
        self.people = people
        self.tags = tags
        self.sourceText = sourceText
    }
}

enum AdaItemKind: String, Codable, CaseIterable, Identifiable {
    case task
    case event
    case note
    case checklist
    case reminder

    var id: String { rawValue }

    var label: String {
        switch self {
        case .task: "Task"
        case .event: "Event"
        case .note: "Note"
        case .checklist: "Checklist"
        case .reminder: "Reminder"
        }
    }

    var systemImage: String {
        switch self {
        case .task: "checkmark.circle"
        case .event: "calendar"
        case .note: "note.text"
        case .checklist: "list.bullet"
        case .reminder: "bell"
        }
    }
}

enum AdaItemStatus: String, Codable, CaseIterable {
    case pending
    case inProgress
    case completed
    case cancelled
}

enum AdaItemPriority: String, Codable, CaseIterable {
    case low
    case normal
    case high
    case urgent
}
