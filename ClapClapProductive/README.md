# 👏 ClapClapProductive

> A macOS menu bar productivity app that keeps you focused by detecting clap sounds. Clap twice to activate focus mode and manage your workspace automatically.

[![macOS](https://img.shields.io/badge/macOS-11.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## ✨ Features

### 🎤 Smart Clap Detection
- **Real-time audio processing** using AVFoundation
- **Double-clap recognition** with advanced signal analysis
- **Weak clap warnings** to help you clap louder for better detection
- **Intelligent microphone management** - only active when needed to save battery

### ⏰ Configurable Timer System
- **Customizable intervals** - choose from 15 minutes to 2 hours
- **Visual progress indicator** in menu bar with elegant namaste hands icon
- **Persistent timer** that survives app restarts
- **Auto-reset** for continuous productivity cycles

### 🎯 Focus Mode Automation
- **Opens productivity apps** you've selected
- **Closes distractions** automatically
- **Smart app management** using macOS APIs
- **System app protection** - won't close Finder, Dock, etc.

### 🎨 Beautiful Interface
- **SwiftUI-powered** onboarding and popups
- **Menu bar integration** with custom Core Graphics icon
- **Searchable app selector** with real-time filtering
- **Clean, modern design** following macOS design guidelines

## 📥 Download

**[Download Latest Release (v1.0.0)](https://github.com/vaibhavgeek/clap-clap-productive/releases/tag/v1.0.0)**

1. Download `ClapClapProductive.zip`
2. Unzip and move `ClapClapProductive.app` to your Applications folder
3. Launch the app and grant microphone permissions
4. Complete onboarding to select your productivity apps
5. Start clapping to stay focused!

## 🚀 Quick Start

### Installation

#### Option 1: Download Pre-built App (Recommended)
See [Download](#-download) section above.

#### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/vaibhavgeek/clap-clap-productive.git

# Navigate to the project
cd clap-clap-productive/multi-agent/ClapClapProductive

# Open in Xcode
open ClapClapProductive.xcodeproj

# Build and run (⌘R)
```

### First Launch

1. **Grant Microphone Access** - Click "OK" when prompted
2. **Complete Onboarding** - Select apps you want to keep open during focus mode
3. **Configure Timer** - Right-click menu bar icon → "Set Interval..." (optional)
4. **Start Working** - The timer will track your productivity session

## 💡 How It Works

### Basic Workflow

```
1. Timer Runs → Menu bar icon fills progressively
2. Timer Completes → Popup appears: "Did you clap? 👏"
3. Clap Twice → Focus mode activates:
   ✓ Selected apps open and focus
   ✓ Other apps close
   ✓ Timer resets
```

### Manual Activation

You can clap twice **anytime** to:
- Activate focus mode immediately
- Dismiss the popup
- Reset the timer to start a new session

### Weak Clap Detection

If your clap isn't strong enough, the app will show a warning:
- ⚠️ "Weak clap detected - try clapping louder!"
- Helps you adjust your clapping strength for better detection

## ⚙️ Configuration

### Timer Intervals

Right-click the menu bar icon → **"Set Interval..."** to choose:
- **15 minutes** - Frequent check-ins
- **30 minutes** - Regular reminders
- **1 hour** - Balanced approach (default)
- **2 hours** - Deep focus sessions

### App Selection

Right-click the menu bar icon → **"Preferences..."** to:
- Add or remove productivity apps
- Update your focus mode configuration
- Search through all installed apps

### Menu Bar Options

Right-click the menu bar icon:
- **Progress: X%** - Current timer status
- **Reset Timer** - Manually reset to 0%
- **Set Interval...** - Change timer duration
- **Preferences...** - Update app selections
- **Quit** - Exit the application

## 🏗️ Architecture

### Project Structure

```
ClapClapProductive/
├── ClapClapProductive/
│   ├── ClapClapProductiveApp.swift    # App entry point
│   ├── AppDelegate.swift               # Main coordinator
│   │
│   ├── Controllers/
│   │   └── MenuBarController.swift    # Menu bar management
│   │
│   ├── Views/
│   │   ├── OnboardingView.swift       # App selection screen
│   │   ├── PopupView.swift            # Timer completion popup
│   │   └── IntervalSettingsView.swift # Timer configuration
│   │
│   ├── Services/
│   │   ├── ClapDetector.swift         # Audio processing & detection
│   │   ├── TimerManager.swift         # Timer logic & persistence
│   │   ├── AppManager.swift           # macOS app control
│   │   └── PreferencesManager.swift   # Settings storage
│   │
│   └── Assets.xcassets/               # App icons & resources
│
├── goose_subagents/                   # Multi-agent development configs
└── README.md                          # This file
```

### Key Components

#### ClapDetector
- Uses **AVFoundation** for microphone capture
- Analyzes audio with:
  - Energy threshold detection
  - Peak-to-RMS ratio analysis
  - Zero-crossing rate calculation
- Detects weak claps and provides feedback
- Smart microphone lifecycle (only active when popup is shown)

#### TimerManager
- **ObservableObject** with @Published properties
- 1-second update intervals
- Persists state using UserDefaults
- Calculates progress (0.0 to 1.0) for visualization

#### AppManager
- Scans installed applications
- Uses **NSWorkspace** and **NSRunningApplication** APIs
- Manages app lifecycle (open, focus, close)
- Protects system-critical apps

#### MenuBarController
- Creates **NSStatusItem** in menu bar
- Custom icon drawn with **Core Graphics**
- Namaste/prayer hands design with progressive fill
- Observes timer via **Combine**

## 🛠️ Requirements

- **macOS 11.0 (Big Sur)** or later
- **Microphone access** for clap detection
- **Xcode 15.0+** (for building from source)

### Permissions

The app requires:

1. **Microphone** (Required)
   - Purpose: Detect clap sounds
   - Prompted on first launch

2. **Accessibility** (Recommended)
   - Purpose: Control other applications
   - May need manual enablement in System Settings

## 🧪 Testing

### Debug Mode

Run in Xcode to see detailed logs:
- `[ClapDetector]` - Audio analysis and clap detection
- `[TimerManager]` - Timer state and progress
- `[AppManager]` - App operations
- `[AppDelegate]` - Application flow
- `[MenuBarController]` - Menu bar updates

### Testing Checklist

- [ ] Menu bar icon appears
- [ ] Onboarding shows on first launch
- [ ] App selection works
- [ ] Search filters apps correctly
- [ ] Timer interval can be changed
- [ ] Menu bar icon fills progressively
- [ ] Popup appears when timer completes
- [ ] Clap detection works (check console)
- [ ] Weak clap warning appears for soft claps
- [ ] Selected apps open/focus on clap
- [ ] Non-selected apps close
- [ ] Timer resets after activation
- [ ] Preferences persist after restart

## 🐛 Troubleshooting

### Microphone Not Working

**Problem**: Claps aren't detected

**Solutions**:
1. Check **System Settings → Privacy & Security → Microphone**
2. Ensure **ClapClapProductive** is enabled
3. Restart the app after granting permission
4. Test your microphone in Voice Memos
5. Try clapping louder or closer to the mic

### Apps Not Opening/Closing

**Problem**: Focus mode doesn't manage apps

**Solutions**:
1. Check **System Settings → Privacy & Security → Accessibility**
2. Enable **ClapClapProductive** in Accessibility
3. Some apps may require additional permissions
4. System apps (Finder, Dock) cannot be closed by design

### Menu Bar Icon Not Visible

**Problem**: Can't see the icon

**Solutions**:
1. Check if menu bar is full (macOS hides icons when crowded)
2. Try hiding other menu bar icons
3. Look for the namaste hands icon
4. Check Xcode console for errors

### Weak Clap Warnings

**Problem**: Always getting weak clap warnings

**Solutions**:
1. Clap louder and sharper
2. Move closer to your Mac's microphone
3. Reduce ambient noise
4. Try clapping with cupped hands for more volume
5. Check microphone input level in System Settings

## 🔮 Future Enhancements

- [ ] Custom clap patterns (triple clap, etc.)
- [ ] Haptic feedback for successful detection
- [ ] Multiple app profiles (work, study, creative)
- [ ] Productivity statistics and tracking
- [ ] Keyboard shortcuts as alternatives
- [ ] Sound feedback for clap detection
- [ ] Pomodoro timer integration
- [ ] Export/import preferences
- [ ] Notification center integration
- [ ] Menu bar icon themes

## 🤖 Multi-Agent Development

This project was developed using a multi-agent approach with specialized agents:

```
goose_subagents/
├── agents/
│   ├── audio-specialist.md    # Audio processing expert
│   ├── backend-core.md         # Core architecture specialist
│   └── ui-specialist.md        # UI/UX designer
└── settings.local.json         # Agent configuration
```

Each agent focused on their domain expertise, enabling rapid development of complex features.

## 📊 Technology Stack

- **Language**: Swift 5.0+
- **UI Framework**: SwiftUI + AppKit
- **Audio**: AVFoundation
- **Reactive**: Combine
- **Graphics**: Core Graphics
- **Storage**: UserDefaults + JSON
- **APIs**: NSWorkspace, NSRunningApplication

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with **Claude Code** - AI-powered development assistant
- Uses native macOS frameworks for seamless integration
- Inspired by productivity methodologies and focus techniques

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs via [GitHub Issues](https://github.com/vaibhavgeek/clap-clap-productive/issues)
- Submit feature requests
- Create pull requests

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/vaibhavgeek/clap-clap-productive/issues)
- **Releases**: [GitHub Releases](https://github.com/vaibhavgeek/clap-clap-productive/releases)

---

**Made with ❤️ and 👏 for better productivity**

Stay focused, clap twice, and get things done! 🚀
