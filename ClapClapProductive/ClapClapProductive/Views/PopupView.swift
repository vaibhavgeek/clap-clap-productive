import SwiftUI

/// Popup view that appears when timer completes, prompting user to clap
struct PopupView: View {
    // MARK: - State Properties

    @State private var secondsRemaining = 10
    @State private var timer: Timer?
    @State private var pulseAnimation = false

    /// Callback when popup is dismissed
    var onDismiss: (() -> Void)?

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background with subtle gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(NSColor.windowBackgroundColor),
                    Color(NSColor.windowBackgroundColor).opacity(0.5)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(16)

            VStack(spacing: 24) {
                Spacer()

                // Clapping hands emoji with pulse animation
                Text("👏")
                    .font(.system(size: 64))
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true),
                        value: pulseAnimation
                    )

                // Main message
                Text("Did you clap?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)

                // Subtitle with timer countdown
                VStack(spacing: 8) {
                    Text("Time to focus!")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)

                    // Countdown indicator
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        Text("Closes in \(secondsRemaining)s")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Dismiss button
                Button(action: dismiss) {
                    Text("Dismiss")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .keyboardShortcut(.defaultAction)
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
            .frame(width: 400, height: 250)
        }
        .frame(width: 400, height: 350)
        .onAppear {
            startCountdown()
            startPulseAnimation()
        }
        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - Methods

    private func startCountdown() {
        // Start the countdown timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                // Auto-dismiss when countdown reaches zero
                dismiss()
            }
        }

        print("[PopupView] Countdown started (10 seconds)")
    }

    private func startPulseAnimation() {
        // Start the pulse animation for the emoji
        pulseAnimation = true
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func dismiss() {
        stopTimer()

        print("[PopupView] Popup dismissed")

        // Call the dismiss callback
        onDismiss?()
    }
}

// MARK: - Preview

struct PopupView_Previews: PreviewProvider {
    static var previews: some View {
        PopupView()
            .preferredColorScheme(.light)

        PopupView()
            .preferredColorScheme(.dark)
    }
}
