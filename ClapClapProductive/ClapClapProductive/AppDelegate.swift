import Cocoa
import SwiftUI
import UserNotifications

/// Main application delegate that coordinates all services and UI components
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Services

    private var clapDetector: ClapDetector!
    private var timerManager: TimerManager!
    private var menuBarController: MenuBarController!

    // MARK: - Windows

    private var onboardingWindow: NSWindow?
    private var popupWindow: NSWindow?
    private var currentPopupView: PopupView?
    private var intervalSettingsWindow: NSWindow?

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("\n========================================")
        print("ClapClap Productive Starting...")
        print("========================================\n")

        // IMPORTANT: For testing, set timer to 5 seconds
        // Comment this out for production (default is 2 hours)
        #if DEBUG
        PreferencesManager.shared.timerInterval = 5.0
        print("[AppDelegate] DEBUG MODE: Timer set to 5 seconds for testing")
        #endif

        // Initialize services
        setupServices()

        // Wire up callbacks
        setupCallbacks()

        // Check if onboarding is needed
        if !PreferencesManager.shared.hasCompletedOnboarding {
            print("[AppDelegate] First launch detected, showing onboarding")
            showOnboarding()
        } else {
            print("[AppDelegate] Onboarding already completed")
            let selectedApps = PreferencesManager.shared.selectedApps
            print("[AppDelegate] \(selectedApps.count) app(s) configured")
        }

        // Note: Microphone will only start when popup appears
        print("\n[AppDelegate] ClapClap Productive ready!")
        print("[AppDelegate] Menu bar icon visible")
        print("[AppDelegate] Clap detection will activate when timer completes\n")
    }

    func applicationWillTerminate(_ notification: Notification) {
        print("[AppDelegate] Application terminating, cleaning up...")
        clapDetector.stopListening()
        timerManager.stopTimer()
    }

    // Ensure app doesn't quit when last window closes (menu bar app behavior)
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    // MARK: - Service Setup

    private func setupServices() {
        // Initialize timer manager
        timerManager = TimerManager()
        print("[AppDelegate] TimerManager initialized")

        // Initialize clap detector
        clapDetector = ClapDetector()
        print("[AppDelegate] ClapDetector initialized")

        // Initialize menu bar controller
        menuBarController = MenuBarController(timerManager: timerManager)
        print("[AppDelegate] MenuBarController initialized")
    }

    private func setupCallbacks() {
        // Timer completion callback
        timerManager.onTimerComplete = { [weak self] in
            print("\n[AppDelegate] ⏰ Timer completed!")
            self?.showClapPopup()
        }

        // Clap detection callback
        clapDetector.onDoubleClapDetected = { [weak self] in
            print("\n[AppDelegate] 👏 Clap confirmed - activating focus mode!")
            self?.handleDoubleClap()
        }

        // Weak clap detection callback
        clapDetector.onWeakClapDetected = { [weak self] in
            print("\n[AppDelegate] ⚠️ Weak clap detected")
            self?.currentPopupView?.showWeakClapWarning()
        }

        // Menu bar controller callbacks
        menuBarController.onPreferencesRequested = { [weak self] in
            print("[AppDelegate] Preferences requested")
            self?.showOnboarding()
        }

        menuBarController.onResetRequested = { [weak self] in
            print("[AppDelegate] Timer reset requested")
            self?.timerManager.resetTimer()
        }

        menuBarController.onSetIntervalRequested = { [weak self] in
            print("[AppDelegate] Set interval requested")
            self?.showIntervalSettings()
        }
    }

    // MARK: - Window Management

    private func showOnboarding() {
        // Close existing onboarding window if any
        onboardingWindow?.close()
        onboardingWindow = nil

        // Create onboarding view with completion callback
        let contentView = OnboardingView(onComplete: { [weak self] in
            print("[AppDelegate] Onboarding completed")
            self?.onboardingWindow?.close()
            self?.onboardingWindow = nil

            // Show a brief notification that setup is complete
            self?.showNotification(
                title: "ClapClap Productive",
                message: "Setup complete! Single clap to activate focus mode."
            )
        })

        let hostingController = NSHostingController(rootView: contentView)

        // Create window with proper styling
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Welcome to ClapClap Productive"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("OnboardingWindow")
        window.makeKeyAndOrderFront(nil)
        window.level = .floating

        // Bring app to front
        NSApp.activate(ignoringOtherApps: true)

        onboardingWindow = window
        print("[AppDelegate] Onboarding window displayed")
    }

    private func showIntervalSettings() {
        // Close existing interval settings window if any
        intervalSettingsWindow?.close()
        intervalSettingsWindow = nil

        // Get current interval
        let currentInterval = PreferencesManager.shared.timerInterval

        // Create interval settings view with callbacks
        let contentView = IntervalSettingsView(
            currentInterval: currentInterval,
            onSave: { [weak self] (newInterval: TimeInterval) in
                print("[AppDelegate] Interval updated to \(newInterval)s")

                // Save new interval
                PreferencesManager.shared.timerInterval = newInterval

                // Reset timer with new interval
                self?.timerManager.resetTimer()

                // Close window
                self?.intervalSettingsWindow?.close()
                self?.intervalSettingsWindow = nil

                // Show confirmation
                self?.showNotification(
                    title: "Interval Updated",
                    message: "Timer interval set to \(self?.formatInterval(newInterval) ?? "")"
                )
            },
            onCancel: { [weak self] in
                print("[AppDelegate] Interval settings cancelled")
                self?.intervalSettingsWindow?.close()
                self?.intervalSettingsWindow = nil
            }
        )

        let hostingController = NSHostingController(rootView: contentView)

        // Create window with proper styling
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Set Timer Interval"
        window.styleMask = [NSWindow.StyleMask.titled, NSWindow.StyleMask.closable]
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("IntervalSettingsWindow")
        window.makeKeyAndOrderFront(nil)
        window.level = NSWindow.Level.floating

        // Bring app to front
        NSApp.activate(ignoringOtherApps: true)

        intervalSettingsWindow = window
        print("[AppDelegate] Interval settings window displayed")
    }

    private func formatInterval(_ interval: TimeInterval) -> String {
        let minutes = Int(interval / 60)
        if minutes < 60 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s")"
        } else {
            let hours = minutes / 60
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        }
    }

    private func showClapPopup() {
        // Close existing popup if any
        popupWindow?.close()
        popupWindow = nil
        currentPopupView = nil

        // START MICROPHONE when popup appears
        print("[AppDelegate] Starting clap detection for popup")
        clapDetector.startListening()

        // Create popup view with dismiss callback
        let contentView = PopupView(onDismiss: { [weak self] in
            print("[AppDelegate] Popup dismissed")

            // STOP MICROPHONE when popup dismisses
            print("[AppDelegate] Stopping clap detection")
            self?.clapDetector.stopListening()

            self?.popupWindow?.close()
            self?.popupWindow = nil
            self?.currentPopupView = nil

            // AUTO-RESET: Start next timer cycle for infinite loop
            self?.timerManager.resetTimer()
            print("[AppDelegate] Timer automatically reset for next cycle")
        })

        // Store reference to popup view for weak clap callbacks
        currentPopupView = contentView

        let hostingController = NSHostingController(rootView: contentView)

        // Create window with floating style (always on top)
        let window = NSWindow(contentViewController: hostingController)
        window.styleMask = [.titled, .closable]
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isOpaque = true  // Fixed: Changed from false to make window visible
        window.backgroundColor = NSColor.windowBackgroundColor  // Fixed: Changed from .clear to have solid background
        window.level = .floating
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(nil)

        // Bring to front and focus
        NSApp.activate(ignoringOtherApps: true)

        popupWindow = window
        print("[AppDelegate] Clap popup displayed")
    }

    // MARK: - Clap Handling

    private func handleDoubleClap() {
        let selectedApps = PreferencesManager.shared.selectedApps

        // Check if apps are configured
        if selectedApps.isEmpty {
            print("[AppDelegate] No apps configured, showing onboarding")
            showNotification(
                title: "ClapClap Productive",
                message: "Please configure your productivity apps first."
            )
            showOnboarding()
            return
        }

        print("[AppDelegate] Activating focus mode with \(selectedApps.count) app(s)")

        // Open and focus selected apps
        print("[AppDelegate] Opening and focusing apps...")
        AppManager.shared.openAndFocusApps(selectedApps)

        // Close other apps (with a small delay to allow selected apps to open first)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            print("[AppDelegate] Closing non-essential apps...")
            AppManager.shared.closeAppsNotIn(selectedApps)
        }

        // Reset timer to start new focus session
        timerManager.resetTimer()
        print("[AppDelegate] Timer reset, new focus session started")

        // Dismiss popup if showing
        if popupWindow != nil {
            // STOP MICROPHONE when clap detected
            print("[AppDelegate] Stopping clap detection")
            clapDetector.stopListening()

            popupWindow?.close()
            popupWindow = nil
            currentPopupView = nil
            print("[AppDelegate] Popup dismissed")
        }

        // Show confirmation notification
        showNotification(
            title: "Focus Mode Activated",
            message: "Your productivity apps are now active. Stay focused!"
        )
    }

    // MARK: - Notifications

    private func showNotification(title: String, message: String) {
        // Request notification authorization on first use
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                // Create notification content
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = message
                content.sound = .default

                // Create request with unique identifier
                let request = UNNotificationRequest(
                    identifier: UUID().uuidString,
                    content: content,
                    trigger: nil // Deliver immediately
                )

                // Schedule the notification
                center.add(request) { error in
                    if let error = error {
                        print("[AppDelegate] Error showing notification: \(error)")
                    }
                }
            }
        }
    }
}
