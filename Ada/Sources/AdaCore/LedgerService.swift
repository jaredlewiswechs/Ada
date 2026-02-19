import Foundation
import SwiftData
import CryptoKit

/// Service for recording immutable audit trail entries.
/// Every action Ada executes is logged to the ledger for transparency.
@MainActor
final class LedgerService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Record an action to the ledger.
    func record(
        input: String,
        actions: [String],
        results: [String],
        planID: UUID? = nil
    ) {
        let hash = SHA256.hash(data: Data(input.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()

        let preview = String(input.prefix(200))

        let entry = AdaLedgerEntry(
            inputHash: hash,
            inputPreview: preview,
            actions: actions,
            results: results,
            planID: planID
        )

        modelContext.insert(entry)
        try? modelContext.save()
    }

    /// Export ledger as JSON data.
    func exportJSON() throws -> Data {
        let descriptor = FetchDescriptor<AdaLedgerEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let entries = try modelContext.fetch(descriptor)

        struct ExportEntry: Encodable {
            let timestamp: Date
            let inputHash: String
            let inputPreview: String
            let actions: [String]
            let results: [String]
        }

        let exportable = entries.map { entry in
            ExportEntry(
                timestamp: entry.timestamp,
                inputHash: entry.inputHash,
                inputPreview: entry.inputPreview,
                actions: entry.actions,
                results: entry.results
            )
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(exportable)
    }
}
