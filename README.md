# RightPosition

[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-blue.svg)](https://microsoft.com/windows)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Dependencies: None](https://img.shields.io/badge/Dependencies-Zero%20%28Standalone%29-brightgreen.svg)]()
[![Security: No DLL Injection](https://img.shields.io/badge/Security-No%20DLL%20Injection%20%7C%20User%20Space-success.svg)]()
[![Language: AHK v2](https://img.shields.io/badge/Language-AutoHotkey%20v2-orange.svg)](https://www.autohotkey.com/)

> **A lightweight, portable, and enterprise-ready window resizing & positioning utility for Windows 10 & 11.**  
> Built as a modern, auditable, and future-proof open-source alternative to legacy utilities like [Sizer 4.0](https://www.brianapps.net/sizer4/).

---

### 🌐 Language / Sprache
- **[🇩🇪 Deutsche Dokumentation (German Documentation)](README.de.md)**
- **🇬🇧 English Documentation (Current)**

---

## 🏢 Why RightPosition? (Enterprise & Open-Stack Ready)

Many developers, screencasters, QA engineers, and power users rely on window management utilities like Brian Apps' classic **Sizer** to enforce precise resolutions (e.g., 1080p, 720p) and reproducible window placements. However, in modern corporate environments, legacy tools face critical roadblocks:

1. **Closed-Source & Abandonware Risks**: Sizer is closed-source freeware maintained by a single author with irregular updates. Enterprise compliance teams cannot audit its binary, preventing rollout across secured workstations.
2. **Security & EDR Conflicts with Hook-Tools**: Alternatives like SmartSystemMenu use global DLL-injection (`WH_CALLWNDPROC` hooks) and require administrator privileges. Modern Endpoint Detection & Response (EDR) software (CrowdStrike, Defender for Endpoint, SentinelOne) routinely flags or blocks this behavior.
3. **Shortcomings of Native Windows & PowerToys Tools**: Built-in Windows 11 Snap Layouts and Microsoft PowerToys (FancyZones) only tile windows into fixed full-screen grid partitions. They cannot set arbitrary floating pixel dimensions (e.g., floating 1440×900 for video capture), nor can they capture and reapply a window's exact geometry on the fly.

**RightPosition** solves this by providing a **100% open, auditable, and lightweight stack**:
- **0 KB external runtimes**: Runs as a single portable 1.2 MB executable.
- **Zero Administrator Rights**: Operates completely in non-elevated user-space.
- **Zero DLL Injection**: No foreign process memory tampering; fully compliant with enterprise security policies.
- **Future-Proof**: Built directly against core Win32 User32 & DWM APIs that maintain backward- and forward-compatibility across Windows generations.

---

## 📊 Comprehensive Feature & Tool Comparison Matrix

| Feature / Criteria | 🚀 RightPosition | 📦 Sizer 4.0 | 🔧 SmartSystemMenu | 🪟 MS PowerToys (FancyZones) | 🖥️ Windows 11 Snap Layouts |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **1-Click Capture Size & Position** | ✔️ **Yes** | ✔️ Yes | ❌ No | ❌ No | ❌ No |
| **Restore Exact Pixel Dimensions** | ✔️ **Yes** | ✔️ Yes | ✔️ Yes (Size only) | ❌ No (Grid-bound) | ❌ No (Grid-bound) |
| **Free Floating Placement (X, Y)** | ✔️ **Yes** | ✔️ Yes | ❌ No (Predefined) | ❌ No (Tiled) | ❌ No (Tiled) |
| **Dedicated Language Dialog (EN & DE)** | ✔️ **Yes (Auto-detect)** | ❌ English only | ⚠️ Partial | ✔️ Yes | ✔️ Yes |
| **Interactive Shortcut Configurator (GUI)** | ✔️ **Yes (Live)** | ⚠️ INI only | ⚠️ Settings | ⚠️ Complex | ❌ Fixed (`Win+Z`) |
| **Auditable Open-Source Code** | ✔️ **100% (MIT)** | ❌ Closed Source | ✔️ Open Source | ✔️ Open Source | ❌ Closed Source |
| **No Admin Rights Required** | ✔️ **Yes** | ✔️ Yes | ⚠️ Needs Admin | ⚠️ Setup / Elevated | ✔️ Native |
| **No DLL-Injection (EDR-Friendly)** | ✔️ **Zero Hooks** | ✔️ Clean | ⚠️ DLL Injection | ✔️ Clean | ✔️ Native |
| **Modern App Support (Chrome/Electron)** | ✔️ **Full** | ⚠️ Partial | ⚠️ Buggy on CSD | ✔️ Full | ✔️ Full |
| **Multi-Monitor Intelligent Anchoring** | ✔️ **Yes** | ✔️ Yes | ✔️ Yes | ✔️ Yes | ✔️ Yes |
| **DWM Shadow Border Compensation** | ✔️ **Yes** (Pixel-exact) | ⚠️ Partial | ❌ No | ⚠️ Windows default | ⚠️ Windows default |
| **Footprint / System Overhead** | ✔️ **~1.2 MB Portable** | ✔️ Small | ⚠️ .NET Runtime | ⚠️ >200 MB Installation | ✔️ System native |
| **No Installation / Zero Registry Pollution** | ✔️ **Yes (Local INI)** | ✔️ Yes | ✔️ Yes | ❌ Requires Installer | ✔️ Native |

---

## 🌟 Highlights & Features

- **💾 1-Click Geometry Capture**: With a single click on any window, capture its visible width, height, and relative X/Y coordinates on its monitor, and save it as a named preset.
- **⭐ Instant Preset Restoration**: Presets appear directly at the top of the menu (`⭐`). Clicking a preset instantly snaps the window back to that exact size and position.
- **🌐 Full Localization (English & German)**: Built-in automatic language detection based on your Windows system locale, plus a dedicated **Language Settings dialog** to switch anytime between Automatic, German, and English.
- **⌨️ Customizable Shortcut (Interactive GUI)**: Change your hotkey anytime directly from the application menu or system tray without editing configuration files or restarting. Choose from popular presets (`Ctrl+Win+Z`, `Ctrl+Alt+Z`, `Win+Z`, `Ctrl+Alt+S`, etc.) or combine arbitrary modifier keys with instant live validation.
- **🖥️ Multi-Monitor Awareness**: Windows stay anchored to the display they currently reside on via Win32 `MonitorFromWindow`.
- **🪟 Windows 10/11 DWM Border Compensation**: Automatically accounts for invisible DWM drop shadows (~7–8 px) using `DwmGetWindowAttribute` to guarantee exact outer boundaries.
- **🖱️ Versatile, Non-Intrusive Triggers**:
  - **Middle-Click on Title Bar** (classic Sizer workflow, detected via crash-safe `WM_NCHITTEST`).
  - **<kbd>Ctrl</kbd> + Right-Click** on any window.
  - **Customizable Global Hotkey** (Default: <kbd>Ctrl</kbd> + <kbd>Win</kbd> + <kbd>Z</kbd>).
- **📋 Live Window Metrics**: Menu header displays the active window's dimensions; click to copy to clipboard.
- **📐 Custom Size Dialog**: Prompt for ad-hoc custom dimensions (e.g. `1280x720`).
- **⚙️ Portable INI Configuration**: Simple, human-readable [`settings.ini`](settings.ini).

---

## 🚀 Quick Start

### Running RightPosition
1. Download or copy the project files to any folder or USB drive.
2. Launch **`RightPosition.exe`**.
3. It appears in the notification area (system tray) with the custom icon.
4. Open the menu on any target window:
   - **Middle-click** the window title bar, **OR**
   - Press **<kbd>Ctrl</kbd> + <kbd>Win</kbd> + <kbd>Z</kbd>** (or your customized hotkey), **OR**
   - Press **<kbd>Ctrl</kbd> + Right-Click** on the window.
5. Select **`💾 Save Current Position & Size...`**, give it a name, and press <kbd>Enter</kbd>.
6. The preset is now permanently available at the top of the menu!

---

## 🌐 Language Settings

RightPosition includes a dedicated language dialog:
1. Open the window menu or right-click the system tray icon.
2. Click **`🌐 Language / Sprache...`**.
3. Choose:
   - **Automatic (Windows system language)**: Defaults to German on German Windows systems, English everywhere else.
   - **Deutsch (German)**
   - **English**
4. Click **`💾 Save & Apply`**. All menus, dialogs, and notifications switch immediately!

---

## ⌨️ Customizing the Shortcut & Trigger Options

### 1. Via the Built-in GUI (Recommended)
1. Right-click the **RightPosition system tray icon** or open the window menu.
2. Click **`⌨️ Shortcut & Settings...`**.
3. In the settings dialog:
   - Choose a quick preset (e.g. `Ctrl + Alt + Z`, `Win + Z`, `Ctrl + Alt + S`, `Alt + Space`, `Ctrl + F12`) or freely check the modifier boxes (**Strg/Ctrl**, **Win**, **Alt**, **Shift**) and select/type any key.
   - Preview your shortcut in real time.
   - Enable or disable mouse triggers (middle-click title bar, Ctrl+Right-click).
   - Toggle Windows 10/11 shadow border compensation and auto-start with Windows.
4. Click **`💾 Save & Apply`**. The new shortcut is validated and active immediately without restarting!

### 2. Via `settings.ini`
Advanced users can also edit [`settings.ini`](settings.ini) directly:
```ini
[Settings]
; Hotkey (^ = Ctrl, # = Win, ! = Alt, + = Shift)
Hotkey=^#z

; Language: auto, de, en
Language=auto
```

---

## 📋 Menu Structure

```text
┌────────────────────────────────────────────────────────┐
│ Current: 1440 × 900  [Pos: 120, 80]  (Copy)            │  <- Click to copy dimensions
├────────────────────────────────────────────────────────┤
│ 💾 Save current position & size...                     │  <- 1-click preset save
├────────────────────────────────────────────────────────┤
│ ⭐ Work Layout (1440 × 900 @ 120, 80)                  │  <- Saved custom layouts
│ ⭐ Split Screen Left (960 × 1040 @ 0, 0)               │
├────────────────────────────────────────────────────────┤
│ 1920 x 1080 (Full HD, Centered)                        │  <- Standard presets
│ 1600 x 900 (HD+, Centered)                             │
│ 1280 x 720 (HD 720p, Centered)                         │
│ 1024 x 768 (XGA, Centered)                             │
│ 800 x 600 (SVGA, Centered)                             │
├────────────────────────────────────────────────────────┤
│ 📐 Custom window size...                               │  <- Custom size prompt
│ 📍 Position window                                  ▶ │  <- Center, Top-Left, etc.
│ 🗑️ Delete preset                                    ▶ │  <- 1-click preset removal
├────────────────────────────────────────────────────────┤
│ ⌨️ Shortcut & Settings (Ctrl + Win + Z)...             │  <- Interactive shortcut GUI
│ 🌐 Language / Sprache...                               │  <- Dedicated language dialog
│ ⚙️ Edit settings (INI)...                              │  <- Opens settings.ini
└────────────────────────────────────────────────────────┘
```

---

## ⚙️ Configuration (`settings.ini`)

```ini
[Settings]
; Hotkey (^ = Ctrl, # = Win, ! = Alt, + = Shift)
Hotkey=^#z

; Language: auto, de, en
Language=auto

; Middle-click title bar trigger (1 = On, 0 = Off)
MiddleClickTitleBar=1

; Ctrl + Right-Click trigger (1 = On, 0 = Off)
CtrlRightClick=1

; DWM invisible frame compensation (1 = On, 0 = Off)
CompensateBorders=1

[Presets]
; Format: Name|Width|Height|Mode|RelX|RelY
; Modes: fixed, center, topleft, topright, bottomleft, bottomright
Item1=1920 x 1080 (Full HD, Centered)|1920|1080|center|0|0
Item2=1600 x 900 (HD+, Centered)|1600|900|center|0|0
Item3=1280 x 720 (HD 720p, Centered)|1280|720|center|0|0
```

---

## 🛠️ Building from Source

### Prerequisites (Compilation only)
- Windows 10 or 11
- [AutoHotkey v2](https://www.autohotkey.com/) installed (includes `Ahk2Exe`)

### 1-Click Build
Run the included build script:
```cmd
build.bat
```

Or compile manually via PowerShell:
```powershell
& "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "RightPosition.ahk" /out "RightPosition.exe" /icon "app.ico" /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /silent
```

---

## 📁 Repository Structure

```text
├── RightPosition.exe   # Standalone compiled executable (ready-to-run)
├── RightPosition.ahk   # Complete AutoHotkey v2 source code
├── settings.ini        # Local configuration file for presets & triggers
├── app.ico             # Multi-resolution application & tray icon
├── build.bat           # 1-click build script
├── LICENSE             # MIT License
├── README.md           # English documentation (with comparison matrix)
└── README.de.md        # German documentation (with comparison matrix)
```

---

## 📄 License

This project is open-source software licensed under the [MIT License](LICENSE).  
Free for personal and commercial use without restrictions.
