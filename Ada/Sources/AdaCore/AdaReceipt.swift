import Foundation
import SwiftData

/// A receipt proves an action was executed.
/// Ada shows these after each plan execution so users always know what happened.
@Model
final class AdaReceipt {
    var id: UUID
    var actionTool: String
    var actionDescription: String
    var resultSummary: String
    var success: Bool
    var createdAt: Date
    var externalID: String?

    @Relationship(inverse: \AdaPlan.receipts)
    var plan: AdaPlan?

    init(
        actionTool: String,
        actionDescription: String,
        resultSummary: String,
        success: Bool,
        externalID: String? = nil
    ) {
        self.id = UUID()
        self.actionTool = actionTool
        self.actionDescription = actionDescription
        self.resultSummary = resultSummary
        self.success = success
        self.createdAt = Date()
        self.externalID = externalID
    }
}
