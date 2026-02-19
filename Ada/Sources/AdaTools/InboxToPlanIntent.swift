import AppIntents
import Foundation

/// App Intent: Convert pasted text into a structured plan.
/// The signature "One Message to Organized" feature.
struct InboxToPlanIntent: AppIntent {
    static let title: LocalizedStringResource = "Inbox to Plan with Ada"
    static let description: IntentDescription = "Paste messy text and Ada turns it into a structured plan with actions."
    static let openAppWhenRun: Bool = true

    @Parameter(title: "Text to Organize")
    var inputText: String

    static var parameterSummary: some ParameterSummary {
        Summary("Organize \(\.$inputText)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let service = AdaModelService()
        let plan = try await service.generatePlan(from: inputText)

        var summary = "Plan: \(plan.intent)\n"
        summary += "Risk: \(plan.riskLevel)\n\n"
        summary += "Actions:\n"

        for (index, action) in plan.actions.enumerated() {
            summary += "\(index + 1). \(action.tool): \(action.title)"
            if action.requiresConfirmation {
                summary += " (needs confirmation)"
            }
            summary += "\n"
        }

        summary += "\n\(plan.summary)"

        return .result(dialog: "\(summary)")
    }
}
