import Foundation
import AVFoundation
import Accelerate
import AppKit

/// ClapDetector uses AVAudioEngine to capture microphone input and detect clap sounds
/// Detection algorithm: Analyzes amplitude spikes with sharp attack characteristics typical of clap sounds
/// Uses single-clap detection with 0.3-second confirmation delay to avoid false triggers
class ClapDetector {

    // MARK: - Properties

    /// Callback invoked when a clap is confirmed (after 0.3-second delay)
    var onDoubleClapDetected: (() -> Void)?

    /// Callback invoked when a weak clap is detected (not strong enough)
    var onWeakClapDetected: (() -> Void)?

    /// Audio engine for capturing microphone input
    private let audioEngine = AVAudioEngine()

    /// Input node from the microphone
    private var inputNode: AVAudioInputNode?

    /// Queue for audio processing to avoid blocking main thread
    private let audioProcessingQueue = DispatchQueue(label: "com.clapclapproductive.audioprocessing", qos: .userInitiated)

    /// Confirmation timer for single-clap detection
    /// Waits 0.3 seconds after clap before triggering action
    private var clapConfirmationTimer: DispatchWorkItem?

    /// Confirmation delay after detecting a clap (in seconds)
    /// Changed from double-clap to single-clap with confirmation delay
    private let confirmationDelay: TimeInterval = 0.3

    /// Cooldown period after triggering action to avoid repeated triggers
    private let actionCooldown: TimeInterval = 1.5

    /// Timestamp of last action trigger (for cooldown)
    private var lastActionTime: TimeInterval = 0

    /// Amplitude threshold for clap detection (normalized 0.0 to 1.0)
    /// Used as baseline for onset detection
    private var amplitudeThreshold: Float = 0.08

    /// Peak-to-RMS ratio threshold (increased to 4.0 based on research)
    /// Claps have sharp transients with ratios typically 4-10+
    private let peakToRMSThreshold: Float = 4.0

    /// Onset detection multiplier - current energy must exceed background by this factor
    /// Professional systems use 6-10x, we use 8x as a good middle ground
    private let onsetMultiplier: Float = 8.0

    /// Energy history for onset detection
    private var energyHistory: [Float] = []

    /// Number of frames to track for background energy calculation
    private let historyLength: Int = 5

    /// High-pass filter cutoff frequency to focus on clap frequencies
    private let highPassCutoff: Float = 1000.0 // Hz

    /// Running state
    private var isRunning = false

    /// Buffer counter for diagnostic logging
    private var bufferCount: Int = 0

    /// Lock for thread-safe access to timing variables
    private let timingLock = NSLock()

    // MARK: - Initialization

    init() {
        // Initialize clap detector
    }

    deinit {
        stopListening()
    }

    // MARK: - Public Methods

    /// Starts listening for clap sounds from the microphone
    /// Requests microphone permission if not already granted
    func startListening() {
        // Check if already running
        guard !isRunning else {
            print("[ClapDetector] Already listening")
            return
        }

        // Request microphone permission
        checkMicrophonePermission { [weak self] granted in
            guard let self = self else { return }

            if granted {
                self.audioProcessingQueue.async {
                    self.setupAudioEngine()
                }
            } else {
                print("[ClapDetector] Microphone permission denied")
                DispatchQueue.main.async {
                    self.showPermissionAlert()
                }
            }
        }
    }

    /// Stops listening for clap sounds and releases audio resources
    func stopListening() {
        guard isRunning else { return }

        audioEngine.stop()
        inputNode?.removeTap(onBus: 0)
        isRunning = false

        print("[ClapDetector] Stopped listening")
    }

    // MARK: - Private Methods - Permission Handling

