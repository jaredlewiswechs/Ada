import AppIntents
import Foundation

/// App Intent: Generate a daily briefing.
/// Surfaces in Shortcuts and Widgets for morning routines.
struct DailyBriefIntent: AppIntent {
    static let title: LocalizedStringResource = "Daily Brief with Ada"
    static let description: IntentDescription = "Get a summary of your day including events, tasks, and priorities."
    static let openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let service = AdaModelService()

        // Gather today's items from EventKit
        let calendarAccess = await CalendarService.shared.requestAccess()
        let reminderAccess = await ReminderService.shared.requestAccess()

        var events: [String] = []
        var reminders: [String] = []

        if calendarAccess {
            events = ["(Events loaded from calendar)"]
        }
        if reminderAccess {
            reminders = ["(Reminders loaded)"]
        }

        let brief = try await service.generateDailyBrief(
            events: events,
            tasks: [],
            reminders: reminders
        )

        return .result(
            dialog: "\(brief.greeting)\n\n\(brief.summary)"
        ) {
            DailyBriefSnippetView(brief: brief)
        }
    }
}

import SwiftUI

/// Snippet view shown inline in Shortcuts/Siri for the daily brief.
struct DailyBriefSnippetView: View {
    let brief: DailyBriefOutput

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(brief.greeting)
                .font(.headline)

            if !brief.topPriorities.isEmpty {
                Text("Top Priorities")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ForEach(Array(brief.topPriorities.enumerated()), id: \.offset) { index, priority in
                    HStack(spacing: 8) {
                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(width: 20, height: 20)
                            .background(Color.accentColor.opacity(0.2))
                            .clipShape(Circle())
                        Text(priority)
                            .font(.callout)
                    }
                }
            }

            if !brief.upcomingEvents.isEmpty {
                Text("Upcoming")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ForEach(Array(brief.upcomingEvents.enumerated()), id: \.offset) { _, event in
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.accentColor)
                        VStack(alignment: .leading) {
                            Text(event.title)
                                .font(.callout)
                            Text(event.time)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
