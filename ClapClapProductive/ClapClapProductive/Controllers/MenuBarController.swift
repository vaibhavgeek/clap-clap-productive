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

    /// Callback for when user requests to change interval
    var onSetIntervalRequested: (() -> Void)?

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

    /// Draws namaste/prayer hands icon with progressive fill
    /// Two hands joined together in prayer position
    private func drawClapIcon(in context: CGContext, size: NSSize, fillProgress: Double) {
        let width = size.width
        let height = size.height
        let strokeWidth: CGFloat = 1.0

        // Clear the background to ensure a clean drawing
        context.clear(CGRect(origin: .zero, size: size))

        // Calculate fill height based on progress (bottom to top)
        let fillHeight = height * CGFloat(fillProgress)

        // MARK: - Left Hand Path (Prayer position - left side)
        let leftHandPath = CGMutablePath()

        // Starting point at bottom center
        leftHandPath.move(to: CGPoint(x: width * 0.50, y: height * 0.10))

        // Left outer edge going up
        leftHandPath.addCurve(
            to: CGPoint(x: width * 0.25, y: height * 0.40),
            control1: CGPoint(x: width * 0.35, y: height * 0.15),
            control2: CGPoint(x: width * 0.25, y: height * 0.25)
        )

        // Left fingers going up and slightly outward
        leftHandPath.addCurve(
            to: CGPoint(x: width * 0.35, y: height * 0.85),
            control1: CGPoint(x: width * 0.25, y: height * 0.55),
            control2: CGPoint(x: width * 0.28, y: height * 0.75)
        )

        // Fingertips curve back toward center
        leftHandPath.addCurve(
            to: CGPoint(x: width * 0.50, y: height * 0.90),
            control1: CGPoint(x: width * 0.38, y: height * 0.88),
            control2: CGPoint(x: width * 0.44, y: height * 0.90)
        )

        // Inner edge coming back down
        leftHandPath.addCurve(
            to: CGPoint(x: width * 0.50, y: height * 0.10),
            control1: CGPoint(x: width * 0.47, y: height * 0.60),
            control2: CGPoint(x: width * 0.48, y: height * 0.30)
        )
        leftHandPath.closeSubpath()

        // MARK: - Right Hand Path (Prayer position - right side)
        let rightHandPath = CGMutablePath()

        // Starting point at bottom center
        rightHandPath.move(to: CGPoint(x: width * 0.50, y: height * 0.10))

        // Right outer edge going up
        rightHandPath.addCurve(
            to: CGPoint(x: width * 0.75, y: height * 0.40),
            control1: CGPoint(x: width * 0.65, y: height * 0.15),
            control2: CGPoint(x: width * 0.75, y: height * 0.25)
        )

        // Right fingers going up and slightly outward
        rightHandPath.addCurve(
            to: CGPoint(x: width * 0.65, y: height * 0.85),
            control1: CGPoint(x: width * 0.75, y: height * 0.55),
            control2: CGPoint(x: width * 0.72, y: height * 0.75)
        )

        // Fingertips curve back toward center
        rightHandPath.addCurve(
            to: CGPoint(x: width * 0.50, y: height * 0.90),
            control1: CGPoint(x: width * 0.62, y: height * 0.88),
            control2: CGPoint(x: width * 0.56, y: height * 0.90)
        )

        // Inner edge coming back down
        rightHandPath.addCurve(
            to: CGPoint(x: width * 0.50, y: height * 0.10),
            control1: CGPoint(x: width * 0.53, y: height * 0.60),
            control2: CGPoint(x: width * 0.52, y: height * 0.30)
        )
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

        // Set Interval
        let intervalItem = NSMenuItem(title: "Set Interval...", action: #selector(setIntervalClicked), keyEquivalent: "i")
        intervalItem.target = self
        menu.addItem(intervalItem)

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

    @objc private func setIntervalClicked() {
        print("[MenuBarController] Set interval requested")
        onSetIntervalRequested?()
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