    private func checkMicrophonePermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            completion(true)

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                completion(granted)
            }

        case .denied, .restricted:
            completion(false)

        @unknown default:
            completion(false)
        }
    }

    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Microphone Access Required"
        alert.informativeText = "ClapClapProductive needs microphone access to detect clap sounds. Please grant permission in System Preferences > Security & Privacy > Privacy > Microphone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    // MARK: - Private Methods - Audio Setup

    private func setupAudioEngine() {
        do {
            // Get the input node
            inputNode = audioEngine.inputNode
            guard let inputNode = inputNode else {
                print("[ClapDetector] Failed to get input node")
                return
            }

            // Get the input format
            let inputFormat = inputNode.outputFormat(forBus: 0)
            let sampleRate = inputFormat.sampleRate
            let channelCount = inputFormat.channelCount

            print("[ClapDetector] Audio format - Sample rate: \(sampleRate) Hz, Channels: \(channelCount)")

            // Define buffer size (increased to 2048 to capture full clap transient ~42ms @ 48kHz)
            // Research shows claps last 50-200ms, so we need larger buffers than 1024
            let bufferSize: AVAudioFrameCount = 2048

            // Install tap on the input node
            inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: inputFormat) { [weak self] (buffer, time) in
                self?.processAudioBuffer(buffer)
            }
            print("[ClapDetector] Audio tap installed successfully (buffer size: \(bufferSize))")

            // Prepare and start the audio engine
            audioEngine.prepare()
            try audioEngine.start()

            isRunning = true
            print("[ClapDetector] Started listening with SINGLE-CLAP + ONSET DETECTION (onset_mult=\(self.onsetMultiplier)x, peak/rms>\(self.peakToRMSThreshold), confirmation=\(self.confirmationDelay)s, buffer=\(bufferSize))")

        } catch {
            print("[ClapDetector] Error starting audio engine: \(error.localizedDescription)")
        }
    }

    // MARK: - Private Methods - Audio Processing

    /// Processes audio buffer to detect clap sounds using onset detection
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }

        let frameCount = Int(buffer.frameLength)

        // Increment buffer counter
        bufferCount += 1

        // Get samples from first channel
        let samples = Array(UnsafeBufferPointer(start: channelData[0], count: frameCount))

        // Calculate RMS (Root Mean Square) energy - represents current energy level
        let rms = calculateRMS(samples: samples)

        // Calculate current energy (RMS is a good energy measure)
        let currentEnergy = rms

        // Calculate peak amplitude
        let peak = calculatePeak(samples: samples)

        // Calculate peak-to-RMS ratio (measures transient sharpness)
        let peakToRMSRatio = rms > 0.001 ? peak / rms : 0

        // Update energy history for onset detection
        energyHistory.append(currentEnergy)
        if energyHistory.count > historyLength {
            energyHistory.removeFirst()
        }

        // Calculate background energy (average of previous frames)
        let backgroundEnergy = energyHistory.count >= historyLength
            ? energyHistory.dropLast().reduce(0, +) / Float(energyHistory.count - 1)
            : currentEnergy

        // Onset detection: current energy must significantly exceed background
        let onsetDetected = currentEnergy > (backgroundEnergy * onsetMultiplier) &&
                           currentEnergy > amplitudeThreshold

        // Diagnostic logging every 100 buffers (~4 seconds @ 48kHz with 2048 buffer)
        if bufferCount % 100 == 0 {
            print("[ClapDetector] Audio flowing - current=\(String(format: "%.4f", currentEnergy)), background=\(String(format: "%.4f", backgroundEnergy)), onset_ratio=\(String(format: "%.1f", currentEnergy / max(backgroundEnergy, 0.0001)))x, peak=\(String(format: "%.3f", peak)), ratio=\(String(format: "%.2f", peakToRMSRatio))")
        }

        // Detect clap based on research-backed criteria:
        // 1. ONSET: Sudden energy increase (current > background * 8x)
        // 2. TRANSIENT: High peak-to-RMS ratio (> 4.0)
        // Note: ZCR removed - research shows it was inverted and unreliable for claps

        let ratioCheck = peakToRMSRatio > peakToRMSThreshold

        let isClapDetected = onsetDetected && ratioCheck

        // Detect "weak clap" - has clap-like transient characteristics but not strong enough
        // We use a lower threshold (2.5) to identify sounds that are clap-like but weak
        // This filters out random noise which typically has ratio < 2.0
        let weakClapThreshold: Float = 2.5
        let isWeakClap = onsetDetected && !ratioCheck && peakToRMSRatio > weakClapThreshold

        // Log when we detect potential clap but not all criteria met
        if onsetDetected && !isClapDetected {
            if isWeakClap {
                print("[ClapDetector] ⚠️ WEAK CLAP detected: onset[\(onsetDetected ? "✓" : "✗")] (current=\(String(format: "%.4f", currentEnergy)) > bg=\(String(format: "%.4f", backgroundEnergy))*\(onsetMultiplier)), ratio=\(String(format: "%.2f", peakToRMSRatio))[\(ratioCheck ? "✓" : "✗")] (need >\(peakToRMSThreshold), has >\(weakClapThreshold))")

                // Notify that a weak clap was detected
                DispatchQueue.main.async { [weak self] in
                    self?.onWeakClapDetected?()
                }
            } else {
                print("[ClapDetector] ⚠️ ONSET detected but not clap-like: onset[\(onsetDetected ? "✓" : "✗")], ratio=\(String(format: "%.2f", peakToRMSRatio)) (too low, likely noise)")
            }
        }

        if isClapDetected {
            print("[ClapDetector] 👏 CLAP DETECTED! onset_ratio=\(String(format: "%.1f", currentEnergy / max(backgroundEnergy, 0.0001)))x, peak/rms=\(String(format: "%.2f", peakToRMSRatio)), peak=\(String(format: "%.3f", peak))")
            handleClapDetection()
        }
    }

    /// Calculates RMS (Root Mean Square) amplitude
    private func calculateRMS(samples: [Float]) -> Float {
        guard !samples.isEmpty else { return 0 }

        var sum: Float = 0.0
        vDSP_svesq(samples, 1, &sum, vDSP_Length(samples.count))

        let rms = sqrt(sum / Float(samples.count))
        return rms
    }

    /// Calculates peak amplitude
    private func calculatePeak(samples: [Float]) -> Float {
        guard !samples.isEmpty else { return 0 }

        var peak: Float = 0.0
        vDSP_maxmgv(samples, 1, &peak, vDSP_Length(samples.count))

        return peak
    }

    /// Zero-crossing rate calculation removed
    /// Research showed ZCR logic was inverted and unreliable for clap detection
    /// Onset detection + peak/RMS ratio is more effective

    /// Handles detection of a single clap with confirmation delay
    /// Waits 0.3 seconds after detecting a clap before triggering action
    /// If another clap arrives during confirmation, the timer resets
    private func handleClapDetection() {
        timingLock.lock()
        defer { timingLock.unlock() }

        let currentTime = Date().timeIntervalSince1970
        let timeSinceLastAction = currentTime - lastActionTime

        // Ignore claps during cooldown period (after action was triggered)
        if timeSinceLastAction < actionCooldown {
            print("[ClapDetector] Clap ignored - in cooldown period (\(String(format: "%.1f", actionCooldown - timeSinceLastAction))s remaining)")
            return
        }

        // Cancel any existing confirmation timer
        clapConfirmationTimer?.cancel()
        clapConfirmationTimer = nil

        print("[ClapDetector] Clap detected, starting \(confirmationDelay)s confirmation timer")

        // Create new confirmation timer
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            self.timingLock.lock()
            let now = Date().timeIntervalSince1970
            self.lastActionTime = now
            self.timingLock.unlock()

            print("[ClapDetector] ✅ Clap confirmed after \(self.confirmationDelay)s delay - triggering action")

            // Notify on main thread
            DispatchQueue.main.async {
                self.onDoubleClapDetected?()
            }
        }

        // Store the work item and schedule it
        clapConfirmationTimer = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + confirmationDelay, execute: workItem)
    }


    // MARK: - Advanced Features (Optional Enhancement)

    /// Updates the amplitude threshold for clap detection
    /// Lower values = more sensitive, higher values = less sensitive
    /// - Parameter threshold: Value between 0.0 and 1.0
    func setAmplitudeThreshold(_ threshold: Float) {
        // Clamp threshold to valid range
        let clampedThreshold = max(0.01, min(0.5, threshold))
        amplitudeThreshold = clampedThreshold
        print("[ClapDetector] Amplitude threshold updated to \(clampedThreshold)")
    }

    /// Returns current listening status
    func isListening() -> Bool {
        return isRunning
    }
}
