import AppIntents
import Foundation

/// App Intent: Scan text and extract structured information.
/// This powers the "Scan -> Structure" feature from Shortcuts and Spotlight.
struct ScanAndExtractIntent: AppIntent {
    static let title: LocalizedStringResource = "Scan & Extract with Ada"
    static let description: IntentDescription = "Extract tasks, dates, and contacts from text or a scanned document."
    static let openAppWhenRun: Bool = true

    @Parameter(title: "Text to Analyze")
    var inputText: String

    static var parameterSummary: some ParameterSummary {
        Summary("Extract information from \(\.$inputText)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let service = AdaModelService()
        let extracted = try await service.extractContent(from: inputText)

        var summary = "Scanned \(extracted.documentType):\n"
        summary += extracted.summary + "\n"

        if !extracted.tasks.isEmpty {
            summary += "\nTasks found: \(extracted.tasks.count)"
            for task in extracted.tasks {
                summary += "\n  - \(task.title)"
                if let due = task.dueDate {
                    summary += " (due: \(due))"
                }
            }
        }

        if !extracted.dates.isEmpty {
            summary += "\nDates: \(extracted.dates.joined(separator: ", "))"
        }

        if !extracted.contacts.isEmpty {
            summary += "\nContacts: \(extracted.contacts.joined(separator: ", "))"
        }

        return .result(dialog: "\(summary)")
    }
}
