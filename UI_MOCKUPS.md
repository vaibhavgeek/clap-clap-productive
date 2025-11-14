# ClapClap Productive - UI Mockups & Visual Guide

## 1. Menu Bar Icon States

### Initial State (0% Progress)
```
┌────┐
│ ╱╲ │  <- Empty outlines of two hands
│╱  ╲│     Only strokes visible, no fill
└────┘
```

### 25% Progress
```
┌────┐
│ ╱╲ │  <- Hands with bottom 25% filled
│▓  ▓│     Shaded area shows fill
└────┘
```

### 50% Progress
```
┌────┐
│▒╱╲▒│  <- Hands half filled
│▓  ▓│     Clear visual progress
└────┘
```

### 100% Progress (Completed)
```
┌────┐
│▓╱╲▓│  <- Hands fully filled
│▓  ▓│     Ready to trigger popup
└────┘
```

### Menu Bar Context Menu
```
┌────────────────────────────┐
│ Progress: 42%              │ (disabled, gray text)
├────────────────────────────┤
│ Reset Timer             ⌘R │
│ Preferences...          ⌘, │
├────────────────────────────┤
│ Quit ClapClap Productive⌘Q │
└────────────────────────────┘
```

---

## 2. Onboarding Window (500x600)

```
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     Welcome to ClapClap Productive 👏            ║
║                                                   ║
║   Select apps to keep open and focused during    ║
║          your productivity sessions              ║
║                                                   ║
║   ┌─────────────────────────────────────────┐   ║
║   │ 🔍 Search apps...                       │   ║
║   └─────────────────────────────────────────┘   ║
║                                                   ║
║   ┌─────────────────────────────────────────┐   ║
║   │ ☐  📱 Calculator                        │   ║
║   │────────────────────────────────────────│   ║
║   │ ☐  📄 Notes                             │   ║
║   │────────────────────────────────────────│   ║
║   │ ☑  🌐 Safari                            │   ║
║   │────────────────────────────────────────│   ║  Scrollable
║   │ ☐  💬 Slack                             │   ║  list of
║   │────────────────────────────────────────│   ║  apps
║   │ ☑  📧 Mail                              │   ║
║   │────────────────────────────────────────│   ║
║   │ ☑  💻 Visual Studio Code                │   ║
║   │────────────────────────────────────────│   ║
║   │ ☐  🎵 Music                             │   ║
║   │────────────────────────────────────────│   ║
║   │ ...                                     │   ║
║   └─────────────────────────────────────────┘   ║
║                                                   ║
║              3 apps selected                     ║
║                                                   ║
║   ┌─────────────────────────────────────────┐   ║
║   │             Continue                     │   ║
║   └─────────────────────────────────────────┘   ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
```

### Onboarding - Loading State
```
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     Welcome to ClapClap Productive 👏            ║
║                                                   ║
║                                                   ║
║                                                   ║
║                                                   ║
║                      ⟳                           ║
║                                                   ║
║              Loading apps...                     ║
║                                                   ║
║                                                   ║
║                                                   ║
║                                                   ║
║                                                   ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
```

### Onboarding - Empty Search State
```
╔═══════════════════════════════════════════════════╗
║                                                   ║
║     Welcome to ClapClap Productive 👏            ║
║                                                   ║
║   Select apps to keep open and focused during    ║
║          your productivity sessions              ║
║                                                   ║
║   ┌─────────────────────────────────────────┐   ║
║   │ 🔍 Photoshop                        ✖  │   ║
║   └─────────────────────────────────────────┘   ║
║                                                   ║
║                                                   ║
║                                                   ║
║                      🔍                          ║
║                                                   ║
║         No apps match 'Photoshop'                ║
║                                                   ║
║                                                   ║
║                                                   ║
║                                                   ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
```

### App Row - Normal State
```
┌──────────────────────────────────────────────────┐
│ ☐  📱  Calculator                                │
└──────────────────────────────────────────────────┘
```

### App Row - Selected State (highlighted)
```
┌──────────────────────────────────────────────────┐
│ ☑  💻  Visual Studio Code                        │ <- Blue tint background
└──────────────────────────────────────────────────┘
```

### App Row - Hover State
```
┌──────────────────────────────────────────────────┐
│ ☐  🌐  Safari                                    │ <- Subtle highlight
└──────────────────────────────────────────────────┘
```

---

## 3. Popup Window (300x250)

