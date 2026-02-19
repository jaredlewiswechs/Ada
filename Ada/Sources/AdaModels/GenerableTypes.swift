import Foundation
import FoundationModels

// MARK: - Generable Plan Output

/// The structured plan that the on-device Foundation Model generates
/// from messy user input. Uses constrained decoding for guaranteed structure.
@Generable
struct GeneratedPlan {
    @Guide(description: "A concise description of the user's overall intent")
    var intent: String

    @Guide(description: "List of actions to execute, each with a tool name and parameters")
    var actions: [GeneratedAction]

    @Guide(description: "Extracted date references from the input")
    var dates: [String]

    @Guide(description: "Extracted time references from the input")
    var times: [String]

    @Guide(description: "Extracted location references from the input")
    var locations: [String]

    @Guide(description: "Extracted people references from the input")
    var people: [String]

    @Guide(description: "Risk level of the plan", .anyOf(["none", "needs_confirm", "sensitive"]))
    var riskLevel: String

    @Guide(description: "Brief summary of what will happen when this plan executes")
    var summary: String
}

@Generable
struct GeneratedAction {
    @Guide(description: "The tool to invoke", .anyOf([
        "createEvent", "createReminder", "createChecklist",
        "scanAndExtract", "dailyBrief", "inboxToPlan"
    ]))
    var tool: String

    @Guide(description: "Title or name for the action")
    var title: String

    @Guide(description: "Date string if applicable, in ISO 8601 or natural language")
    var date: String?

    @Guide(description: "Time string if applicable")
    var time: String?

    @Guide(description: "Location if applicable")
    var location: String?

    @Guide(description: "Additional notes or details")
    var notes: String?

    @Guide(description: "List of items for checklists")
    var listItems: [String]?

    @Guide(description: "Whether this action needs user confirmation before executing")
    var requiresConfirmation: Bool
}

// MARK: - Scan/OCR Extraction Output

/// Structured output from scanning a document or image.
@Generable
struct ExtractedContent {
    @Guide(description: "The type of document scanned", .anyOf([
        "notes", "bill", "flyer", "schedule", "receipt", "other"
    ]))
    var documentType: String

    @Guide(description: "Extracted tasks or action items")
    var tasks: [ExtractedTask]

    @Guide(description: "Extracted date references")
    var dates: [String]

    @Guide(description: "Extracted contact information")
    var contacts: [String]

    @Guide(description: "Key amounts or numbers found")
    var amounts: [String]

    @Guide(description: "Clean, reformatted version of the document content")
    var cleanDocument: String

    @Guide(description: "One-line summary of the scanned content")
    var summary: String
}

@Generable
struct ExtractedTask {
    @Guide(description: "The task description")
    var title: String

    @Guide(description: "Due date if mentioned")
    var dueDate: String?

    @Guide(description: "Priority level", .anyOf(["low", "normal", "high", "urgent"]))
    var priority: String

    @Guide(description: "Person assigned if mentioned")
    var assignee: String?
}

// MARK: - Daily Brief Output

/// Structured output for the daily briefing feature.
@Generable
struct DailyBriefOutput {
    @Guide(description: "Greeting appropriate for the time of day")
    var greeting: String

    @Guide(description: "Summary of today's events and tasks")
    var summary: String

    @Guide(description: "Top priority items for today", .count(3))
    var topPriorities: [String]

    @Guide(description: "Upcoming events for today")
    var upcomingEvents: [BriefEvent]

    @Guide(description: "Pending reminders due today or overdue")
    var pendingReminders: [String]
}

@Generable
struct BriefEvent {
    @Guide(description: "Event title")
    var title: String

    @Guide(description: "Event time")
    var time: String

    @Guide(description: "Event location if any")
    var location: String?
}
