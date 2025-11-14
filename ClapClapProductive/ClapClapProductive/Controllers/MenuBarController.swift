import Cocoa
import SwiftUI
import Combine

/// Manages the menu bar icon with progressive fill animation based on timer progress
class MenuBarController: ObservableObject {
    // MARK: - Properties

    private var statusItem: NSStatusItem?
    private var timerManager: TimerManager
    private var cancellables = Set<AnyCancellable>()

    /// Callback for when user requests preferences
    var onPreferencesRequested: (() -> Void)?

    /// Callback for when user requests timer reset
    var onResetRequested: (() -> Void)?

    // MARK: - Initialization

    init(timerManager: TimerManager) {
        self.timerManager = timerManager
        setupStatusItem()
        observeTimer()
    }

    // MARK: - Setup Methods

    private func setupStatusItem() {
        // Create status bar item with square length (standard menu bar icon size)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        // Set initial icon (0% progress)
        updateIcon(progress: 0.0)

        // Setup right-click menu
        setupMenu()

        print("[MenuBarController] Status item created")
    }

    private func observeTimer() {
        // Observe timer progress and update icon accordingly
        timerManager.$progress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.updateIcon(progress: progress)
            }
            .store(in: &cancellables)

        print("[MenuBarController] Observing timer progress")
    }

    // MARK: - Icon Management

    private func updateIcon(progress: Double) {
        guard let button = statusItem?.button else { return }

        // Create icon with progressive fill
        let icon = createProgressIcon(progress: progress)
        button.image = icon
        button.image?.isTemplate = true // Adapt to light/dark mode

        // Update tooltip with progress percentage
        let percentage = Int(progress * 100)
        button.toolTip = "ClapClap Productive: \(percentage)% complete"
    }

    /// Creates a menu bar icon showing clapping hands with fill progress
    private func createProgressIcon(progress: Double) -> NSImage {
        // Icon size for menu bar (standard is 18x18 at 1x, 36x36 at 2x)
        let size = NSSize(width: 18, height: 18)

        let image = NSImage(size: size)
        image.lockFocus()

        // Get graphics context
        guard let context = NSGraphicsContext.current?.cgContext else {
            image.unlockFocus()
            return image
        }

        // Draw the icon
        drawClapIcon(in: context, size: size, fillProgress: progress)

        image.unlockFocus()
        return image
    }

    /// Draws recognizable clapping hands icon with progressive fill
    /// Two hands facing each other with curved palm shapes and fingers
    private func drawClapIcon(in context: CGContext, size: NSSize, fillProgress: Double) {
        let width = size.width
        let height = size.height
        let strokeWidth: CGFloat = 1.3

        // Calculate fill height based on progress (bottom to top)
        let fillHeight = height * CGFloat(fillProgress)

        // LEFT HAND - Palm with curved top representing fingers
        let leftHandPath = CGMutablePath()
        // Start at bottom left
        leftHandPath.move(to: CGPoint(x: width * 0.15, y: height * 0.15))
        // Left side of palm
        leftHandPath.addLine(to: CGPoint(x: width * 0.15, y: height * 0.65))
        // Thumb curve (left side)
        leftHandPath.addQuadCurve(
            to: CGPoint(x: width * 0.20, y: height * 0.75),
            control: CGPoint(x: width * 0.12, y: height * 0.72)
        )
        // Fingers as rounded top
        leftHandPath.addQuadCurve(
            to: CGPoint(x: width * 0.38, y: height * 0.82),
            control: CGPoint(x: width * 0.28, y: height * 0.88)
        )
        // Down to right side of palm
        leftHandPath.addLine(to: CGPoint(x: width * 0.38, y: height * 0.65))
        leftHandPath.addLine(to: CGPoint(x: width * 0.30, y: height * 0.15))
        leftHandPath.closeSubpath()

        // RIGHT HAND - Mirrored palm with curved top
        let rightHandPath = CGMutablePath()
        // Start at bottom right
        rightHandPath.move(to: CGPoint(x: width * 0.85, y: height * 0.15))
        // Right side of palm
        rightHandPath.addLine(to: CGPoint(x: width * 0.85, y: height * 0.65))
        // Thumb curve (right side)
        rightHandPath.addQuadCurve(
            to: CGPoint(x: width * 0.80, y: height * 0.75),
            control: CGPoint(x: width * 0.88, y: height * 0.72)
        )
        // Fingers as rounded top (mirrored)
        rightHandPath.addQuadCurve(
            to: CGPoint(x: width * 0.62, y: height * 0.82),
            control: CGPoint(x: width * 0.72, y: height * 0.88)
        )
        // Down to left side of palm
        rightHandPath.addLine(to: CGPoint(x: width * 0.62, y: height * 0.65))
        rightHandPath.addLine(to: CGPoint(x: width * 0.70, y: height * 0.15))
        rightHandPath.closeSubpath()

        // Draw hand outlines (always visible)
        context.setLineWidth(strokeWidth)
        context.setStrokeColor(NSColor.controlTextColor.cgColor)

        context.addPath(leftHandPath)
        context.strokePath()

        context.addPath(rightHandPath)
        context.strokePath()

        // Draw progressive fill (bottom to top)
        if fillProgress > 0 {
            context.saveGState()

            // Create clipping rectangle for fill effect
            let fillRect = CGRect(x: 0, y: 0, width: width, height: fillHeight)
            context.clip(to: fillRect)

            // Fill both hands within clipping area
            context.setFillColor(NSColor.controlTextColor.cgColor)

            context.addPath(leftHandPath)
            context.fillPath()

            context.addPath(rightHandPath)
            context.fillPath()

            context.restoreGState()
        }
    }

    // MARK: - Menu Setup

    private func setupMenu() {
        let menu = NSMenu()

        // Progress display (non-clickable)
        let progressItem = NSMenuItem(title: "Progress: 0%", action: nil, keyEquivalent: "")
        progressItem.isEnabled = false
        menu.addItem(progressItem)

        menu.addItem(NSMenuItem.separator())

        // Reset Timer
        let resetItem = NSMenuItem(title: "Reset Timer", action: #selector(resetTimerClicked), keyEquivalent: "r")
        resetItem.target = self
        menu.addItem(resetItem)

        // Preferences (reopens onboarding)
        let preferencesItem = NSMenuItem(title: "Preferences...", action: #selector(preferencesClicked), keyEquivalent: ",")
        preferencesItem.target = self
        menu.addItem(preferencesItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(title: "Quit ClapClap Productive", action: #selector(quitClicked), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu

        // Update progress item when timer changes
        timerManager.$progress
            .receive(on: DispatchQueue.main)
            .sink { [weak progressItem] progress in
                let percentage = Int(progress * 100)
                progressItem?.title = "Progress: \(percentage)%"
            }
            .store(in: &cancellables)
    }

    // MARK: - Menu Actions

    @objc private func resetTimerClicked() {
        print("[MenuBarController] Reset timer requested")
        onResetRequested?()
    }

    @objc private func preferencesClicked() {
        print("[MenuBarController] Preferences requested")
        onPreferencesRequested?()
    }

    @objc private func quitClicked() {
        print("[MenuBarController] Quit requested")
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Public Methods

    /// Update the icon immediately (useful for forcing refresh)
    func refreshIcon() {
        updateIcon(progress: timerManager.progress)
    }
}
