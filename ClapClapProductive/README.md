# ClapClap Productive 👏

A macOS menu bar productivity app that helps you stay focused by prompting you to clap twice. When you double-clap, it automatically opens your selected productivity apps and closes distractions.

## Features

- **Double Clap Detection**: Uses microphone to detect when you clap twice in quick succession
- **Progressive Timer**: Visual menu bar icon that fills over 2 hours to remind you to take breaks
- **Smart App Management**: Opens your chosen productivity apps and closes everything else
- **Clean UI**: Beautiful onboarding and popup interfaces built with SwiftUI
- **Persistent Preferences**: Remembers your app selections across restarts
- **Menu Bar Integration**: Unobtrusive menu bar icon with progress visualization

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later (for building)
- Microphone access (for clap detection)

## Installation & Setup

### 1. Open the Project

Navigate to the project directory and open the Xcode project:

```bash
cd /Users/user/projects/clap-clap-productive/multi-agent/ClapClapProductive
open ClapClapProductive.xcodeproj
```

### 2. Build and Run

1. Select your Mac as the build target (not a simulator)
2. Press **Cmd+R** or click the Run button in Xcode
3. The app will build and launch automatically

### 3. Grant Microphone Permission

On first launch, macOS will prompt you to grant microphone access:
- Click **OK** to allow microphone access
- If you accidentally deny, go to: **System Settings > Privacy & Security > Microphone**
- Enable the checkbox next to "ClapClapProductive"

### 4. Complete Onboarding

The onboarding window will appear on first launch:
1. Browse or search for your productivity apps
2. Select apps you want to keep open (e.g., VS Code, Safari, Notes)
3. Click **Continue** to save your preferences

## How to Use

### Basic Workflow

1. **Monitor Progress**: The menu bar icon fills progressively over 2 hours
2. **Timer Completes**: After 2 hours, a popup appears asking "Did you clap? 👏"
3. **Double Clap**: Clap your hands twice to activate focus mode
4. **Focus Mode Activates**:
   - Your selected apps open and come to focus
   - Other apps (except system apps) close
   - Timer resets for another 2-hour session

### Menu Bar Options

Right-click the menu bar icon to access:
- **Progress**: View current timer progress percentage
- **Reset Timer**: Manually reset the timer to 0%
- **Preferences...**: Reopen onboarding to change app selections
- **Quit ClapClap Productive**: Exit the application

### Double Clap Anytime

You don't have to wait for the popup! Double-clap at any time to:
- Activate focus mode immediately
- Reset the timer
- Dismiss any showing popups

## Testing the App

The app is configured with a **5-second timer in DEBUG mode** for easy testing.

### Testing Procedure

1. **Build and Run** the app in Xcode (Cmd+R)
2. **Complete onboarding** by selecting at least one app
3. **Wait 5 seconds** - the popup will appear
4. **Test clap detection**:
   - Clap twice near your microphone
   - Watch as your selected apps open
   - Observe other apps closing
   - See the timer reset to 0%

### Testing Checklist

- [ ] Menu bar icon appears in the top bar
- [ ] Onboarding shows on first launch
- [ ] App selection works with checkboxes
- [ ] Search bar filters apps correctly
- [ ] Can save and continue with selected apps
- [ ] Menu bar icon fills progressively (5 seconds)
- [ ] Popup appears after 5 seconds
- [ ] Popup auto-dismisses after 10 seconds
- [ ] Double clap is detected (check console logs)
- [ ] Selected apps open/focus on double clap
- [ ] Non-selected apps close (except system apps)
- [ ] Timer resets after double clap
- [ ] Right-click menu shows all options
- [ ] Preferences reopens onboarding
- [ ] Quit option exits the app
- [ ] Preferences persist after restart

### Viewing Debug Logs

Open the Xcode console to see detailed logs:
- `[ClapDetector]` - Clap detection events
- `[TimerManager]` - Timer state changes
- `[AppManager]` - App open/close operations
- `[AppDelegate]` - High-level app flow
- `[MenuBarController]` - Menu bar updates
- `[OnboardingView]` - Onboarding events
- `[PopupView]` - Popup lifecycle

