import Foundation

/// Manages persistent storage of user preferences using UserDefaults
class PreferencesManager {
    // MARK: - Singleton
    static let shared = PreferencesManager()

    private init() {}

    // MARK: - UserDefaults Keys
    private enum Keys {
        static let selectedApps = "selectedApps"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let timerInterval = "timerInterval"
        static let timerStartTime = "timerStartTime"
    }

    // MARK: - Properties

    /// Selected apps to keep open and focused during productivity sessions
    var selectedApps: [AppInfo] {
        get {
            guard let data = UserDefaults.standard.data(forKey: Keys.selectedApps) else {
                return []
            }

            do {
                let apps = try JSONDecoder().decode([AppInfo].self, from: data)
                return apps
            } catch {
                print("PreferencesManager: Failed to decode selectedApps: \(error)")
                return []
            }
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: Keys.selectedApps)
            } catch {
                print("PreferencesManager: Failed to encode selectedApps: \(error)")
            }
        }
    }

    /// Whether the user has completed the onboarding process
    var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.hasCompletedOnboarding)
        }
    }

    /// Timer interval in seconds (default: 7200 seconds = 2 hours)
    var timerInterval: TimeInterval {
        get {
            let interval = UserDefaults.standard.double(forKey: Keys.timerInterval)
            // Return default 2 hours if not set
            return interval > 0 ? interval : 7200
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.timerInterval)
        }
    }

    /// Timer start time for persistence across app restarts
    var timerStartTime: Date? {
        get {
            UserDefaults.standard.object(forKey: Keys.timerStartTime) as? Date
        }
        set {
            if let date = newValue {
                UserDefaults.standard.set(date, forKey: Keys.timerStartTime)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.timerStartTime)
            }
        }
    }

    // MARK: - Methods

    /// Clear all stored preferences (useful for testing and reset)
    func clearAllPreferences() {
        UserDefaults.standard.removeObject(forKey: Keys.selectedApps)
        UserDefaults.standard.removeObject(forKey: Keys.hasCompletedOnboarding)
        UserDefaults.standard.removeObject(forKey: Keys.timerInterval)
        UserDefaults.standard.removeObject(forKey: Keys.timerStartTime)
        UserDefaults.standard.synchronize()
    }
}
