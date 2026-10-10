# SizerAlternative

[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-blue.svg)](https://microsoft.com/windows)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Dependencies: None](https://img.shields.io/badge/Dependencies-Zero%20%28Standalone%29-brightgreen.svg)]()
[![Language: AHK v2](https://img.shields.io/badge/Language-AutoHotkey%20v2-orange.svg)](https://www.autohotkey.com/)

> **A modern, lightweight, and future-proof window resizing & positioning utility for Windows 10 & 11.**  
> Built as a portable 1:1 replacement for the classic [Sizer 4.0](https://www.brianapps.net/sizer4/).

---

### 🌐 Language / Sprache
- **[🇩🇪 Deutsche Dokumentation (German Documentation)](README.de.md)**
- **🇬🇧 English Documentation (Current)**

---

## 🌟 Highlights & Features

- **💾 1-Click Size & Position Presets**: Capture any window's exact dimensions (Width × Height) and position (X, Y) with one click and save it as a reusable preset.
- **⭐ Instant Layout Restoration**: Click any saved preset (`⭐`) to immediately restore the window's size and coordinates.
- **🖥️ Smart Multi-Monitor Support**: Uses Win32 `MonitorFromWindow` and `GetMonitorInfoW` to detect which display the window resides on. Windows stay anchored to their active monitor and won't jump to the primary screen.
- **🪟 Windows 10/11 DWM Border Compensation**: Modern Windows windows have invisible drop-shadow borders (~7–8 px). SizerAlternative calculates these offsets via `DwmGetWindowAttribute` to guarantee pixel-exact visible dimensions.
- **🖱️ Flexible Triggers**:
  - **Middle-Click on Title Bar** (like classic Sizer, detected crash-safely via `WM_NCHITTEST`).
  - **<kbd>Ctrl</kbd> + Right-Click** on any window.
  - **<kbd>Ctrl</kbd> + <kbd>Win</kbd> + <kbd>Z</kbd>** (global hotkey, customizable).
- **📋 Live Size Display & Clipboard Copy**: The top line of the menu displays the current window's dimensions; clicking it copies the values to your clipboard.
- **📐 Custom Dimensions Dialog**: Quickly resize to arbitrary dimensions (e.g., `1280x720`).
- **⚙️ Portable Configuration**: All settings and presets are stored in a clean local [`settings.ini`](settings.ini).
- **🚀 100% Standalone & Portable**: Runs as a single 1.2 MB executable (`SizerAlternative.exe`). **Zero dependencies**, no installation, and no AutoHotkey runtime required on target machines.

---

## 🚀 Quick Start

### Running the Application
1. Download or copy the project files to any folder or USB flash drive.
2. Launch **`SizerAlternative.exe`**.
3. It will appear in your system tray with the custom window-sizer icon.
4. Open the menu on any target window:
   - **Middle-click** the window's title bar, **OR**
   - Press **<kbd>Ctrl</kbd> + <kbd>Win</kbd> + <kbd>Z</kbd>**, **OR**
   - Press **<kbd>Ctrl</kbd> + Right-Click** anywhere on the window.
5. Select **`💾 Save Current Position & Size...`**, enter a name, and press <kbd>Enter</kbd>.
6. The preset is now permanently available at the top of the menu!

---

## 📋 Menu Structure

```text
┌────────────────────────────────────────────────────────┐
│ Aktuell: 1440 × 900  [Pos: 120, 80]  (Kopieren)        │  <- Click to copy dimensions
├────────────────────────────────────────────────────────┤
│ 💾 Aktuelle Position & Größe speichern...              │  <- Save 1-click preset
├────────────────────────────────────────────────────────┤
│ ⭐ Mein Arbeits-Layout (1440 × 900 @ 120, 80)          │  <- Custom saved presets
│ ⭐ Split Screen Links (960 × 1040 @ 0, 0)              │
├────────────────────────────────────────────────────────┤
│ 1920 x 1080 (Full HD, Zentriert)                       │  <- Standard presets
│ 1600 x 900 (HD+, Zentriert)                            │
│ 1280 x 720 (HD 720p, Zentriert)                        │
│ 1024 x 768 (XGA, Zentriert)                            │
│ 800 x 600 (SVGA, Zentriert)                            │
├────────────────────────────────────────────────────────┤
│ 📐 Benutzerdefinierte Größe...                         │  <- Custom size prompt
│ 📍 Positionieren                                    ▶ │  <- Center, Top-Left, etc.
│ 🗑️ Preset löschen                                   ▶ │  <- 1-click preset removal
├────────────────────────────────────────────────────────┤
│ ⚙️ Einstellungen bearbeiten (INI)...                   │  <- Opens settings.ini
└────────────────────────────────────────────────────────┘
```

---

## ⚙️ Configuration (`settings.ini`)

The [`settings.ini`](settings.ini) file is automatically created on first launch if not present:

```ini
[Settings]
; Global hotkey (^ = Ctrl, # = Win, ! = Alt, + = Shift)
Hotkey=^#z

; Open menu via middle-click on window title bar (1 = On, 0 = Off)
MiddleClickTitleBar=1

; Open menu via Ctrl + Right-Click on window (1 = On, 0 = Off)
CtrlRightClick=1

; Compensate invisible DWM shadow borders on Windows 10/11 (1 = On, 0 = Off)
CompensateBorders=1

[Presets]
; Format: Name|Width|Height|Mode|RelX|RelY
; Modes: fixed, center, topleft, topright, bottomleft, bottomright
Item1=1920 x 1080 (Full HD, Zentriert)|1920|1080|center|0|0
Item2=1600 x 900 (HD+, Zentriert)|1600|900|center|0|0
Item3=1280 x 720 (HD 720p, Zentriert)|1280|720|center|0|0
```

---

## 🛠️ Building from Source

The repository includes both the compiled binary and the full, clean AutoHotkey v2 source code.

### Prerequisites (Only needed for compiling)
- Windows 10 or 11
- [AutoHotkey v2](https://www.autohotkey.com/) installed (includes `Ahk2Exe`)

### 1-Click Build
Simply run the included build script:
```cmd
build.bat
```

Or run via PowerShell:
```powershell
& "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "SizerAlternative.ahk" /out "SizerAlternative.exe" /icon "app.ico" /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /silent
```

---

## 📊 Comparison with Alternatives

| Feature | SizerAlternative | Sizer 4.0 | SmartSystemMenu |
| :--- | :---: | :---: | :---: |
| **Save current position & size per click** | ✔️ **Yes** | ✔️ Yes | ❌ No |
| **Windows 10 / 11 modern app support** | ✔️ **Full** (Chrome, Electron, VS Code) | ⚠️ Partial | ⚠️ Partial (DLL hook issues) |
| **Admin rights required** | ❌ **No** | ❌ No | ⚠️ Yes |
| **DLL Injection / AV False-Positives** | ❌ **None** | ❌ None | ⚠️ Uses Hook DLLs |
| **Multi-Monitor intelligent placement** | ✔️ **Yes** | ✔️ Yes | ✔️ Yes |
| **Invisible DWM border compensation** | ✔️ **Yes** | ⚠️ Partial | ❌ No |
| **Portability** | ✔️ **1 File (1.2 MB)** | ✔️ Yes | ⚠️ Requires .NET Runtime |

---

## 📁 Repository Structure

```text
├── SizerAlternative.exe   # Standalone compiled executable (ready-to-run)
├── SizerAlternative.ahk   # Complete AutoHotkey v2 source code
├── settings.ini           # Configuration file for presets and triggers
├── app.ico                # Multi-resolution application & tray icon
├── build.bat              # 1-click build script
├── LICENSE                # MIT License
├── README.md              # English documentation
└── README.de.md           # German documentation
```

---

## 📄 License

This project is open-source software licensed under the [MIT License](LICENSE).  
Free for personal and commercial use.
