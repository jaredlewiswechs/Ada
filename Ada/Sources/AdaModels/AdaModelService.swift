import Foundation
import FoundationModels

/// The central on-device intelligence service.
/// Uses Apple's Foundation Models framework to process user input
/// entirely on-device — no data leaves the phone.
@MainActor
@Observable
final class AdaModelService {
    private(set) var isAvailable: Bool = false
    private(set) var isProcessing: Bool = false

    private var session: LanguageModelSession?

    static let systemInstructions = """
        You are Ada, a personal operations assistant. Your job is to take messy, \
        unstructured input from the user and produce a clean, structured plan of actions.

        You are a task compiler, not a chatbot. Focus on:
        - Extracting dates, times, locations, people, and amounts
        - Mapping input to concrete actions (create events, reminders, checklists)
        - Identifying what needs user confirmation vs. what's safe to execute
        - Being precise and never hallucinating actions the user didn't request

        Always err on the side of asking for confirmation when the intent is ambiguous.
        """

    init() {
        checkAvailability()
    }

    /// Check if the on-device model is available on this device.
    func checkAvailability() {
        let model = SystemLanguageModel.default
        isAvailable = model.isAvailable
    }

    /// Create a fresh session with Ada's system instructions.
    func createSession() -> LanguageModelSession {
        let newSession = LanguageModelSession(
            instructions: Self.systemInstructions
        )
        self.session = newSession
        return newSession
    }

    /// Generate a structured plan from user input.
    func generatePlan(from input: String) async throws -> GeneratedPlan {
        isProcessing = true
        defer { isProcessing = false }

        let session = createSession()

        let prompt = """
            Parse the following user input and create a structured plan of actions:

            "\(input)"

            Extract all dates, times, locations, people, and amounts. \
            Map each request to the appropriate tool (createEvent, createReminder, \
            createChecklist, etc.). Flag anything that needs confirmation.
            """

        let response = try await session.respond(
            to: prompt,
            generating: GeneratedPlan.self
        )

        return response
    }

    /// Extract structured content from scanned/OCR text.
    func extractContent(from ocrText: String) async throws -> ExtractedContent {
        isProcessing = true
        defer { isProcessing = false }

        let session = createSession()

        let prompt = """
            Analyze the following text extracted from a scanned document. \
            Identify the document type, extract all tasks, dates, contacts, \
            and amounts. Produce a clean, formatted version of the content.

            Scanned text:
            "\(ocrText)"
            """

        let response = try await session.respond(
            to: prompt,
            generating: ExtractedContent.self
        )

        return response
    }

    /// Generate a daily briefing from current items and events.
    func generateDailyBrief(
        events: [String],
        tasks: [String],
        reminders: [String]
    ) async throws -> DailyBriefOutput {
        isProcessing = true
        defer { isProcessing = false }

        let session = createSession()

        let prompt = """
            Create a daily briefing. Here is what the user has today:

            Events: \(events.joined(separator: ", "))
            Tasks: \(tasks.joined(separator: ", "))
            Reminders: \(reminders.joined(separator: ", "))

            Summarize the day, identify the top 3 priorities, and list upcoming events.
            """

        let response = try await session.respond(
            to: prompt,
            generating: DailyBriefOutput.self
        )

        return response
    }

    /// Stream a natural language response for the chat interface.
    func streamResponse(to input: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let session = self.session ?? self.createSession()
                    let stream = session.streamResponse(to: input)

                    for try await partial in stream {
                        continuation.yield(partial.content)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
