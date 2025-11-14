# ClapClap Productive - Key Code Snippets

Quick reference guide for important code patterns used in the implementation.

---

## 1. MenuBarController - Icon Drawing

### Creating the Menu Bar Icon with Progressive Fill
```swift
private func createProgressIcon(progress: Double) -> NSImage {
    let size = NSSize(width: 18, height: 18)
    let image = NSImage(size: size)
    image.lockFocus()

    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    drawClapIcon(in: context, size: size, fillProgress: progress)
    image.unlockFocus()
    return image
}

private func drawClapIcon(in context: CGContext, size: NSSize, fillProgress: Double) {
    let width = size.width
    let height = size.height
    let fillHeight = height * CGFloat(fillProgress)

    // Draw hand outlines
    context.setLineWidth(1.5)
    context.setStrokeColor(NSColor.controlTextColor.cgColor)

    // Draw fill using clipping
    if fillProgress > 0 {
        let fillRect = CGRect(x: 0, y: 0, width: width, height: fillHeight)
        context.saveGState()
        context.clip(to: fillRect)
        context.setFillColor(NSColor.controlTextColor.cgColor)
        // Fill paths here
        context.restoreGState()
    }
}
```

### Observing Timer Progress with Combine
```swift
private func observeTimer() {
    timerManager.$progress
        .receive(on: DispatchQueue.main)
        .sink { [weak self] progress in
            self?.updateIcon(progress: progress)
        }
        .store(in: &cancellables)
}
```

---

## 2. OnboardingView - App Selection UI

### Main View Structure
```swift
struct OnboardingView: View {
    @State private var installedApps: [AppInfo] = []
    @State private var selectedApps: Set<AppInfo> = []
    @State private var searchText = ""
    @State private var isLoading = true

    var filteredApps: [AppInfo] {
        if searchText.isEmpty {
            return installedApps
        } else {
            return installedApps.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Welcome to ClapClap Productive")
                .font(.system(size: 28, weight: .bold))

            // Search bar
            TextField("Search apps...", text: $searchText)

            // App list
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(filteredApps) { app in
                        AppRow(
                            app: app,
                            isSelected: selectedApps.contains(app),
                            onToggle: { toggleSelection(app) }
                        )
                    }
                }
            }

            // Continue button
            Button("Continue") {
                completeOnboarding()
            }
            .disabled(selectedApps.isEmpty)
        }
        .frame(width: 500, height: 600)
        .onAppear { loadApps() }
    }
}
```

### Custom App Row Component
```swift
struct AppRow: View {
    let app: AppInfo
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Checkbox
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .accentColor : .secondary)

                // App icon
                if let iconPath = app.iconPath,
                   let nsImage = NSImage(contentsOfFile: iconPath) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .frame(width: 24, height: 24)
                }

                // App name
                Text(app.name)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
    }
}
```

### Async App Loading
```swift
private func loadApps() {
    isLoading = true

    DispatchQueue.global(qos: .userInitiated).async {
        let apps = AppManager.shared.getAllInstalledApps()

        DispatchQueue.main.async {
            self.installedApps = apps
            self.isLoading = false

            // Pre-select previously selected apps
            let savedApps = PreferencesManager.shared.selectedApps
            self.selectedApps = Set(savedApps)
        }
    }
}
```

---

## 3. PopupView - Timer Completion Popup

### Main Popup Structure
```swift
struct PopupView: View {
    @State private var secondsRemaining = 10
    @State private var timer: Timer?
    @State private var pulseAnimation = false

    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(spacing: 24) {
            // Animated emoji
            Text("👏")
                .font(.system(size: 64))
                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true),
                    value: pulseAnimation
                )

            // Message
            Text("Did you clap?")
                .font(.system(size: 32, weight: .bold))

            // Countdown
            Text("Closes in \(secondsRemaining)s")
                .font(.system(size: 13))
                .foregroundColor(.secondary)

            // Dismiss button
            Button("Dismiss") {
                dismiss()
            }
        }
        .frame(width: 300, height: 250)
        .onAppear {
            startCountdown()
            pulseAnimation = true
        }
    }
}
```

### Auto-Dismiss Timer
```swift
private func startCountdown() {
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
        if secondsRemaining > 0 {
            secondsRemaining -= 1
        } else {
            dismiss()
        }
    }
}

private func dismiss() {
    timer?.invalidate()
    timer = nil
    onDismiss?()
}
```

