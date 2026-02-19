import SwiftUI
import SwiftData

/// The Inbox shows captured items awaiting user approval before execution.
/// Items that need confirmation land here; the user can approve, edit, or dismiss.
struct InboxView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<AdaPlan> { $0.status == "awaitingConfirmation" },
        sort: \AdaPlan.createdAt,
        order: .reverse
    )
    private var pendingPlans: [AdaPlan]

    @Query(
        filter: #Predicate<AdaItem> { $0.status == "pending" },
        sort: \AdaItem.createdAt,
        order: .reverse
    )
    private var pendingItems: [AdaItem]

    var body: some View {
        NavigationStack {
            List {
                if pendingPlans.isEmpty && pendingItems.isEmpty {
                    emptyState
                }

                if !pendingPlans.isEmpty {
                    Section("Plans Awaiting Confirmation") {
                        ForEach(pendingPlans) { plan in
                            PlanRowView(plan: plan)
                                .swipeActions(edge: .trailing) {
                                    Button("Approve", systemImage: "checkmark") {
                                        approvePlan(plan)
                                    }
                                    .tint(.green)
                                }
                                .swipeActions(edge: .leading) {
                                    Button("Dismiss", systemImage: "xmark", role: .destructive) {
                                        dismissPlan(plan)
                                    }
                                }
                        }
                    }
                }

                if !pendingItems.isEmpty {
                    Section("Pending Items") {
                        ForEach(pendingItems) { item in
                            ItemRowView(item: item)
                                .swipeActions(edge: .trailing) {
                                    Button("Complete", systemImage: "checkmark") {
                                        completeItem(item)
                                    }
                                    .tint(.green)
                                }
                                .swipeActions(edge: .leading) {
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        modelContext.delete(item)
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle("Inbox")
            .toolbar {
                if !pendingPlans.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Approve All") {
                            for plan in pendingPlans {
                                approvePlan(plan)
                            }
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Inbox Clear", systemImage: "tray")
        } description: {
            Text("Items that need your approval before Ada executes them will appear here.")
        }
    }

    private func approvePlan(_ plan: AdaPlan) {
        plan.status = .executing
        Task {
            // Execute plan actions
            plan.status = .completed
            plan.executedAt = Date()
            try? modelContext.save()
        }
    }

    private func dismissPlan(_ plan: AdaPlan) {
        plan.status = .failed
        try? modelContext.save()
    }

    private func completeItem(_ item: AdaItem) {
        item.status = .completed
        item.completedAt = Date()
        item.updatedAt = Date()
        try? modelContext.save()
    }
}

// MARK: - Row Views

struct PlanRowView: View {
    let plan: AdaPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(plan.intent)
                .font(.headline)

            Text("\(plan.actions.count) action\(plan.actions.count == 1 ? "" : "s")")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach(plan.actions) { action in
                    Label(action.tool.rawValue, systemImage: iconForTool(action.tool))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            if plan.riskLevel == .needsConfirm {
                Label("Needs confirmation", systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }

    private func iconForTool(_ tool: AdaToolKind) -> String {
        switch tool {
        case .createEvent: return "calendar"
        case .createReminder: return "bell"
        case .createChecklist: return "list.bullet"
        case .scanAndExtract: return "doc.text.viewfinder"
        case .dailyBrief: return "sun.max"
        case .inboxToPlan: return "text.badge.checkmark"
        }
    }
}

struct ItemRowView: View {
    let item: AdaItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.kind.systemImage)
                .foregroundStyle(.accent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.body)

                if let dueDate = item.dueDate {
                    Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    InboxView()
        .modelContainer(for: [AdaPlan.self, AdaItem.self], inMemory: true)
}
