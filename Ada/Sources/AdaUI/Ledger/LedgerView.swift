import SwiftUI
import SwiftData

/// The Ledger is Ada's audit trail — every action taken is recorded here.
/// This builds trust: Ada never pretends it did something it didn't.
struct LedgerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AdaLedgerEntry.timestamp, order: .reverse)
    private var entries: [AdaLedgerEntry]

    @State private var showingExport = false
    @State private var exportData: Data?

    var body: some View {
        NavigationStack {
            List {
                if entries.isEmpty {
                    emptyState
                } else {
                    ForEach(groupedEntries, id: \.key) { date, dayEntries in
                        Section(date.formatted(date: .abbreviated, time: .omitted)) {
                            ForEach(dayEntries) { entry in
                                LedgerEntryRow(entry: entry)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Ledger")
            .toolbar {
                if !entries.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Export", systemImage: "square.and.arrow.up") {
                            exportLedger()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingExport) {
                if let data = exportData {
                    ShareSheet(data: data)
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Activity Yet", systemImage: "list.clipboard")
        } description: {
            Text("When Ada creates events, reminders, or checklists, every action is logged here for full transparency.")
        }
    }

    private var groupedEntries: [(key: Date, value: [AdaLedgerEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    private func exportLedger() {
        let ledger = LedgerService(modelContext: modelContext)
        if let data = try? ledger.exportJSON() {
            exportData = data
            showingExport = true
        }
    }
}

struct LedgerEntryRow: View {
    let entry: AdaLedgerEntry

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.inputPreview)
                        .font(.body)
                        .lineLimit(isExpanded ? nil : 2)

                    Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                Text("\(entry.actions.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Capsule())
            }

            if isExpanded {
                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    Text("Actions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    ForEach(Array(entry.actions.enumerated()), id: \.offset) { _, action in
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.accent)
                            Text(action)
                                .font(.callout)
                        }
                    }

                    if !entry.results.isEmpty {
                        Text("Results")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .padding(.top, 4)

                        ForEach(Array(entry.results.enumerated()), id: \.offset) { _, result in
                            Text(result)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        }
    }
}

/// A simple share sheet wrapper for exporting ledger data.
struct ShareSheet: UIViewControllerRepresentable {
    let data: Data

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("ada-ledger.json")
        try? data.write(to: url)
        return UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    LedgerView()
        .modelContainer(for: AdaLedgerEntry.self, inMemory: true)
}
