import Foundation
import AppKit

/// Represents an application on the system
struct AppInfo: Codable, Identifiable, Hashable {
    var id: String { bundleIdentifier }
    let name: String
    let bundleIdentifier: String
    let iconPath: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(bundleIdentifier)
    }

    static func == (lhs: AppInfo, rhs: AppInfo) -> Bool {
        return lhs.bundleIdentifier == rhs.bundleIdentifier
    }
}

/// Manages macOS application lifecycle (opening, closing, focusing)
class AppManager {
    // MARK: - Singleton
    static let shared = AppManager()

    private init() {}

    // MARK: - System Apps to Never Close
    private let systemApps: Set<String> = [
        "com.apple.finder",
        "com.apple.systemuiserver",
        "com.apple.dock",
        "com.apple.WindowManager",
        "com.apple.loginwindow",
        "com.apple.notificationcenterui",
        "com.apple.controlcenter",
        "com.apple.Spotlight",
        "com.apple.preferences"
    ]

    // MARK: - Public Methods

    /// Get all installed applications from common directories
    func getAllInstalledApps() -> [AppInfo] {
        var apps: [AppInfo] = []

        // Search paths for applications
        let searchPaths = [
            "/Applications",
            "/System/Applications",
            NSHomeDirectory() + "/Applications"
        ]

        let fileManager = FileManager.default

        for searchPath in searchPaths {
            guard let contents = try? fileManager.contentsOfDirectory(atPath: searchPath) else {
                continue
            }

            for item in contents {
                if item.hasSuffix(".app") {
                    let appPath = searchPath + "/" + item
                    let appURL = URL(fileURLWithPath: appPath)

                    if let bundle = Bundle(url: appURL),
                       let bundleID = bundle.bundleIdentifier,
                       let appName = bundle.infoDictionary?["CFBundleName"] as? String {

                        // Get icon path if available
                        let iconFileName = bundle.infoDictionary?["CFBundleIconFile"] as? String
                        let iconPath = iconFileName != nil ? appPath + "/Contents/Resources/\(iconFileName!)" : nil

                        let appInfo = AppInfo(
                            name: appName,
                            bundleIdentifier: bundleID,
                            iconPath: iconPath
                        )

                        apps.append(appInfo)
                    }
                }
            }
        }

        // Sort alphabetically by name
        return apps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    /// Get currently running applications
    func getRunningApps() -> [AppInfo] {
        let runningApps = NSWorkspace.shared.runningApplications

        let appInfos: [AppInfo] = runningApps.compactMap { app in
            guard let bundleID = app.bundleIdentifier,
                  let appName = app.localizedName,
                  app.activationPolicy == .regular else {
                return nil
            }

            // Get app URL and icon path
            var iconPath: String?
            if let bundleURL = app.bundleURL {
                let bundle = Bundle(url: bundleURL)
                let iconFileName = bundle?.infoDictionary?["CFBundleIconFile"] as? String
                iconPath = iconFileName != nil ? bundleURL.path + "/Contents/Resources/\(iconFileName!)" : nil
            }

            return AppInfo(
                name: appName,
                bundleIdentifier: bundleID,
                iconPath: iconPath
            )
        }

        return appInfos.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    /// Open and focus specified apps
    func openAndFocusApps(_ apps: [AppInfo]) {
        for app in apps {
            openApp(app)
            // Small delay to allow app to launch before focusing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.activateApp(app)
            }
        }
    }

    /// Close all apps that are NOT in the specified list
    func closeAppsNotIn(_ appsToKeep: [AppInfo]) {
        let bundleIDsToKeep = Set(appsToKeep.map { $0.bundleIdentifier })
        let runningApps = NSWorkspace.shared.runningApplications

        for app in runningApps {
            guard let bundleID = app.bundleIdentifier,
                  app.activationPolicy == .regular else {
                continue
            }

            // Skip system apps and apps we want to keep
            if systemApps.contains(bundleID) || bundleIDsToKeep.contains(bundleID) {
                continue
            }

            // Skip our own app
            if bundleID == Bundle.main.bundleIdentifier {
                continue
            }

            // Attempt to terminate the app
            app.terminate()
            print("AppManager: Closing app: \(app.localizedName ?? bundleID)")
        }
    }

    /// Check if an app is currently running
    func isAppRunning(_ app: AppInfo) -> Bool {
        let runningApps = NSWorkspace.shared.runningApplications
        return runningApps.contains { $0.bundleIdentifier == app.bundleIdentifier }
    }

    /// Open a single application
    func openApp(_ app: AppInfo) {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = false // Don't activate immediately, we'll do that separately

        // Try to find the app by bundle identifier
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.bundleIdentifier) {
            NSWorkspace.shared.openApplication(at: appURL, configuration: configuration) { runningApp, error in
                if let error = error {
                    print("AppManager: Failed to open \(app.name): \(error.localizedDescription)")
                } else {
                    print("AppManager: Opened app: \(app.name)")
                }
            }
        } else {
            print("AppManager: Could not find app with bundle ID: \(app.bundleIdentifier)")
        }
    }

    /// Activate/focus a single application
    func activateApp(_ app: AppInfo) {
        let runningApps = NSWorkspace.shared.runningApplications

        if let runningApp = runningApps.first(where: { $0.bundleIdentifier == app.bundleIdentifier }) {
            let success = runningApp.activate(options: .activateIgnoringOtherApps)
            if success {
                print("AppManager: Activated app: \(app.name)")
            } else {
                print("AppManager: Failed to activate app: \(app.name)")
            }
        } else {
            print("AppManager: App not running, cannot activate: \(app.name)")
        }
    }

    /// Close a single application
    func closeApp(_ app: AppInfo) {
        let runningApps = NSWorkspace.shared.runningApplications

        // Don't close system apps
        if systemApps.contains(app.bundleIdentifier) {
            print("AppManager: Cannot close system app: \(app.name)")
            return
        }

        if let runningApp = runningApps.first(where: { $0.bundleIdentifier == app.bundleIdentifier }) {
            let success = runningApp.terminate()
            if success {
                print("AppManager: Closed app: \(app.name)")
            } else {
                print("AppManager: Failed to close app: \(app.name)")
            }
        } else {
            print("AppManager: App not running: \(app.name)")
        }
    }
}
