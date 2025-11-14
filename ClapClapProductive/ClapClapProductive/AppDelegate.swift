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

        // Start listening for claps
        clapDetector.startListening()

        print("\n[AppDelegate] ClapClap Productive ready!")
        print("[AppDelegate] Menu bar icon visible")
        print("[AppDelegate] Listening for claps (single clap with 0.3s confirmation)...\n")
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

        // Menu bar controller callbacks
        menuBarController.onPreferencesRequested = { [weak self] in
            print("[AppDelegate] Preferences requested")
            self?.showOnboarding()
        }

        menuBarController.onResetRequested = { [weak self] in
            print("[AppDelegate] Timer reset requested")
            self?.timerManager.resetTimer()
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

    private func showClapPopup() {
        // Close existing popup if any
        popupWindow?.close()
        popupWindow = nil

        // Create popup view with dismiss callback
        let contentView = PopupView(onDismiss: { [weak self] in
            print("[AppDelegate] Popup dismissed")
            self?.popupWindow?.close()
            self?.popupWindow = nil

            // AUTO-RESET: Start next timer cycle for infinite loop
            self?.timerManager.resetTimer()
            print("[AppDelegate] Timer automatically reset for next cycle")
        })

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
            popupWindow?.close()
            popupWindow = nil
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