## Switching to Production Mode

To use the **2-hour timer** instead of 5 seconds:

1. Open `AppDelegate.swift`
2. Find lines 26-29:
   ```swift
   #if DEBUG
   PreferencesManager.shared.timerInterval = 5.0
   print("[AppDelegate] DEBUG MODE: Timer set to 5 seconds for testing")
   #endif
   ```
3. Comment out or remove the DEBUG block
4. Rebuild the app

Alternatively, change the interval to any duration:
```swift
PreferencesManager.shared.timerInterval = 3600.0  // 1 hour
PreferencesManager.shared.timerInterval = 1800.0  // 30 minutes
```

## Troubleshooting

### Microphone Not Working

**Problem**: Clap detection doesn't work

**Solutions**:
1. Check System Settings > Privacy & Security > Microphone
2. Ensure ClapClapProductive has a checkmark
3. Restart the app after granting permission
4. Test your microphone in another app (Voice Memos)
5. Check Xcode console for `[ClapDetector]` error messages

### Apps Not Opening/Closing

**Problem**: Double clap doesn't manage apps

**Solutions**:
1. Check System Settings > Privacy & Security > Accessibility
2. Enable ClapClapProductive in Accessibility
3. Some apps may require additional permissions
4. System apps (Finder, Dock) cannot be closed by design
5. Check console for `[AppManager]` error messages

### Menu Bar Icon Not Appearing

**Problem**: Can't see the menu bar icon

**Solutions**:
1. Check your menu bar isn't full (macOS hides icons when crowded)
2. Try hiding other menu bar icons temporarily
3. Look for the clapping hands icon on the right side of the menu bar
4. Check Xcode console for `[MenuBarController]` errors

### Onboarding Doesn't Show

**Problem**: Can't select apps

**Solutions**:
1. Reset preferences: Delete app from Applications and rebuild
2. Manually clear preferences in code:
   ```swift
   PreferencesManager.shared.clearAllPreferences()
   ```
3. Right-click menu bar icon > Preferences to reopen onboarding

### App Crashes on Launch

**Problem**: App quits immediately

**Solutions**:
1. Check Xcode build errors
2. Clean build folder: Product > Clean Build Folder (Cmd+Shift+K)
3. Check macOS version is 13.0 or later
4. Review Xcode console for crash logs

## Architecture Overview

### Services Layer

- **ClapDetector** (`Services/ClapDetector.swift`)
  - Uses AVFoundation to capture microphone input
  - Analyzes audio for clap pattern (amplitude, ZCR, peak-to-RMS)
  - Detects double claps within 1-second window
  - Provides callback when double clap detected

- **TimerManager** (`Services/TimerManager.swift`)
  - ObservableObject with @Published properties
  - Tracks 2-hour productivity timer with 1-second updates
  - Persists state across app restarts
  - Calculates progress (0.0 to 1.0) for UI
  - Notifies when timer completes

- **AppManager** (`Services/AppManager.swift`)
  - Manages macOS application lifecycle
  - Scans for installed apps
  - Opens, focuses, and closes applications
  - Uses NSWorkspace and NSRunningApplication APIs
  - Protects system apps from being closed

- **PreferencesManager** (`Services/PreferencesManager.swift`)
  - Singleton for UserDefaults persistence
  - Stores selected apps, onboarding status, timer settings
  - JSON encoding/decoding for complex types
  - Thread-safe access

### UI Layer

- **AppDelegate** (`AppDelegate.swift`)
  - Main coordinator for all services and UI
  - Wires up callbacks between components
  - Manages window lifecycle
  - Handles focus mode activation

- **MenuBarController** (`Controllers/MenuBarController.swift`)
  - Creates and manages NSStatusItem
  - Draws custom progress icon with Core Graphics
  - Observes timer via Combine
  - Provides right-click menu

