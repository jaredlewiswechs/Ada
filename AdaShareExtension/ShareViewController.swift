import SwiftUI
import UniformTypeIdentifiers

/// Share Extension: "Send to Ada"
/// Receives shared text from any app and sends it to Ada's inbox for processing.
/// This is a key "everywhere" entry point — users share content directly to Ada.
@objc(ShareViewController)
class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let hostingController = UIHostingController(
            rootView: ShareExtensionView(
                extensionContext: extensionContext
            )
        )

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        hostingController.didMove(toParent: self)
    }
}

/// SwiftUI view for the share extension.
struct ShareExtensionView: View {
    let extensionContext: NSExtensionContext?

    @State private var sharedText = ""
    @State private var isProcessing = false
    @State private var result: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let result {
                    // Show extraction result
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Extracted", systemImage: "checkmark.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.green)

                            Text(result)
                                .font(.body)
                        }
                        .padding()
                    }
                } else if isProcessing {
                    ProgressView("Ada is analyzing...")
                        .padding()
                } else {
                    // Show shared content preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Send to Ada")
                            .font(.headline)

                        Text("Ada will extract tasks, dates, and action items from this content.")
                            .font(.callout)
                            .foregroundStyle(.secondary)

                        TextEditor(text: $sharedText)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding()
                }
            }
            .navigationTitle("Ada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        extensionContext?.completeRequest(returningItems: nil)
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if result != nil {
                        Button("Done") {
                            extensionContext?.completeRequest(returningItems: nil)
                        }
                    } else {
                        Button("Send") {
                            processSharedContent()
                        }
                        .disabled(sharedText.isEmpty || isProcessing)
                    }
                }
            }
            .onAppear {
                loadSharedContent()
            }
        }
    }

    private func loadSharedContent() {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else { return }

        for item in items {
            guard let attachments = item.attachments else { continue }

            for attachment in attachments {
                if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    attachment.loadItem(
                        forTypeIdentifier: UTType.plainText.identifier
                    ) { data, _ in
                        if let text = data as? String {
                            Task { @MainActor in
                                sharedText = text
                            }
                        }
                    }
                    return
                }

                if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    attachment.loadItem(
                        forTypeIdentifier: UTType.url.identifier
                    ) { data, _ in
                        if let url = data as? URL {
                            Task { @MainActor in
                                sharedText = url.absoluteString
                            }
                        }
                    }
                    return
                }
            }
        }
    }

    private func processSharedContent() {
        isProcessing = true

        // Save to app group UserDefaults for the main app to pick up
        let defaults = UserDefaults(suiteName: "group.com.ada.app")
        var inbox = defaults?.stringArray(forKey: "shared_inbox") ?? []
        inbox.append(sharedText)
        defaults?.set(inbox, forKey: "shared_inbox")

        // Show a result preview
        result = "Content saved to Ada's inbox. Open Ada to process it into a structured plan."
        isProcessing = false
    }
}
