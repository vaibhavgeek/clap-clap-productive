# 👏 ClapClapProductive

> A macOS menu bar productivity app that keeps you focused by detecting clap sounds.

[![macOS](https://img.shields.io/badge/macOS-11.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen.svg)](https://github.com/vaibhavgeek/clap-clap-productive/releases)

## 📥 Download

**[Download ClapClapProductive v1.0.0](https://github.com/vaibhavgeek/clap-clap-productive/releases/tag/v1.0.0)**

## 🚀 What is ClapClapProductive?

ClapClapProductive is a macOS menu bar app that helps you stay focused and productive:

- 👏 **Clap Detection** - Detects when you clap twice near your Mac
- ⏰ **Configurable Timer** - Choose intervals from 15 minutes to 2 hours
- 🎯 **Auto Focus Mode** - Opens your productivity apps, closes distractions
- 🎨 **Beautiful Interface** - Native macOS design with SwiftUI

### How It Works

1. **Set Timer** - Configure your focus session duration
2. **Work** - Focus on your tasks while the timer runs
3. **Clap Twice** - When the timer completes or anytime you need focus
4. **Auto-Focus** - Your selected apps open, distractions close
5. **Repeat** - Timer resets for continuous productivity cycles

## 📂 Project Structure

This repository contains multiple development iterations:

```
clap-clap-productive/
├── multi-agent/ClapClapProductive/    # ⭐ Current version (v1.0.0)
│   ├── ClapClapProductive/            # Main application code
│   ├── goose_subagents/               # Multi-agent development configs
│   └── README.md                      # Full documentation
│
├── ClapClap/                          # Early prototype
├── one-shot/                          # Single-shot experiments
└── *.mp4                              # Demo videos
```

## 📖 Full Documentation

For complete documentation, installation instructions, and technical details:

👉 **[View Full README](multi-agent/ClapClapProductive/README.md)**

## ✨ Key Features

### 🎤 Smart Clap Detection
- Real-time audio processing using AVFoundation
- Advanced signal analysis for accurate detection
- Weak clap warnings to improve detection
- Battery-efficient microphone management

### ⏰ Flexible Timer System
- **15 minutes** - Frequent check-ins
- **30 minutes** - Regular reminders
- **1 hour** - Balanced approach
- **2 hours** - Deep focus sessions

### 🎯 Intelligent Focus Mode
- Opens your productivity apps automatically
- Closes distracting applications
- Protects system apps (Finder, Dock, etc.)
- Customizable app selection

### 🎨 Native macOS Integration
- Menu bar app with progress visualization
- SwiftUI-based modern interface
- Namaste hands icon design
- Follows macOS Human Interface Guidelines

## 🛠️ Quick Start

### Option 1: Download (Recommended)
1. Download from [Releases](https://github.com/vaibhavgeek/clap-clap-productive/releases)
2. Move to Applications folder
3. Launch and grant microphone permission
4. Select your productivity apps

### Option 2: Build from Source
```bash
git clone https://github.com/vaibhavgeek/clap-clap-productive.git
cd clap-clap-productive/multi-agent/ClapClapProductive
open ClapClapProductive.xcodeproj
# Build and run in Xcode (⌘R)
```

## 🤖 Multi-Agent Development

This project showcases a multi-agent development approach using specialized AI agents:

- **Audio Specialist** - Clap detection and audio processing
- **Backend Core** - Architecture and services
- **UI Specialist** - Interface design and user experience

Each agent focused on their domain expertise, enabling rapid development of a production-ready app.

## 🎥 Demo Videos

The repository includes demo videos showing the app in action:
- `one.mp4`, `two.mp4`, `third.mp4` - Feature demonstrations
- `one-one.mp4` - Extended usage walkthrough
- `download.mp4`, `download (1-3).mp4` - Various demos

## 📋 Requirements

- macOS 11.0 (Big Sur) or later
- Microphone access for clap detection
- Xcode 15.0+ (for building from source)

## 🤝 Contributing

Contributions are welcome! Please check the [full documentation](multi-agent/ClapClapProductive/README.md) for details.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/vaibhavgeek/clap-clap-productive/issues)
- **Releases**: [GitHub Releases](https://github.com/vaibhavgeek/clap-clap-productive/releases)
- **Documentation**: [Full README](multi-agent/ClapClapProductive/README.md)

---

**Made with ❤️ and 👏 for better productivity**

🚀 [Download Now](https://github.com/vaibhavgeek/clap-clap-productive/releases/tag/v1.0.0) | 📖 [Full Docs](multi-agent/ClapClapProductive/README.md) | 🐛 [Report Issue](https://github.com/vaibhavgeek/clap-clap-productive/issues)
