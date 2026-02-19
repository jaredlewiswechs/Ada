import SwiftUI

/// Animated indicator shown while Ada is thinking/processing on-device.
struct ProcessingIndicatorView: View {
    @State private var animating = false

    var body: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animating ? 1.0 : 0.5)
                        .opacity(animating ? 1.0 : 0.3)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: animating
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))

            Spacer()
        }
        .onAppear {
            animating = true
        }
    }
}

#Preview {
    ProcessingIndicatorView()
        .padding()
}
