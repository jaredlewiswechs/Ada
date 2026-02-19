import SwiftUI
import SwiftData

/// Ada: Personal Ops + Capture
/// A compiler for life — turning messy human input into structured, verified actions.
@main
struct AdaApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                AdaItem.self,
                AdaPlan.self,
                AdaReceipt.self,
                AdaLedgerEntry.self,
                AdaConversation.self,
                AdaMessage.self,
            ])
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to initialize model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