- **OnboardingView** (`Views/OnboardingView.swift`)
  - SwiftUI view for app selection
  - Searchable app list with checkboxes
  - Saves preferences on completion
  - Async app loading

- **PopupView** (`Views/PopupView.swift`)
  - SwiftUI view for timer completion notification
  - 10-second countdown with auto-dismiss
  - Animated emoji and clean design

## Project Structure

```
ClapClapProductive/
├── ClapClapProductive/
│   ├── ClapClapProductiveApp.swift    # App entry point
│   ├── AppDelegate.swift               # Main coordinator
│   ├── Info.plist                      # App metadata
│   ├── ClapClapProductive.entitlements # Permissions
│   │
│   ├── Controllers/
│   │   └── MenuBarController.swift    # Menu bar icon
│   │
│   ├── Views/
│   │   ├── OnboardingView.swift       # Onboarding screen
│   │   └── PopupView.swift            # Timer popup
│   │
│   ├── Services/
│   │   ├── ClapDetector.swift         # Audio detection
│   │   ├── TimerManager.swift         # Timer logic
│   │   ├── AppManager.swift           # App management
│   │   └── PreferencesManager.swift   # Data persistence
│   │
│   └── Assets.xcassets/               # App icons
│       └── AppIcon.appiconset/
│
├── ClapClapProductive.xcodeproj/      # Xcode project
└── README.md                           # This file
```

## Permissions Required

### Microphone (Required)
- **Purpose**: Detect clap sounds
- **Prompt**: Automatic on first launch
- **Settings**: System Settings > Privacy & Security > Microphone

### Accessibility (Recommended)
- **Purpose**: Control other applications
- **Prompt**: May be automatic or manual
- **Settings**: System Settings > Privacy & Security > Accessibility
- **Note**: Required for full app management capabilities

## Known Limitations

1. **Clap Detection Sensitivity**
   - May trigger on other sharp sounds (door slams, loud keyboard typing)
   - Soft claps may not register
   - Ambient noise can affect accuracy

2. **App Management**
   - Cannot close system-protected apps (Finder, Dock, SystemUIServer)
   - Some sandboxed apps may require additional permissions
   - Force quit not implemented (graceful termination only)

3. **Menu Bar Icon**
   - Uses simplified geometric shapes for hands (not detailed icons)
   - May be hidden if menu bar is crowded

4. **Timer Persistence**
   - Timer continues during system sleep
   - System time changes may affect timer accuracy

## Future Enhancements

- [ ] Customizable timer duration via UI
- [ ] Clap sensitivity calibration
- [ ] Multiple app profiles (work, study, creative)
- [ ] Statistics and productivity tracking
- [ ] Keyboard shortcuts for common actions
- [ ] Sound feedback for clap detection
- [ ] Dark mode optimizations
- [ ] App icon customization
- [ ] Export/import preferences
- [ ] Notification center integration

## Development

### Building from Source

```bash
# Clone or navigate to the project
cd /Users/user/projects/clap-clap-productive/multi-agent/ClapClapProductive

# Open in Xcode
open ClapClapProductive.xcodeproj

# Build and run
# Xcode: Product > Run (Cmd+R)
```

### Code Style

- Swift 5.0+
- SwiftUI for UI components
- Combine for reactive updates
- MARK comments for organization
- Comprehensive logging with prefixes

### Adding New Features

1. **New Service**: Add to `Services/` directory
2. **New View**: Add to `Views/` directory
3. **Wire Up**: Connect in `AppDelegate.swift`
4. **Test**: Add to testing checklist above

## Credits

Built with:
- Swift & SwiftUI
- AVFoundation (audio processing)
- AppKit (macOS integration)
- Combine (reactive programming)
- Core Graphics (custom icon drawing)

## License

This is a personal productivity project. Feel free to modify and extend for your own use.

---

**Enjoy staying productive with ClapClap! 👏**

For issues or questions, check the Xcode console logs for detailed debugging information.
