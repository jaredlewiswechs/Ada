import Foundation
import SwiftData

/// A ledger entry is an immutable audit trail record.
/// Every action Ada takes is logged here for transparency and user trust.
@Model
final class AdaLedgerEntry {
    var id: UUID
    var timestamp: Date
    var inputHash: String
    var inputPreview: String
    var actions: [String]
    var results: [String]
    var planID: UUID?

    init(
        inputHash: String,
        inputPreview: String,
        actions: [String],
        results: [String],
        planID: UUID? = nil
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.inputHash = inputHash
        self.inputPreview = inputPreview
        self.actions = actions
        self.results = results
        self.planID = planID
    }
}
