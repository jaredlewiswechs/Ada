import AppIntents

/// App Shortcuts provider — these show up in Spotlight, Shortcuts app,
/// and as suggested Siri phrases without any user configuration.
struct AdaShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: InboxToPlanIntent(),
            phrases: [
                "Organize with \(.applicationName)",
                "Plan with \(.applicationName)",
                "Send to \(.applicationName)",
            ],
            shortTitle: "Inbox to Plan",
            systemImageName: "text.badge.checkmark"
        )

        AppShortcut(
            intent: CreateReminderIntent(),
            phrases: [
                "Create reminder with \(.applicationName)",
                "Remind me with \(.applicationName)",
                "Add reminder in \(.applicationName)",
            ],
            shortTitle: "Create Reminder",
            systemImageName: "bell.badge"
        )

        AppShortcut(
            intent: CreateEventIntent(),
            phrases: [
                "Create event with \(.applicationName)",
                "Schedule with \(.applicationName)",
                "Add to calendar with \(.applicationName)",
            ],
            shortTitle: "Create Event",
            systemImageName: "calendar.badge.plus"
        )

        AppShortcut(
            intent: ScanAndExtractIntent(),
            phrases: [
                "Scan with \(.applicationName)",
                "Extract with \(.applicationName)",
            ],
            shortTitle: "Scan & Extract",
            systemImageName: "doc.text.viewfinder"
        )

        AppShortcut(
            intent: DailyBriefIntent(),
            phrases: [
                "Daily brief with \(.applicationName)",
                "Brief me with \(.applicationName)",
                "What's my day \(.applicationName)",
            ],
            shortTitle: "Daily Brief",
            systemImageName: "sun.max"
        )
    }
}
