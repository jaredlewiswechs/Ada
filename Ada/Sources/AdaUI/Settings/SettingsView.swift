import SwiftUI

/// Settings screen with privacy controls, permissions management,
/// and ledger export. Privacy posture front and center.
struct SettingsView: View {
    @State private var calendarAccess = false
    @State private var remindersAccess = false
    @State private var cameraAccess = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.title)
                            .foregroundStyle(.green)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("On-Device Processing")
                                .font(.headline)
                            Text("All intelligence runs on your device. Nothing leaves your phone unless you choose to share it.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Privacy")
                }

                Section("Permissions") {
                    PermissionRow(
                        title: "Calendar",
                        icon: "calendar",
                        description: "Create and manage events",
                        isGranted: calendarAccess
                    ) {
                        Task {
                            calendarAccess = await CalendarService.shared.requestAccess()
                        }
                    }

                    PermissionRow(
                        title: "Reminders",
                        icon: "bell",
                        description: "Create and manage reminders",
                        isGranted: remindersAccess
                    ) {
                        Task {
                            remindersAccess = await ReminderService.shared.requestAccess()
                        }
                    }

                    PermissionRow(
                        title: "Camera",
                        icon: "camera",
                        description: "Scan documents for extraction",
                        isGranted: cameraAccess
                    ) {
                        // Camera permission is requested when first used
                    }
                }

                Section("Data") {
                    NavigationLink {
                        LedgerView()
                    } label: {
                        Label("View Audit Ledger", systemImage: "list.clipboard")
                    }

                    Button {
                        // Export all data
                    } label: {
                        Label("Export All Data", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        // Clear all data
                    } label: {
                        Label("Clear All Data", systemImage: "trash")
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Model")
                        Spacer()
                        Text("On-Device Foundation Model")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Processing")
                        Spacer()
                        Text("100% On-Device")
                            .foregroundStyle(.green)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct PermissionRow: View {
    let title: String
    let icon: String
    let description: String
    let isGranted: Bool
    let requestAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isGranted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Button("Enable") {
                    requestAction()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }
}

#Preview {
    SettingsView()
}
