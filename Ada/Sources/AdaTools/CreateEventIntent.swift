import AppIntents
import Foundation

/// App Intent: Create a calendar event via Ada.
/// Surfaces in Shortcuts, Spotlight, and Siri.
struct CreateEventIntent: AppIntent {
    static let title: LocalizedStringResource = "Create Event with Ada"
    static let description: IntentDescription = "Create a calendar event using Ada's intelligent parsing."
    static let openAppWhenRun: Bool = false

    @Parameter(title: "Event Description")
    var eventDescription: String

    @Parameter(title: "Date", description: "The date for the event")
    var date: Date?

    @Parameter(title: "Location")
    var location: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Create event from \(\.$eventDescription)") {
            \.$date
            \.$location
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let service = AdaModelService()

        var prompt = eventDescription
        if let date {
            prompt += " on \(date.formatted(date: .abbreviated, time: .omitted))"
        }
        if let location {
            prompt += " at \(location)"
        }

        let plan = try await service.generatePlan(from: prompt)

        // Execute the first createEvent action
        let calendarAccess = await CalendarService.shared.requestAccess()
        var resultMessage = ""

        if calendarAccess {
            for action in plan.actions where action.tool == "createEvent" {
                let result = await CalendarService.shared.createEvent(
                    title: action.title,
                    dateString: action.date ?? "",
                    startTime: action.time ?? "09:00",
                    endTime: nil,
                    location: action.location,
                    notes: action.notes
                )
                resultMessage = result
            }
        } else {
            resultMessage = "Calendar access is required. Please grant access in Settings."
        }

        if resultMessage.isEmpty {
            resultMessage = "Plan created: \(plan.summary)"
        }

        return .result(
            dialog: "\(resultMessage)"
        ) {
            IntentReceiptView(
                title: plan.intent,
                summary: resultMessage,
                success: !resultMessage.contains("Error")
            )
        }
    }
}
