import SwiftUI

/// A receipt card shown after Ada executes an action.
/// Displays what was done, building trust through transparency.
struct ReceiptCardView: View {
    let receipt: AdaReceipt

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: receipt.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title3)
                .foregroundStyle(receipt.success ? .green : .red)

            VStack(alignment: .leading, spacing: 2) {
                Text(receipt.actionDescription)
                    .font(.callout)
                    .fontWeight(.medium)

                Text(receipt.resultSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let externalID = receipt.externalID {
                    Text("ID: \(externalID)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .monospaced()
                }
            }

            Spacer()

            Text(receipt.createdAt.formatted(date: .omitted, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// A group of receipts shown together after a plan execution.
struct ReceiptGroupView: View {
    let receipts: [AdaReceipt]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Receipts")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Spacer()

                let successCount = receipts.filter(\.success).count
                Text("\(successCount)/\(receipts.count) completed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(receipts) { receipt in
                ReceiptCardView(receipt: receipt)
            }
        }
    }
}

#Preview {
    VStack {
        ReceiptCardView(
            receipt: AdaReceipt(
                actionTool: "createEvent",
                actionDescription: "Dentist appointment",
                resultSummary: "Event created for Thu, Jan 30 at 2:00 PM",
                success: true,
                externalID: "EK-12345"
            )
        )

        ReceiptCardView(
            receipt: AdaReceipt(
                actionTool: "createReminder",
                actionDescription: "Reminder: Dentist tomorrow",
                resultSummary: "Reminder set for Wed, Jan 29 at 8:00 PM",
                success: true
            )
        )
    }
    .padding()
}
