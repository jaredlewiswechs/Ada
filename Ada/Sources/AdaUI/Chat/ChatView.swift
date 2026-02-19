import SwiftUI
import SwiftData

/// The main chat interface — the primary way users interact with Ada.
/// Users type or paste messy input, Ada returns a structured plan with receipts.
struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ChatViewModel()
    @State private var inputText = ""
    @State private var showingCapture = false
    @FocusState private var inputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                messageList
                inputBar
            }
            .navigationTitle("Ada")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    modelStatusIndicator
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.startNewConversation(context: modelContext)
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingCapture) {
                CaptureView { scannedText in
                    inputText = scannedText
                    showingCapture = false
                }
            }
            .onAppear {
                viewModel.setup(context: modelContext)
            }
        }
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    if viewModel.messages.isEmpty {
                        emptyState
                    } else {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                    }

                    if viewModel.isProcessing {
                        ProcessingIndicatorView()
                            .id("processing")
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.messages.count) {
                if let lastMessage = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.isProcessing) {
                if viewModel.isProcessing {
                    withAnimation {
                        proxy.scrollTo("processing", anchor: .bottom)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 60)

            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(.accent)

            Text("What needs organizing?")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Drop in messy text, a to-do brain dump, or scan a document — Ada will turn it into structured actions.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            HStack(spacing: 12) {
                SuggestionChip(
                    title: "Plan my week",
                    icon: "calendar"
                ) {
                    inputText = "Plan my week: Monday meeting with Sarah at 10am, dentist Wednesday afternoon, gym Tuesday and Thursday morning, Friday off"
                    sendMessage()
                }

                SuggestionChip(
                    title: "Packing list",
                    icon: "suitcase"
                ) {
                    inputText = "Create a packing list for a 3-day business trip to Dallas next week"
                    sendMessage()
                }
            }

            HStack(spacing: 12) {
                SuggestionChip(
                    title: "Daily brief",
                    icon: "sun.max"
                ) {
                    inputText = "What's my day look like?"
                    sendMessage()
                }

                SuggestionChip(
                    title: "Scan document",
                    icon: "doc.text.viewfinder"
                ) {
                    showingCapture = true
                }
            }
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(alignment: .bottom, spacing: 12) {
                Button {
                    showingCapture = true
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.title3)
                        .foregroundStyle(.accent)
                }
                .padding(.bottom, 8)

                TextField("What needs organizing?", text: $inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...6)
                    .focused($inputFocused)
                    .onSubmit {
                        sendMessage()
                    }

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                        .foregroundStyle(
                            inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? .gray
                            : .accent
                        )
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.bottom, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(.bar)
    }

    private var modelStatusIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(viewModel.modelService.isAvailable ? .green : .orange)
                .frame(width: 8, height: 8)
            Text(viewModel.modelService.isAvailable ? "On-Device" : "Unavailable")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Actions

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        inputFocused = false

        Task {
            await viewModel.send(message: text, context: modelContext)
        }
    }
}