### Normal State
```
┌────────────────────────────────────┐
│                                    │
│                                    │
│             👏                     │  <- Pulse animation
│          (pulsing)                 │     (1.0x ↔ 1.1x scale)
│                                    │
│                                    │
│       Did you clap?                │
│                                    │
│       Time to focus!               │
│                                    │
│      ⏱ Closes in 8s                │
│                                    │
│                                    │
│  ┌────────────────────────────┐   │
│  │        Dismiss             │   │
│  └────────────────────────────┘   │
│                                    │
└────────────────────────────────────┘
```

### Countdown Sequence
```
Closes in 10s → 9s → 8s → 7s → 6s → 5s → 4s → 3s → 2s → 1s → Auto-close
```

### Animation Timeline
```
t=0s:   Popup appears, emoji starts pulsing
t=0-10s: Countdown decrements every second
t=10s:  Auto-dismiss (or earlier if user clicks Dismiss)
```

---

## 4. Notifications

### Setup Complete Notification
```
╔═══════════════════════════════════╗
║ ClapClap Productive               ║
║───────────────────────────────────║
║ Setup complete! Clap twice to     ║
║ activate focus mode.              ║
╚═══════════════════════════════════╝
```

### Focus Mode Activated Notification
```
╔═══════════════════════════════════╗
║ Focus Mode Activated              ║
║───────────────────────────────────║
║ Your productivity apps are now    ║
║ active. Stay focused!             ║
╚═══════════════════════════════════╝
```

### No Apps Configured Notification
```
╔═══════════════════════════════════╗
║ ClapClap Productive               ║
║───────────────────────────────────║
║ Please configure your             ║
║ productivity apps first.          ║
╚═══════════════════════════════════╝
```

---

## 5. Complete User Journey Flowchart

```
┌─────────────────┐
│  App Launch     │
└────────┬────────┘
         │
         v
   ┌──────────┐
   │ First    │ No
   │ Launch?  ├────────────────┐
   └────┬─────┘                │
        │ Yes                  │
        v                      │
┌───────────────┐              │
│ Show          │              │
│ Onboarding    │              │
└───────┬───────┘              │
        │                      │
        v                      │
┌───────────────┐              │
│ User Selects  │              │
│ Apps          │              │
└───────┬───────┘              │
        │                      │
        v                      │
┌───────────────┐              │
│ Click         │              │
│ Continue      │              │
└───────┬───────┘              │
        │                      │
        v                      │
        │◄─────────────────────┘
        │
        v
┌───────────────┐
│ Menu Bar Icon │
│ Appears       │
│ (0% filled)   │
└───────┬───────┘
        │
        v
┌───────────────┐
│ Timer Starts  │
│ Icon Fills    │
│ Progressively │
└───────┬───────┘
        │
        v
  ┌──────────┐
  │ Timer    │
  │ Complete?│ No
  └────┬─────┘ └───┐
       │ Yes       │
       v           │
┌───────────────┐  │
│ Show Popup    │  │
│ "Did you      │  │
│  clap?"       │  │
└───────┬───────┘  │
        │          │
        v          │
  ┌──────────┐    │
  │ 10s      │    │
  │ Timeout? │ No │
  └────┬─────┘ └──┘
       │ Yes
       v
┌───────────────┐
│ Popup         │
│ Auto-Dismiss  │
└───────────────┘


PARALLEL: Clap Detection
┌───────────────┐
│ User Claps    │
│ Twice         │
└───────┬───────┘
        │
        v
  ┌──────────┐
  │ Apps     │ No
  │ Selected?├────────┐
  └────┬─────┘        │
       │ Yes          v
       v        ┌───────────┐
┌───────────┐   │ Show      │
│ Open &    │   │ Onboarding│
│ Focus     │   └───────────┘
│ Apps      │
└─────┬─────┘
      │
      v
┌───────────┐
│ Close     │
│ Other     │
│ Apps      │
└─────┬─────┘
      │
      v
┌───────────┐
│ Reset     │
│ Timer     │
└─────┬─────┘
      │
      v
┌───────────┐
│ Show      │
│ "Focus    │
│  Mode"    │
│ Notice    │
└───────────┘
```

---

## 6. Color Scheme

### Light Mode
```
Background:        White (#FFFFFF)
Secondary BG:      Light Gray (#F5F5F5)
Text Primary:      Black (#000000)
Text Secondary:    Gray (#6C6C6C)
Accent Color:      Blue (#007AFF) - macOS system accent
Separator:         Light Gray (#E5E5E5)
Selected BG:       Blue 10% opacity (#007AFF1A)
```