---

## 4. AppDelegate - Application Coordination

### Service Initialization
```swift
class AppDelegate: NSObject, NSApplicationDelegate {
    private var clapDetector: ClapDetector!
    private var timerManager: TimerManager!
    private var menuBarController: MenuBarController!
    private var onboardingWindow: NSWindow?
    private var popupWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set debug timer for testing
        #if DEBUG
        PreferencesManager.shared.timerInterval = 5.0
        #endif

        setupServices()
        setupCallbacks()

        if !PreferencesManager.shared.hasCompletedOnboarding {
            showOnboarding()
        }

        clapDetector.startListening()
    }
}
```

### Callback Wiring
```swift
private func setupCallbacks() {
    // Timer completion → Show popup
    timerManager.onTimerComplete = { [weak self] in
        self?.showClapPopup()
    }

    // Clap detection → Activate focus mode
    clapDetector.onDoubleClapDetected = { [weak self] in
        self?.handleDoubleClap()
    }

    // Menu bar interactions
    menuBarController.onPreferencesRequested = { [weak self] in
        self?.showOnboarding()
    }

    menuBarController.onResetRequested = { [weak self] in
        self?.timerManager.resetTimer()
    }
}
```

### Window Creation with SwiftUI
```swift
private func showOnboarding() {
    let contentView = OnboardingView(onComplete: { [weak self] in
        self?.onboardingWindow?.close()
        self?.onboardingWindow = nil
        self?.showNotification(
            title: "ClapClap Productive",
            message: "Setup complete! Clap twice to activate focus mode."
        )
    })

    let hostingController = NSHostingController(rootView: contentView)

    let window = NSWindow(contentViewController: hostingController)
    window.title = "Welcome to ClapClap Productive"
    window.styleMask = [.titled, .closable]
    window.center()
    window.makeKeyAndOrderFront(nil)
    window.level = .floating

    NSApp.activate(ignoringOtherApps: true)

    onboardingWindow = window
}
```

### Focus Mode Logic
```swift
private func handleDoubleClap() {
    let selectedApps = PreferencesManager.shared.selectedApps

    guard !selectedApps.isEmpty else {
        showOnboarding()
        return
    }

    // Open and focus selected apps
    AppManager.shared.openAndFocusApps(selectedApps)

    // Close other apps (with delay)
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        AppManager.shared.closeAppsNotIn(selectedApps)
    }

    // Reset timer
    timerManager.resetTimer()

    // Dismiss popup if showing
    popupWindow?.close()
    popupWindow = nil

    // Show notification
    showNotification(
        title: "Focus Mode Activated",
        message: "Your productivity apps are now active. Stay focused!"
    )
}
```

---

## 5. Key Integration Patterns

### Using ObservableObject with Combine
```swift
class TimerManager: ObservableObject {
    @Published var progress: Double = 0.0
    @Published var isCompleted: Bool = false

    var onTimerComplete: (() -> Void)?
}

// In consumer:
timerManager.$progress
    .receive(on: DispatchQueue.main)
    .sink { progress in
        // Handle update
    }
    .store(in: &cancellables)
```

### Persisting Data with PreferencesManager
```swift
// Saving
PreferencesManager.shared.selectedApps = Array(selectedApps)
PreferencesManager.shared.hasCompletedOnboarding = true

// Loading
let apps = PreferencesManager.shared.selectedApps
let completed = PreferencesManager.shared.hasCompletedOnboarding
```

### Working with AppManager
```swift
// Get all installed apps
let apps = AppManager.shared.getAllInstalledApps()

// Open and focus apps
AppManager.shared.openAndFocusApps(selectedApps)

// Close apps not in list
AppManager.shared.closeAppsNotIn(selectedApps)

// Check if app is running
let isRunning = AppManager.shared.isAppRunning(app)
```

---

## 6. Common SwiftUI Patterns Used

### Conditional Views
```swift
if isLoading {
    ProgressView("Loading...")
} else if filteredApps.isEmpty {
    Text("No apps found")
} else {
    ScrollView {
        // Content
    }
}
```

### Button with Custom Styling
```swift
Button(action: { /* action */ }) {
    Text("Continue")
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.accentColor)
        .cornerRadius(8)
}
.buttonStyle(PlainButtonStyle())
.disabled(condition)
```

