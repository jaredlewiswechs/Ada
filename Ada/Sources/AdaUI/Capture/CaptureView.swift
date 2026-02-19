import SwiftUI
import VisionKit

/// Camera capture view for "Scan -> Structure" feature.
/// Uses VisionKit's document scanner for OCR, then feeds text to the Foundation Model.
struct CaptureView: View {
    let onCapture: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showingScanner = false
    @State private var scannedText = ""
    @State private var showingManualInput = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 64))
                    .foregroundStyle(.accent)

                Text("Scan & Structure")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Point your camera at notes, a bill, a schedule, or any document. Ada will extract tasks, dates, and contacts.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                VStack(spacing: 12) {
                    Button {
                        if DataScannerViewController.isSupported {
                            showingScanner = true
                        }
                    } label: {
                        Label("Scan with Camera", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!DataScannerViewController.isSupported)

                    Button {
                        showingManualInput = true
                    } label: {
                        Label("Paste Text Instead", systemImage: "doc.on.clipboard")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding(.horizontal, 32)

                Spacer()
            }
            .navigationTitle("Capture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                LiveTextScannerView { text in
                    scannedText = text
                    showingScanner = false
                    onCapture(text)
                }
            }
            .sheet(isPresented: $showingManualInput) {
                ManualTextInputView { text in
                    showingManualInput = false
                    onCapture(text)
                }
            }
        }
    }
}

/// Wraps VisionKit's DataScannerViewController for live text recognition.
struct LiveTextScannerView: UIViewControllerRepresentable {
    let onRecognize: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .accurate,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onRecognize: onRecognize)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onRecognize: (String) -> Void

        init(onRecognize: @escaping (String) -> Void) {
            self.onRecognize = onRecognize
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            if case .text(let text) = item {
                onRecognize(text.transcript)
            }
        }
    }
}

/// Manual text input for when the camera isn't available.
struct ManualTextInputView: View {
    let onSubmit: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text = ""

    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $text)
                    .padding()
                    .overlay(
                        Group {
                            if text.isEmpty {
                                Text("Paste or type text to extract information from...")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 24)
                                    .padding(.leading, 20)
                            }
                        },
                        alignment: .topLeading
                    )
            }
            .navigationTitle("Paste Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Extract") {
                        onSubmit(text)
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    CaptureView { text in
        print("Captured: \(text)")
    }
}
