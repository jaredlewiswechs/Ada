import SwiftUI

/// A snippet view displayed inline in Shortcuts/Siri results
/// showing the receipt of an executed action.
struct IntentReceiptView: View {
    let title: String
    let summary: String
    let success: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title2)
                .foregroundStyle(success ? .green : .red)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(summary)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}