### Search Field with Clear Button
```swift
HStack {
    Image(systemName: "magnifyingglass")
    TextField("Search...", text: $searchText)

    if !searchText.isEmpty {
        Button(action: { searchText = "" }) {
            Image(systemName: "xmark.circle.fill")
        }
    }
}
```

---

## 7. Memory Management Patterns

### Weak Self in Closures
```swift
timerManager.onTimerComplete = { [weak self] in
    self?.showClapPopup()
}

clapDetector.onDoubleClapDetected = { [weak self] in
    self?.handleDoubleClap()
}
```

### Proper Cleanup
```swift
func applicationWillTerminate(_ notification: Notification) {
    clapDetector.stopListening()
    timerManager.stopTimer()
}

// In views:
.onDisappear {
    stopTimer()
}
```

---

## 8. Testing Helpers

### Debug Timer Override
```swift
#if DEBUG
PreferencesManager.shared.timerInterval = 5.0  // 5 seconds
print("[DEBUG] Timer set to 5 seconds for testing")
#endif
```

### Comprehensive Logging
```swift
print("[MenuBarController] Status item created")
print("[OnboardingView] Loaded \(apps.count) apps")
print("[PopupView] Countdown started (10 seconds)")
print("[AppDelegate] 👏 Double clap detected!")
```

### Reset Preferences for Testing
```swift
// In PreferencesManager
func clearAllPreferences() {
    UserDefaults.standard.removeObject(forKey: Keys.selectedApps)
    UserDefaults.standard.removeObject(forKey: Keys.hasCompletedOnboarding)
    UserDefaults.standard.synchronize()
}
```

---

## 9. macOS Specific Patterns

### Menu Bar App Behavior
```swift
func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false  // Keep app running when windows close
}
```

### Creating NSMenu
```swift
let menu = NSMenu()

let item = NSMenuItem(title: "Reset Timer",
                      action: #selector(resetTimerClicked),
                      keyEquivalent: "r")
item.target = self
menu.addItem(item)

menu.addItem(NSMenuItem.separator())

statusItem?.menu = menu
```

### User Notifications
```swift
private func showNotification(title: String, message: String) {
    let notification = NSUserNotification()
    notification.title = title
    notification.informativeText = message
    notification.soundName = NSUserNotificationDefaultSoundName

    NSUserNotificationCenter.default.deliver(notification)
}
```

---

## 10. Error Handling Patterns

### Optional Chaining
```swift
guard let button = statusItem?.button else { return }
guard let context = NSGraphicsContext.current?.cgContext else { return }
```

### Nil Coalescing for Defaults
```swift
let iconPath = app.iconPath ?? "/default/path"
let appCount = selectedApps.count > 0 ? selectedApps.count : 0
```

### Safe Window Management
```swift
// Close existing window before creating new one
onboardingWindow?.close()
onboardingWindow = nil

// Create new window
let window = NSWindow(contentViewController: controller)
onboardingWindow = window
```

---

## 11. Performance Optimizations

### Async Loading
```swift
DispatchQueue.global(qos: .userInitiated).async {
    let apps = AppManager.shared.getAllInstalledApps()

    DispatchQueue.main.async {
        self.installedApps = apps
        self.isLoading = false
    }
}
```

### Efficient Filtering
```swift
var filteredApps: [AppInfo] {
    guard !searchText.isEmpty else { return installedApps }
    return installedApps.filter {
        $0.name.localizedCaseInsensitiveContains(searchText)
    }
}
```

### Set-Based Selection
```swift
@State private var selectedApps: Set<AppInfo> = []

// O(1) lookup instead of O(n)
let isSelected = selectedApps.contains(app)
```

---

## 12. Accessibility Helpers

### Keyboard Shortcuts
```swift
Button("Dismiss") {
    dismiss()
}
.keyboardShortcut(.defaultAction)  // Return key
```

### Button Styles for Accessibility
```swift
.buttonStyle(PlainButtonStyle())  // Removes default styling
.contentShape(Rectangle())        // Makes entire area tappable
```

---

These code snippets represent the key patterns and techniques used throughout the ClapClap Productive implementation. All code follows Swift best practices and macOS Human Interface Guidelines.
