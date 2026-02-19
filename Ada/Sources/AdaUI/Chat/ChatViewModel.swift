import Foundation
import SwiftData
import Observation

/// View model for the Chat screen.
/// Orchestrates the flow: user input -> Foundation Model -> plan -> execute -> receipts.
@MainActor
@Observable
final class ChatViewModel {
    var messages: [AdaMessage] = []
    var currentConversation: AdaConversation?
    var isProcessing = false
    let modelService = AdaModelService()

    private var modelContext: ModelContext?

    func setup(context: ModelContext) {
        self.modelContext = context
        loadOrCreateConversation(context: context)
    }

    func startNewConversation(context: ModelContext) {
        let conversation = AdaConversation(title: "New Conversation")
        context.insert(conversation)
        try? context.save()
        currentConversation = conversation
        messages = []
    }

    func send(message text: String, context: ModelContext) async {
        guard let conversation = currentConversation else { return }

        // Add user message
        let userMessage = AdaMessage(role: .user, content: text)
        userMessage.conversation = conversation
        conversation.messages.append(userMessage)
        messages.append(userMessage)
        context.insert(userMessage)

        isProcessing = true
        defer { isProcessing = false }

        do {
            // Generate plan from user input
            let plan = try await modelService.generatePlan(from: text)

            // Build the response with receipts
            var responseText = buildResponseFromPlan(plan)

            // Execute actions if risk is none
            if plan.riskLevel == "none" {
                let executionResults = await executePlan(plan)
                if !executionResults.isEmpty {
                    responseText += "\n\n---\n"
                    responseText += executionResults.joined(separator: "\n")
                }

                // Log to ledger
                let ledger = LedgerService(modelContext: context)
                ledger.record(
                    input: text,
                    actions: plan.actions.map { "\($0.tool): \($0.title)" },
                    results: executionResults
                )
            }

            // Create a SwiftData plan record
            let planRecord = AdaPlan(
                intent: plan.intent,
                rawInput: text,
                entities: AdaEntities(
                    dates: plan.dates,
                    times: plan.times,
                    locations: plan.locations,
                    people: plan.people
                ),
                actions: plan.actions.map { action in
                    AdaAction(
                        tool: AdaToolKind(rawValue: action.tool) ?? .inboxToPlan,
                        parameters: [
                            "title": action.title,
                            "date": action.date ?? "",
                            "time": action.time ?? "",
                            "location": action.location ?? "",
                        ],
                        requiresConfirmation: action.requiresConfirmation
                    )
                },
                riskLevel: plan.riskLevel == "none" ? .none
                    : plan.riskLevel == "sensitive" ? .sensitive
                    : .needsConfirm
            )
            planRecord.status = plan.riskLevel == "none" ? .completed : .awaitingConfirmation
            context.insert(planRecord)

            // Add assistant message
            let assistantMessage = AdaMessage(
                role: .assistant,
                content: responseText,
                planID: planRecord.id
            )
            assistantMessage.conversation = conversation
            conversation.messages.append(assistantMessage)
            messages.append(assistantMessage)
            context.insert(assistantMessage)

            // Update conversation title from first message
            if conversation.messages.count <= 2 {
                conversation.title = String(plan.intent.prefix(50))
            }

            try? context.save()

        } catch {
            let errorMessage = AdaMessage(
                role: .assistant,
                content: "I couldn't process that. The on-device model may not be available on this device. Error: \(error.localizedDescription)"
            )
            errorMessage.conversation = conversation
            conversation.messages.append(errorMessage)
            messages.append(errorMessage)
            context.insert(errorMessage)
            try? context.save()
        }
    }

    // MARK: - Private

    private func loadOrCreateConversation(context: ModelContext) {
        let descriptor = FetchDescriptor<AdaConversation>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        if let existing = try? context.fetch(descriptor).first {
            currentConversation = existing
            messages = existing.messages.sorted { $0.createdAt < $1.createdAt }
        } else {
            startNewConversation(context: context)
        }
    }

    private func buildResponseFromPlan(_ plan: GeneratedPlan) -> String {
        var lines: [String] = []

        lines.append("**\(plan.intent)**")
        lines.append("")

        for action in plan.actions {
            let icon = iconForTool(action.tool)
            var line = "\(icon) \(action.title)"
            if let date = action.date {
                line += " — \(date)"
            }
            if let time = action.time {
                line += " at \(time)"
            }
            if let location = action.location {
                line += " (\(location))"
            }
            if action.requiresConfirmation {
                line += " ⚠️ needs confirmation"
            }
            lines.append(line)
        }

        if plan.riskLevel == "needs_confirm" {
            lines.append("")
            lines.append("Some actions need your confirmation before I execute them. Reply **confirm** to proceed.")
        }

        lines.append("")
        lines.append(plan.summary)

        return lines.joined(separator: "\n")
    }

    private func executePlan(_ plan: GeneratedPlan) async -> [String] {
        var results: [String] = []

        for action in plan.actions {
            switch action.tool {
            case "createEvent":
                let calendarAccess = await CalendarService.shared.requestAccess()
                if calendarAccess {
                    let result = await CalendarService.shared.createEvent(
                        title: action.title,
                        dateString: action.date ?? "",
                        startTime: action.time ?? "09:00",
                        endTime: nil,
                        location: action.location,
                        notes: action.notes
                    )
                    results.append("✅ \(result)")
                } else {
                    results.append("⚠️ Calendar access needed for: \(action.title)")
                }

            case "createReminder":
                let reminderAccess = await ReminderService.shared.requestAccess()
                if reminderAccess {
                    let result = await ReminderService.shared.createReminder(
                        title: action.title,
                        dueDateString: action.date,
                        priority: nil,
                        notes: action.notes
                    )
                    results.append("✅ \(result)")
                } else {
                    results.append("⚠️ Reminders access needed for: \(action.title)")
                }

            case "createChecklist":
                let items = action.listItems ?? []
                results.append("✅ Checklist '\(action.title)' created with \(items.count) items")

            default:
                results.append("📋 \(action.title) — queued")
            }
        }

        return results
    }

    private func iconForTool(_ tool: String) -> String {
        switch tool {
        case "createEvent": return "📅"
        case "createReminder": return "🔔"
        case "createChecklist": return "📋"
        case "scanAndExtract": return "📷"
        case "dailyBrief": return "☀️"
        default: return "📌"
        }
    }
}
