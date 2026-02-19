import SwiftUI

/// Automations screen — saved routines that users can trigger as Shortcuts.
/// Shows pre-built automations and lets users create custom ones.
struct AutomationsView: View {
    @State private var automations = AutomationTemplate.defaults

    var body: some View {
        NavigationStack {
            List {
                Section {
                    quickActionsRow
                } header: {
                    Text("Quick Actions")
                } footer: {
                    Text("These actions run immediately when tapped.")
                }

                Section("Routines") {
                    ForEach(automations.filter { $0.category == .routine }) { automation in
                        AutomationRow(automation: automation)
                    }
                }

                Section("Shortcuts Integration") {
                    ForEach(automations.filter { $0.category == .shortcut }) { automation in
                        AutomationRow(automation: automation)
                    }
                }

                Section {
                    NavigationLink {
                        CreateAutomationView()
                    } label: {
                        Label("Create Custom Automation", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("Automations")
        }
    }

    private var quickActionsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Daily Brief",
                    icon: "sun.max.fill",
                    color: .orange
                ) {
                    // Trigger DailyBriefIntent
                }

                QuickActionButton(
                    title: "Quick Capture",
                    icon: "camera.fill",
                    color: .blue
                ) {
                    // Open capture
                }

                QuickActionButton(
                    title: "Inbox to Plan",
                    icon: "text.badge.checkmark",
                    color: .purple
                ) {
                    // Open paste-to-plan
                }
            }
            .padding(.vertical, 4)
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 48, height: 48)
                    .background(color.opacity(0.15))
                    .foregroundStyle(color)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct AutomationRow: View {
    let automation: AutomationTemplate

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: automation.icon)
                .font(.title3)
                .foregroundStyle(.accent)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(automation.title)
                    .font(.body)
                Text(automation.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if automation.category == .shortcut {
                Image(systemName: "arrow.up.forward.app")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Data

struct AutomationTemplate: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let category: AutomationCategory

    enum AutomationCategory {
        case routine
        case shortcut
    }

    static let defaults: [AutomationTemplate] = [
        AutomationTemplate(
            title: "Morning Brief",
            subtitle: "Summarize today's events and top tasks",
            icon: "sun.max",
            category: .routine
        ),
        AutomationTemplate(
            title: "End of Day Review",
            subtitle: "Review what was completed and what carries over",
            icon: "moon.stars",
            category: .routine
        ),
        AutomationTemplate(
            title: "Weekly Planning",
            subtitle: "Review the week ahead and set priorities",
            icon: "calendar.badge.clock",
            category: .routine
        ),
        AutomationTemplate(
            title: "Quick Capture to Inbox",
            subtitle: "Opens in Shortcuts for one-tap capture",
            icon: "bolt.fill",
            category: .shortcut
        ),
        AutomationTemplate(
            title: "Scan Document",
            subtitle: "Camera scan -> structured extraction",
            icon: "doc.text.viewfinder",
            category: .shortcut
        ),
        AutomationTemplate(
            title: "Share to Ada",
            subtitle: "Send text from any app to Ada's inbox",
            icon: "square.and.arrow.up",
            category: .shortcut
        ),
    ]
}

/// Placeholder for custom automation creation.
struct CreateAutomationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 48))
                .foregroundStyle(.accent)

            Text("Custom Automations")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Combine Ada's intents into custom Shortcuts workflows. Build chains like:\n\nScan -> Extract -> Create Events -> Set Reminders")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                // Open Shortcuts app with Ada actions
            } label: {
                Label("Open Shortcuts", systemImage: "arrow.up.forward.app")
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Create Automation")
    }
}

#Preview {
    AutomationsView()
}
