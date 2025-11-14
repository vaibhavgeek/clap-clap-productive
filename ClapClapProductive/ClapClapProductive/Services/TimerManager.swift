import Foundation
import Combine

/// Manages the productivity timer with progress tracking and persistence
class TimerManager: ObservableObject {
    // MARK: - Published Properties

    /// Current progress from 0.0 to 1.0
    @Published var progress: Double = 0.0

    /// Whether the timer has completed
    @Published var isCompleted: Bool = false

    /// Elapsed time in seconds
    @Published var elapsedTime: TimeInterval = 0

    /// Remaining time in seconds
    @Published var remainingTime: TimeInterval = 7200

    // MARK: - Properties

    /// Timer interval in seconds (default: 2 hours = 7200 seconds)
    var timerInterval: TimeInterval {
        get {
            PreferencesManager.shared.timerInterval
        }
        set {
            PreferencesManager.shared.timerInterval = newValue
            updateProgress()
        }
    }

    /// Callback when timer completes
    var onTimerComplete: (() -> Void)?

    // MARK: - Private Properties

    private var timer: DispatchSourceTimer?
    private var startTime: Date?
    private let queue = DispatchQueue(label: "com.clapclap.timerqueue", qos: .userInteractive)
    private var isRunning: Bool = false

    // MARK: - Initialization

    init() {
        loadTimerState()
        updateProgress()
    }

    deinit {
        stopTimer()
    }

    // MARK: - Public Methods

    /// Start the timer
    func startTimer() {
        guard !isRunning else { return }

        // If no start time exists, create one
        if startTime == nil {
            startTime = Date()
            saveTimerState()
        }

        isRunning = true

        // Create dispatch timer for high accuracy
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: 1.0) // Fire every 1 second

        timer.setEventHandler { [weak self] in
            self?.timerTick()
        }

        timer.resume()
        self.timer = timer

        print("TimerManager: Timer started")
    }

    /// Stop the timer (but preserve state)
    func stopTimer() {
        guard isRunning else { return }

        isRunning = false
        timer?.cancel()
        timer = nil

        print("TimerManager: Timer stopped")
    }

    /// Reset the timer to zero
    func resetTimer() {
        stopTimer()

        startTime = Date()
        saveTimerState()

        DispatchQueue.main.async {
            self.progress = 0.0
            self.isCompleted = false
            self.elapsedTime = 0
            self.remainingTime = self.timerInterval
        }

        startTimer()

        print("TimerManager: Timer reset")
    }

    /// Get elapsed time since start
    func getElapsedTime() -> TimeInterval {
        guard let startTime = startTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }

    /// Get remaining time until completion
    func getRemainingTime() -> TimeInterval {
        let remaining = timerInterval - getElapsedTime()
        return max(0, remaining)
    }

    // MARK: - Private Methods

    /// Called every second by the timer
    private func timerTick() {
        updateProgress()

        // Check if completed
        if progress >= 1.0 && !isCompleted {
            DispatchQueue.main.async {
                self.isCompleted = true
                self.stopTimer()
                self.onTimerComplete?()
                print("TimerManager: Timer completed!")
            }
        }
    }

    /// Update progress and time values
    private func updateProgress() {
        let elapsed = getElapsedTime()
        let remaining = getRemainingTime()
        let calculatedProgress = min(elapsed / timerInterval, 1.0)

        DispatchQueue.main.async {
            self.elapsedTime = elapsed
            self.remainingTime = remaining
            self.progress = calculatedProgress
        }
    }

    /// Save timer state to preferences
    private func saveTimerState() {
        PreferencesManager.shared.timerStartTime = startTime
    }

    /// Load timer state from preferences
    private func loadTimerState() {
        if let savedStartTime = PreferencesManager.shared.timerStartTime {
            startTime = savedStartTime

            // Check if timer should already be completed
            let elapsed = getElapsedTime()
            if elapsed >= timerInterval {
                DispatchQueue.main.async {
                    self.isCompleted = true
                    self.progress = 1.0
                    self.elapsedTime = elapsed
                    self.remainingTime = 0
                }
            } else {
                // Timer still running, resume it
                startTimer()
            }
        } else {
            // No saved state, start fresh
            startTime = Date()
            saveTimerState()
            startTimer()
        }
    }

    // MARK: - Helper Methods

    /// Format time interval as MM:SS
    func formatTime(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    /// Get formatted elapsed time
    func getFormattedElapsedTime() -> String {
        return formatTime(elapsedTime)
    }

    /// Get formatted remaining time
    func getFormattedRemainingTime() -> String {
        return formatTime(remainingTime)
    }
}
