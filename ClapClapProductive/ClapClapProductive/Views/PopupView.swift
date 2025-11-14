import SwiftUI

/// Popup view that appears when timer completes, prompting user to clap
struct PopupView: View {
    // MARK: - State Properties

    @State private var secondsRemaining = 10
    @State private var timer: Timer?
    @State private var pulseAnimation = false
    @State private var showWeakClapMessage = false
    @State private var weakClapMessageTimer: Timer?

    /// Callback when popup is dismissed
    var onDismiss: (() -> Void)?

    /// Callback to trigger weak clap message
    var onWeakClapShow: (() -> Void)?

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

                // Weak clap warning message
                if showWeakClapMessage {
                    Text("You gotta clap harder than that!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(8)
                        .transition(.scale.combined(with: .opacity))
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
        stopWeakClapTimer()

        print("[PopupView] Popup dismissed")

        // Call the dismiss callback
        onDismiss?()
    }

    func showWeakClapWarning() {
        // Cancel existing timer
        weakClapMessageTimer?.invalidate()

        // Show message with animation
        withAnimation {
            showWeakClapMessage = true
        }

        print("[PopupView] Showing weak clap warning")

        // Hide message after 2 seconds
        weakClapMessageTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            withAnimation {
                self.showWeakClapMessage = false
            }
        }
    }

    private func stopWeakClapTimer() {
        weakClapMessageTimer?.invalidate()
        weakClapMessageTimer = nil
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
