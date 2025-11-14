import SwiftUI

/// Onboarding view for selecting apps to keep open during productivity sessions
struct OnboardingView: View {
    // MARK: - State Properties

    @State private var currentStep = 0 // 0 = interval, 1 = app selection
    @State private var installedApps: [AppInfo] = []
    @State private var selectedApps: Set<AppInfo> = []
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var selectedInterval: TimeInterval = 7200 // Default 2 hours

    /// Callback when onboarding is completed
    var onComplete: (() -> Void)?

    // MARK: - Computed Properties

    /// Filtered apps based on search text
    var filteredApps: [AppInfo] {
        if searchText.isEmpty {
            return installedApps
        } else {
            return installedApps.filter { app in
                app.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 20) {
            if currentStep == 0 {
                intervalSelectionView
            } else {
                appSelectionView
            }
        }
        .frame(width: 500, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            loadApps()
            // Load saved interval
            selectedInterval = PreferencesManager.shared.timerInterval
        }
    }

    // MARK: - Interval Selection View

    private var intervalSelectionView: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Welcome to ClapClap Productive")
                    .font(.system(size: 28, weight: .bold))

                Text("How often should we remind you to stay focused?")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 30)

            Spacer()

            // Interval options
            VStack(spacing: 16) {
                IntervalOption(
                    title: "15 minutes",
                    subtitle: "Frequent check-ins",
                    interval: 900,
                    isSelected: selectedInterval == 900,
                    onSelect: { selectedInterval = 900 }
                )

                IntervalOption(
                    title: "30 minutes",
                    subtitle: "Regular reminders",
                    interval: 1800,
                    isSelected: selectedInterval == 1800,
                    onSelect: { selectedInterval = 1800 }
                )

                IntervalOption(
                    title: "1 hour",
                    subtitle: "Balanced approach",
                    interval: 3600,
                    isSelected: selectedInterval == 3600,
                    onSelect: { selectedInterval = 3600 }
                )

                IntervalOption(
                    title: "2 hours",
                    subtitle: "Deep focus sessions",
                    interval: 7200,
                    isSelected: selectedInterval == 7200,
                    onSelect: { selectedInterval = 7200 }
                )
            }
            .padding(.horizontal, 30)

            Spacer()

            // Continue button
            Button(action: { currentStep = 1 }) {
                Text("Continue")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.accentColor)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
        }
    }

    // MARK: - App Selection View

    private var appSelectionView: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Select Your Productivity Apps")
                    .font(.system(size: 28, weight: .bold))

                Text("Choose apps to keep open and focused during your productivity sessions")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 30)

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search apps...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(8)
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal, 30)

            // App list
            if isLoading {
                Spacer()
                ProgressView("Loading apps...")
                    .progressViewStyle(CircularProgressViewStyle())
                Spacer()
            } else if filteredApps.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)

                    Text(searchText.isEmpty ? "No apps found" : "No apps match '\(searchText)'")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                // App list with checkboxes
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
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .padding(.horizontal, 30)
            }

            // Selection count
            if !selectedApps.isEmpty {
                Text("\(selectedApps.count) app\(selectedApps.count == 1 ? "" : "s") selected")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            // Navigation buttons
            HStack(spacing: 12) {
                Button(action: { currentStep = 0 }) {
                    Text("Back")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: completeOnboarding) {
                    Text("Finish")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedApps.isEmpty ? Color.gray : Color.accentColor)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(selectedApps.isEmpty)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Methods

    private func loadApps() {
        isLoading = true

        // Load apps asynchronously to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async {
            let apps = AppManager.shared.getAllInstalledApps()

            DispatchQueue.main.async {
                self.installedApps = apps
                self.isLoading = false

                // Pre-select previously selected apps if any
                let savedApps = PreferencesManager.shared.selectedApps
                self.selectedApps = Set(savedApps)

                print("[OnboardingView] Loaded \(apps.count) apps")
            }
        }
    }

    private func toggleSelection(_ app: AppInfo) {
        if selectedApps.contains(app) {
            selectedApps.remove(app)
        } else {
            selectedApps.insert(app)
        }
    }

    private func completeOnboarding() {
        // Save preferences
        PreferencesManager.shared.selectedApps = Array(selectedApps)
        PreferencesManager.shared.timerInterval = selectedInterval
        PreferencesManager.shared.hasCompletedOnboarding = true

        print("[OnboardingView] Onboarding completed with \(selectedApps.count) apps selected and \(selectedInterval)s interval")

        // Call completion handler
        onComplete?()
    }
}

// MARK: - App Row Component

struct AppRow: View {
    let app: AppInfo
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Checkbox
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .accentColor : .secondary)

                // App icon (if available)
                if let iconPath = app.iconPath,
                   let nsImage = NSImage(contentsOfFile: iconPath) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .frame(width: 24, height: 24)
                } else {
                    // Default app icon
                    Image(systemName: "app.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                }

                // App name
                Text(app.name)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .bottom
        )
    }
}

// MARK: - Interval Option Component

struct IntervalOption: View {
    let title: String
    let subtitle: String
    let interval: TimeInterval
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Radio button
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .accentColor : .secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(16)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
