# Quick Test Guide - Clap Detection

## Test Now! 🚀

### 1. Build and Run
```bash
cd /Users/user/projects/clap-clap-productive/multi-agent/ClapClapProductive
open ClapClapProductive.xcodeproj
```
Press **Cmd+R** in Xcode

### 2. Open Console (Cmd+Shift+Y)

### 3. Look for These Messages

**✅ Audio Engine Started:**
```
[ClapDetector] Started listening for claps (thresholds: amplitude=0.08, ratio=2.0, zcr=0.15)
```

**✅ Audio Flowing (every ~2 seconds):**
```
[ClapDetector] Audio flowing: peak=0.012, rms=0.003, ratio=4.21, zcr=0.145
```

### 4. CLAP TWICE!

**✅ You Should See:**
```
[ClapDetector] 👏 CLAP DETECTED! peak=0.095, ratio=2.18, zcr=0.163
[ClapDetector] Single clap detected
[ClapDetector] 👏 CLAP DETECTED! peak=0.088, ratio=2.24, zcr=0.165
[ClapDetector] Double clap detected! (interval: 0.45s)
```

---

## What Changed?

### OLD THRESHOLDS (Too Strict ❌)
- Amplitude: 0.15
- Peak-to-RMS: 3.0
- Zero-crossing: 0.2

### NEW THRESHOLDS (More Sensitive ✅)
- Amplitude: **0.08** (↓ 47%)
- Peak-to-RMS: **2.0** (↓ 33%)
- Zero-crossing: **0.15** (↓ 25%)

---

## Still Not Working?

### Check Console for "Potential clap" Messages

Example:
```
[ClapDetector] Potential clap: peak=0.065[✓], ratio=1.85[✗], zcr=0.142[✗]
```

- ✓ = Passed threshold
- ✗ = Failed threshold

### Quick Fixes

**If peak fails [✗]:**
- Clap louder
- Move closer to mic

**If ratio fails [✗]:**
- Clap with sharper, crisper motion
- Try cupping your hands

**If zcr fails [✗]:**
- Make sure clap is sharp, not muffled
- Don't clap with soft materials

---

## Adjust Sensitivity

Open `ClapDetector.swift` and modify these lines:

**More Sensitive (if claps not detected):**
```swift
Line 47:  private var amplitudeThreshold: Float = 0.05  // Was 0.08
Line 50:  private let peakToRMSThreshold: Float = 1.5   // Was 2.0
Line 53:  private let zcrThreshold: Float = 0.10        // Was 0.15
```

**Less Sensitive (if too many false positives):**
```swift
Line 47:  private var amplitudeThreshold: Float = 0.12  // Was 0.08
Line 50:  private let peakToRMSThreshold: Float = 2.5   // Was 2.0
Line 53:  private let zcrThreshold: Float = 0.20        // Was 0.15
```

---

## Success! ✅

When working correctly, you'll see:
1. Audio flowing messages every 2 seconds
2. "CLAP DETECTED" when you clap
3. "Double clap detected" message
4. Apps opening/closing
5. Timer resetting

**The console logs tell you everything!** 📊
