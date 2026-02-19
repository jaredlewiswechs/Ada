import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Quick Actions Widget

/// A widget providing quick action buttons for Scan, Add, and Daily Brief.
/// These appear on the home screen and lock screen.
struct QuickActionsWidget: Widget {
    let kind: String = "com.ada.app.quickactions"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickActionsProvider()) { entry in
            QuickActionsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Ada Quick Actions")
        .description("Quick access to Scan, Add, and Daily Brief.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

struct QuickActionsEntry: TimelineEntry {
    let date: Date
}

struct QuickActionsProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickActionsEntry {
        QuickActionsEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickActionsEntry) -> Void) {
        completion(QuickActionsEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickActionsEntry>) -> Void) {
        let entry = QuickActionsEntry(date: .now)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct QuickActionsWidgetView: View {
    let entry: QuickActionsEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .accessoryRectangular:
            accessoryWidget
        default:
            smallWidget
        }
    }

    private var smallWidget: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.accent)
                Text("Ada")
                    .font(.headline)
                Spacer()
            }

            Spacer()

            HStack(spacing: 12) {
                Link(destination: URL(string: "ada://scan")!) {
                    VStack(spacing: 4) {
                        Image(systemName: "camera.fill")
                            .font(.title3)
                        Text("Scan")
                            .font(.caption2)
                    }
                }

                Link(destination: URL(string: "ada://add")!) {
                    VStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Add")
                            .font(.caption2)
                    }
                }

                Link(destination: URL(string: "ada://brief")!) {
                    VStack(spacing: 4) {
                        Image(systemName: "sun.max.fill")
                            .font(.title3)
                        Text("Brief")
                            .font(.caption2)
                    }
                }
            }
        }
        .padding()
    }

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.accent)
                    Text("Ada")
                        .font(.headline)
                }
                Text("What needs organizing?")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 16) {
                Link(destination: URL(string: "ada://scan")!) {
                    VStack(spacing: 6) {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .frame(width: 40, height: 40)
                            .background(Color.blue.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text("Scan")
                            .font(.caption2)
                    }
                }

                Link(destination: URL(string: "ada://add")!) {
                    VStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .frame(width: 40, height: 40)
                            .background(Color.green.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text("Add")
                            .font(.caption2)
                    }
                }

                Link(destination: URL(string: "ada://brief")!) {
                    VStack(spacing: 6) {
                        Image(systemName: "sun.max.fill")
                            .font(.title2)
                            .frame(width: 40, height: 40)
                            .background(Color.orange.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text("Brief")
                            .font(.caption2)
                    }
                }
            }
        }
        .padding()
    }

    private var accessoryWidget: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
            VStack(alignment: .leading) {
                Text("Ada")
                    .font(.headline)
                Text("Quick Capture")
                    .font(.caption)
            }
        }
    }
}

// MARK: - Widget Bundle

@main
struct AdaWidgetBundle: WidgetBundle {
    var body: some Widget {
        QuickActionsWidget()
    }
}

#Preview(as: .systemSmall) {
    QuickActionsWidget()
} timeline: {
    QuickActionsEntry(date: .now)
}

#Preview(as: .systemMedium) {
    QuickActionsWidget()
} timeline: {
    QuickActionsEntry(date: .now)
}
