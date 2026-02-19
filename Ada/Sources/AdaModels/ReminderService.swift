import Foundation
import EventKit

/// Service for interacting with the system Reminders via EventKit.
actor ReminderService {
    static let shared = ReminderService()

    private let store = EKEventStore()
    private var hasAccess = false

    /// Request reminders access from the user.
    func requestAccess() async -> Bool {
        do {
            let granted = try await store.requestFullAccessToReminders()
            hasAccess = granted
            return granted
        } catch {
            return false
        }
    }

    /// Create a reminder and return a receipt string.
    func createReminder(
        title: String,
        dueDateString: String?,
        priority: String?,
        notes: String?
    ) -> String {
        guard hasAccess else {
            return "Error: Reminders access not granted. Please allow access in Settings."
        }

        let reminder = EKReminder(eventStore: store)
        reminder.title = title
        reminder.calendar = store.defaultCalendarForNewReminders()

        if let dueDateString {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            if let date = formatter.date(from: dueDateString) {
                let components = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: date
                )
                reminder.dueDateComponents = components
            }
        }

        switch priority {
        case "high":
            reminder.priority = Int(EKReminderPriority.high.rawValue)
        case "low":
            reminder.priority = Int(EKReminderPriority.low.rawValue)
        default:
            reminder.priority = Int(EKReminderPriority.medium.rawValue)
        }

        if let notes {
            reminder.notes = notes
        }

        do {
            try store.save(reminder, commit: true)
            var result = "Reminder '\(title)' created"
            if let dueDateString {
                result += " due \(dueDateString)"
            }
            return result
        } catch {
            return "Error creating reminder: \(error.localizedDescription)"
        }
    }
}
