import SwiftUI

/// View for changing the timer interval
struct IntervalSettingsView: View {
    // MARK: - State Properties

    @State private var selectedInterval: TimeInterval

    /// Callback when settings are saved
    var onSave: ((TimeInterval) -> Void)?

    /// Callback when dismissed without saving
    var onCancel: (() -> Void)?

    // MARK: - Initialization

    init(currentInterval: TimeInterval, onSave: ((TimeInterval) -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        _selectedInterval = State(initialValue: currentInterval)
        self.onSave = onSave
        self.onCancel = onCancel
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Set Timer Interval")
                    .font(.system(size: 24, weight: .bold))

                Text("Choose how often you want to be reminded to stay focused")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 20)

            // Interval options
            VStack(spacing: 12) {
                IntervalOptionSmall(
                    title: "15 minutes",
                    subtitle: "Frequent check-ins",
                    interval: 900,
                    isSelected: selectedInterval == 900,
                    onSelect: { selectedInterval = 900 }
                )

                IntervalOptionSmall(
                    title: "30 minutes",
                    subtitle: "Regular reminders",
                    interval: 1800,
                    isSelected: selectedInterval == 1800,
                    onSelect: { selectedInterval = 1800 }
                )

                IntervalOptionSmall(
                    title: "1 hour",
                    subtitle: "Balanced approach",
                    interval: 3600,
                    isSelected: selectedInterval == 3600,
                    onSelect: { selectedInterval = 3600 }
                )

                IntervalOptionSmall(
                    title: "2 hours",
                    subtitle: "Deep focus sessions",
                    interval: 7200,
                    isSelected: selectedInterval == 7200,
                    onSelect: { selectedInterval = 7200 }
                )
            }
            .padding(.horizontal, 20)

            // Action buttons
            HStack(spacing: 12) {
                Button(action: {
                    print("[IntervalSettingsView] Cancelled")
                    onCancel?()
                }) {
                    Text("Cancel")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    print("[IntervalSettingsView] Saved interval: \(selectedInterval)s")
                    onSave?(selectedInterval)
                }) {
                    Text("Save")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(width: 400, height: 450)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Interval Option Small Component

struct IntervalOptionSmall: View {
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
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .accentColor : .secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(12)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct IntervalSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        IntervalSettingsView(currentInterval: 7200)
    }
}
