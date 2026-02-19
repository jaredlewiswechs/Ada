import Foundation
import EventKit

/// Service for interacting with the system Calendar via EventKit.
/// All calendar operations go through here, providing a single point of
/// audit and permission management.
actor CalendarService {
    static let shared = CalendarService()

    private let store = EKEventStore()
    private var hasAccess = false

    /// Request calendar access from the user.
    func requestAccess() async -> Bool {
        do {
            let granted = try await store.requestFullAccessToEvents()
            hasAccess = granted
            return granted
        } catch {
            return false
        }
    }

    /// Create a calendar event and return a receipt string.
    func createEvent(
        title: String,
        dateString: String,
        startTime: String,
        endTime: String?,
        location: String?,
        notes: String?
    ) -> String {
        guard hasAccess else {
            return "Error: Calendar access not granted. Please allow access in Settings."
        }

        let event = EKEvent(eventStore: store)
        event.title = title
        event.calendar = store.defaultCalendarForNewEvents

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        if let baseDate = formatter.date(from: dateString) {
            if let startComponents = parseTime(startTime) {
                var components = Calendar.current.dateComponents(
                    [.year, .month, .day], from: baseDate
                )
                components.hour = startComponents.hour
                components.minute = startComponents.minute
                event.startDate = Calendar.current.date(from: components) ?? baseDate
            } else {
                event.startDate = baseDate
            }

            if let endTimeStr = endTime, let endComponents = parseTime(endTimeStr) {
                var components = Calendar.current.dateComponents(
                    [.year, .month, .day], from: baseDate
                )
                components.hour = endComponents.hour
                components.minute = endComponents.minute
                event.endDate = Calendar.current.date(from: components)
                    ?? event.startDate.addingTimeInterval(3600)
            } else {
                event.endDate = event.startDate.addingTimeInterval(3600)
            }
        } else {
            event.startDate = Date()
            event.endDate = Date().addingTimeInterval(3600)
        }

        if let location {
            event.location = location
        }
        if let notes {
            event.notes = notes
        }

        do {
            try store.save(event, span: .thisEvent)
            let dateStr = event.startDate.formatted(date: .abbreviated, time: .shortened)
            return "Event '\(title)' created for \(dateStr)"
                + (location.map { " at \($0)" } ?? "")
        } catch {
            return "Error creating event: \(error.localizedDescription)"
        }
    }

    private func parseTime(_ time: String) -> (hour: Int, minute: Int)? {
        let parts = time.split(separator: ":").compactMap { Int($0) }
        guard parts.count >= 2 else { return nil }
        return (hour: parts[0], minute: parts[1])
    }
}
