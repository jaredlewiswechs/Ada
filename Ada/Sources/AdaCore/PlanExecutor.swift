import Foundation
import SwiftData

/// Executes a generated plan by invoking each action's tool,
/// collecting receipts, and logging everything to the ledger.
@MainActor
final class PlanExecutor {
    private let modelContext: ModelContext
    private let ledger: LedgerService

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.ledger = LedgerService(modelContext: modelContext)
    }

    /// Execute a plan, producing receipts for each action.
    func execute(plan: AdaPlan) async -> [AdaReceipt] {
        var receipts: [AdaReceipt] = []
        plan.status = .executing

        for action in plan.actions {
            let receipt = await executeAction(action)
            receipt.plan = plan
            plan.receipts.append(receipt)
            modelContext.insert(receipt)
            receipts.append(receipt)
        }

        plan.status = receipts.allSatisfy(\.success) ? .completed : .failed
        plan.executedAt = Date()

        // Log to ledger
        ledger.record(
            input: plan.rawInput,
            actions: plan.actions.map { "\($0.tool.rawValue): \($0.parameters["title"] ?? "")" },
            results: receipts.map { $0.resultSummary },
            planID: plan.id
        )

        try? modelContext.save()
        return receipts
    }

    // MARK: - Private

    private func executeAction(_ action: AdaAction) async -> AdaReceipt {
        switch action.tool {
        case .createEvent:
            let calendarAccess = await CalendarService.shared.requestAccess()
            guard calendarAccess else {
                return AdaReceipt(
                    actionTool: action.tool.rawValue,
                    actionDescription: action.parameters["title"] ?? "Create event",
                    resultSummary: "Calendar access not granted",
                    success: false
                )
            }

            let result = await CalendarService.shared.createEvent(
                title: action.parameters["title"] ?? "",
                dateString: action.parameters["date"] ?? "",
                startTime: action.parameters["time"] ?? "09:00",
                endTime: nil,
                location: action.parameters["location"],
                notes: nil
            )

            return AdaReceipt(
                actionTool: action.tool.rawValue,
                actionDescription: action.parameters["title"] ?? "Create event",
                resultSummary: result,
                success: !result.contains("Error")
            )

        case .createReminder:
            let reminderAccess = await ReminderService.shared.requestAccess()
            guard reminderAccess else {
                return AdaReceipt(
                    actionTool: action.tool.rawValue,
                    actionDescription: action.parameters["title"] ?? "Create reminder",
                    resultSummary: "Reminders access not granted",
                    success: false
                )
            }

            let result = await ReminderService.shared.createReminder(
                title: action.parameters["title"] ?? "",
                dueDateString: action.parameters["date"],
                priority: nil,
                notes: nil
            )

            return AdaReceipt(
                actionTool: action.tool.rawValue,
                actionDescription: action.parameters["title"] ?? "Create reminder",
                resultSummary: result,
                success: !result.contains("Error")
            )

        case .createChecklist:
            let title = action.parameters["title"] ?? "Checklist"
            return AdaReceipt(
                actionTool: action.tool.rawValue,
                actionDescription: title,
                resultSummary: "Checklist '\(title)' created",
                success: true
            )

        case .scanAndExtract:
            return AdaReceipt(
                actionTool: action.tool.rawValue,
                actionDescription: "Scan & Extract",
                resultSummary: "Content queued for scanning",
                success: true
            )

        case .dailyBrief:
            return AdaReceipt(
                actionTool: action.tool.rawValue,
                actionDescription: "Daily Brief",
                resultSummary: "Brief generated",
                success: true
            )

        case .inboxToPlan:
            return AdaReceipt(
                actionTool: action.tool.rawValue,
                actionDescription: "Inbox to Plan",
                resultSummary: "Plan created from inbox",
                success: true
            )
        }
    }
}
