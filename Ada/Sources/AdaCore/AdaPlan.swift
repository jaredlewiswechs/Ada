import Foundation
import SwiftData

/// An Ada Plan represents a structured interpretation of user input.
/// The on-device Foundation Model produces this from natural language,
/// then Ada executes each action and generates receipts.
@Model
final class AdaPlan {
    var id: UUID
    var intent: String
    var rawInput: String
    var entities: AdaEntities
    var actions: [AdaAction]
    var riskLevel: AdaRiskLevel
    var status: AdaPlanStatus
    var createdAt: Date
    var executedAt: Date?

    @Relationship(deleteRule: .cascade)
    var items: [AdaItem]

    @Relationship(deleteRule: .cascade)
    var receipts: [AdaReceipt]

    init(
        intent: String,
        rawInput: String,
        entities: AdaEntities = AdaEntities(),
        actions: [AdaAction] = [],
        riskLevel: AdaRiskLevel = .none
    ) {
        self.id = UUID()
        self.intent = intent
        self.rawInput = rawInput
        self.entities = entities
        self.actions = actions
        self.riskLevel = riskLevel
        self.status = .draft
        self.createdAt = Date()
        self.items = []
        self.receipts = []
    }
}

/// Extracted entities from user input.
struct AdaEntities: Codable, Hashable {
    var dates: [String]
    var times: [String]
    var locations: [String]
    var people: [String]
    var amounts: [String]

    init(
        dates: [String] = [],
        times: [String] = [],
        locations: [String] = [],
        people: [String] = [],
        amounts: [String] = []
    ) {
        self.dates = dates
        self.times = times
        self.locations = locations
        self.people = people
        self.amounts = amounts
    }
}

/// A single action Ada will execute as part of a plan.
struct AdaAction: Codable, Identifiable, Hashable {
    var id: UUID
    var tool: AdaToolKind
    var parameters: [String: String]
    var requiresConfirmation: Bool

    init(
        tool: AdaToolKind,
        parameters: [String: String] = [:],
        requiresConfirmation: Bool = false
    ) {
        self.id = UUID()
        self.tool = tool
        self.parameters = parameters
        self.requiresConfirmation = requiresConfirmation
    }
}

enum AdaToolKind: String, Codable, CaseIterable {
    case createEvent
    case createReminder
    case createChecklist
    case scanAndExtract
    case dailyBrief
    case inboxToPlan
}

enum AdaRiskLevel: String, Codable {
    case none
    case needsConfirm
    case sensitive
}

enum AdaPlanStatus: String, Codable {
    case draft
    case awaitingConfirmation
    case executing
    case completed
    case failed
}
