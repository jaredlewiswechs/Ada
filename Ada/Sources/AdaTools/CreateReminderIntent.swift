import AppIntents
import Foundation

/// App Intent: Create a reminder via Ada.
/// Surfaces in Shortcuts, Spotlight, and Siri.
struct CreateReminderIntent: AppIntent {
    static let title: LocalizedStringResource = "Create Reminder with Ada"
    static let description: IntentDescription = "Create a reminder using Ada's intelligent parsing."
    static let openAppWhenRun: Bool = false

    @Parameter(title: "Reminder Description")
    var reminderDescription: String

    @Parameter(title: "Due Date")
    var dueDate: Date?

    @Parameter(title: "Priority", default: .normal)
    var priority: IntentPriority

    static var parameterSummary: some ParameterSummary {
        Summary("Remind me to \(\.$reminderDescription)") {
            \.$dueDate
            \.$priority
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let reminderAccess = await ReminderService.shared.requestAccess()

        guard reminderAccess else {
            return .result(dialog: "Reminders access is required. Please grant access in Settings.")
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let dueDateStr = dueDate.map { formatter.string(from: $0) }

        let result = await ReminderService.shared.createReminder(
            title: reminderDescription,
            dueDateString: dueDateStr,
            priority: priority.serviceValue,
            notes: nil
        )

        return .result(dialog: "\(result)")
    }
}

/// Priority level for App Intents parameter.
enum IntentPriority: String, AppEnum {
    case low
    case normal
    case high

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Priority"
    static let caseDisplayRepresentations: [IntentPriority: DisplayRepresentation] = [
        .low: "Low",
        .normal: "Normal",
        .high: "High",
    ]

    var serviceValue: String { rawValue }
}