### Dark Mode
```
Background:        Dark Gray (#1E1E1E)
Secondary BG:      Darker Gray (#2C2C2C)
Text Primary:      White (#FFFFFF)
Text Secondary:    Light Gray (#A0A0A0)
Accent Color:      Blue (#0A84FF) - macOS system accent
Separator:         Dark Gray (#404040)
Selected BG:       Blue 20% opacity (#0A84FF33)
```

---

## 7. Typography

```
Title:             SF Pro Display, 28pt, Bold
Subtitle:          SF Pro Text, 14pt, Regular
Section Header:    SF Pro Text, 16pt, Semibold
Body Text:         SF Pro Text, 13pt, Regular
Caption:           SF Pro Text, 12pt, Regular
Menu Item:         SF Pro Text, 13pt, Regular
Button:            SF Pro Text, 14pt, Semibold
Large Display:     SF Pro Display, 32pt, Bold
Emoji Large:       64pt
Emoji Menu Bar:    18pt
```

---

## 8. Spacing & Layout

```
Window Padding:        30pt
Element Spacing:       20pt
Compact Spacing:       8pt
Row Height:            32pt
Button Height:         36pt
Search Bar Height:     36pt
Icon Size (List):      24x24pt
Icon Size (Menu Bar):  18x18pt
Corner Radius:         8pt
```

---

## 9. Interaction States

### Button States
```
Normal:    Blue background, white text
Hover:     Darker blue, cursor changes
Pressed:   Even darker, slight scale
Disabled:  Gray background, gray text
```

### Checkbox States
```
Unchecked: ☐ Empty square outline
Checked:   ☑ Filled square with checkmark
Hover:     Subtle highlight
```

### Text Field States
```
Normal:    Gray border, white background
Focus:     Blue border, white background
Disabled:  Gray border, gray background
```

---

## 10. Animation Specifications

### Menu Bar Icon Fill
```
Duration:     Continuous over timer period
Easing:       Linear
Direction:    Bottom to top
Refresh Rate: Every 1 second
```

### Popup Emoji Pulse
```
Duration:     0.6 seconds
Easing:       Ease in/out
Scale Range:  1.0x to 1.1x
Repeat:       Forever, auto-reverse
```

### Window Transitions
```
Appear:       Fade in (0.2s)
Disappear:    Fade out (0.2s)
```

### List Scrolling
```
Type:         Smooth scroll
Momentum:     Enabled
Bounce:       Enabled (native macOS)
```

---

## 11. Accessibility

### VoiceOver Labels
```
Menu Bar Icon:     "ClapClap Productive, progress: 42 percent"
Onboarding Search: "Search applications"
App Checkbox:      "Select Safari for focus mode"
Continue Button:   "Continue with 3 selected apps"
Popup Dismiss:     "Dismiss popup"
Menu Items:        Standard menu item labels
```

### Keyboard Navigation
```
Tab:              Navigate between elements
Space:            Toggle checkbox/button
Return:           Activate default button
Escape:           Close popup/window
Cmd+Q:            Quit application
Cmd+R:            Reset timer
Cmd+,:            Open preferences
```

### Contrast Ratios
```
All text:         Meets WCAG AA (4.5:1 minimum)
Large text:       Meets WCAG AAA (7:1 minimum)
Interactive:      Clear focus indicators
```

---

## 12. Window Behaviors

### Onboarding Window
```
Type:             Standard window
Resizable:        No (fixed 500x600)
Minimize:         Yes
Close:            Yes (doesn't quit app)
Level:            Floating (above other windows)
Position:         Centered on screen
```

### Popup Window
```
Type:             Borderless with controls
Resizable:        No (fixed 300x250)
Minimize:         No
Close:            Yes
Level:            Floating (always on top)
Position:         Centered on screen
Background:       Semi-transparent
```

### Menu Bar Behavior
```
Always Visible:   Yes
Position:         Right side (near clock)
Click:            Shows menu
Hover:            Shows tooltip
Icon Size:        18x18pt (adaptive)
```

---

## Design Inspiration & References

The UI follows standard macOS design patterns:
- **Human Interface Guidelines**: Apple HIG for macOS
- **Menu Bar Apps**: Similar to Spotlight, Time Machine, Battery
- **Modern SwiftUI**: Clean, minimal, native appearance
- **Progressive Disclosure**: Simple → Advanced as needed

All components use native macOS controls and styling for consistency.
