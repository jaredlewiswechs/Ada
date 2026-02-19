import SwiftUI

/// Root navigation for Ada.
/// Four tabs: Chat, Inbox, Ledger, Automations.
struct ContentView: View {
    @State private var selectedTab: AdaTab = .chat

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Chat", systemImage: "bubble.left.and.text.bubble.right", value: .chat) {
                ChatView()
            }

            Tab("Inbox", systemImage: "tray.and.arrow.down", value: .inbox) {
                InboxView()
            }

            Tab("Ledger", systemImage: "list.clipboard", value: .ledger) {
                LedgerView()
            }

            Tab("Automations", systemImage: "gearshape.2", value: .automations) {
                AutomationsView()
            }
        }
        .tint(.accentColor)
    }
}

enum AdaTab: String, Hashable {
    case chat
    case inbox
    case ledger
    case automations
}

#Preview {
    ContentView()
        .modelContainer(for: [
            AdaItem.self,
            AdaPlan.self,
            AdaReceipt.self,
            AdaLedgerEntry.self,
            AdaConversation.self,
            AdaMessage.self,
        ], inMemory: true)
}
