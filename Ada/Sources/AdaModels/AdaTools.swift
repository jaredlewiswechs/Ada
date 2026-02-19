import Foundation
import FoundationModels

// MARK: - Foundation Models Tool Definitions

/// Tool that creates a calendar event via the on-device model's tool calling.
struct CreateEventTool: Tool {
    let name = "createEvent"
    let description = "Create a calendar event with a title, date, time, and optional location"

    @Generable
    struct Arguments {
        @Guide(description: "Event title")
        var title: String
        @Guide(description: "Event date in ISO 8601 format (YYYY-MM-DD)")
        var date: String
        @Guide(description: "Event start time (HH:mm)")
        var startTime: String
        @Guide(description: "Event end time (HH:mm)")
        var endTime: String?
        @Guide(description: "Event location")
        var location: String?
        @Guide(description: "Additional notes")
        var notes: String?
    }

    func call(arguments: Arguments) async throws -> ToolOutput {
        // Delegate to CalendarService for actual EventKit execution
        let result = await CalendarService.shared.createEvent(
            title: arguments.title,
            dateString: arguments.date,
            startTime: arguments.startTime,
            endTime: arguments.endTime,
            location: arguments.location,
            notes: arguments.notes
        )
        return ToolOutput(result)
    }
}

/// Tool that creates a reminder.
struct CreateReminderTool: Tool {
    let name = "createReminder"
    let description = "Create a reminder with a title and optional due date"

    @Generable
    struct Arguments {
        @Guide(description: "Reminder title")
        var title: String
        @Guide(description: "Due date in ISO 8601 format (YYYY-MM-DD)")
        var dueDate: String?
        @Guide(description: "Priority level", .anyOf(["low", "normal", "high"]))
        var priority: String?
        @Guide(description: "Additional notes")
        var notes: String?
    }

    func call(arguments: Arguments) async throws -> ToolOutput {
        let result = await ReminderService.shared.createReminder(
            title: arguments.title,
            dueDateString: arguments.dueDate,
            priority: arguments.priority,
            notes: arguments.notes
        )
        return ToolOutput(result)
    }
}

/// Tool that creates a checklist.
struct CreateChecklistTool: Tool {
    let name = "createChecklist"
    let description = "Create a checklist with a title and list of items"

    @Generable
    struct Arguments {
        @Guide(description: "Checklist title")
        var title: String
        @Guide(description: "Items in the checklist")
        var items: [String]
    }

    func call(arguments: Arguments) async throws -> ToolOutput {
        let itemList = arguments.items.enumerated()
            .map { "[\($0.offset + 1)] \($0.element)" }
            .joined(separator: "\n")
        return ToolOutput("Checklist '\(arguments.title)' created with \(arguments.items.count) items:\n\(itemList)")
    }
}

// MARK: - Tool-Enabled Session Factory

extension AdaModelService {
    /// Create a session with all Ada tools registered for autonomous execution.
    func createToolSession() -> LanguageModelSession {
        let session = LanguageModelSession(
            instructions: Self.systemInstructions,
            tools: [
                CreateEventTool(),
                CreateReminderTool(),
                CreateChecklistTool(),
            ]
        )
        self.session = session
        return session
    }
}
