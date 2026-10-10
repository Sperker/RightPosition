# SizerAlternative

[![Plattform: Windows](https://img.shields.io/badge/Plattform-Windows%2010%20%7C%2011-blue.svg)](https://microsoft.com/windows)
[![Lizenz: MIT](https://img.shields.io/badge/Lizenz-MIT-green.svg)](LICENSE)
[![Abhängigkeiten: Keine](https://img.shields.io/badge/Abh%C3%A4ngigkeiten-Null%20%28Standalone%29-brightgreen.svg)]()
[![Sprache: AHK v2](https://img.shields.io/badge/Sprache-AutoHotkey%20v2-orange.svg)](https://www.autohotkey.com/)

> **Ein schlankes, portables und zukunftssicheres Werkzeug zum Skalieren und Positionieren von Fenstern unter Windows 10 & 11.**  
> Entwickelt als moderner 1:1-Ersatz für das beliebte Tool [Sizer 4.0](https://www.brianapps.net/sizer4/).

---

### 🌐 Sprache / Language
- **🇩🇪 Deutsche Dokumentation (Aktuell)**
- **[🇬🇧 English Documentation](README.md)**

---

## 🌟 Highlights & Funktionen

- **💾 1-Klick Preset-Speicherung**: Liest die aktuellen Fenstermaße (Breite × Höhe) und die exakte Position (X, Y) auf dem Monitor mit einem einzigen Klick aus und speichert sie als wiederverwendbares Preset.
- **⭐ Sofortige Wiederherstellung**: Gespeicherte Presets (`⭐`) erscheinen direkt im Menü; ein Klick stellt Größe **und** Position auf dem Bildschirm wieder her.
- **🖥️ Intelligente Multi-Monitor-Unterstützung**: Nutzt die Win32-APIs `MonitorFromWindow` und `GetMonitorInfoW`, um den Bildschirm des Zielfensters zu ermitteln. Fenster bleiben auf ihrem aktuellen Monitor verankert und springen nicht ungewollt auf Bildschirm 1.
- **🪟 Windows 10/11 DWM Rahmenkorrektur**: Moderne Windows-Fenster besitzen unsichtbare Schattenränder (~7–8 Pixel). Das Tool gleicht diese Offsets via `DwmGetWindowAttribute` automatisch aus, sodass die sichtbaren Kanten pixelgenau stimmen.
- **🖱️ Vielseitige Aufruf-Möglichkeiten**:
  - **Mittelklick auf die Titelleiste** (wie im klassischen Sizer, absturzsicher via `WM_NCHITTEST` ermittelt).
  - **<kbd>Strg</kbd> + Rechtsklick** auf ein beliebiges Fenster.
  - **<kbd>Strg</kbd> + <kbd>Win</kbd> + <kbd>Z</kbd>** (globaler Standard-Hotkey von Sizer, frei anpassbar).
- **📋 Live-Maße & Zwischenablage**: Die oberste Zeile des Menüs zeigt die aktuellen Abmessungen des Zielfensters an; ein Klick kopiert die Werte in die Zwischenablage.
- **📐 Freie Größenangabe**: Schnelle Eingabe beliebiger Auflösungen über einen übersichtlichen Dialog (z. B. `1280x720`).
- **⚙️ Portable Konfiguration**: Alle Einstellungen und Presets werden lokal in der [`settings.ini`](settings.ini) gespeichert – ohne Registry-Müll.
- **🚀 100% Standalone & Portabel**: Läuft als einzelne 1,2 MB große Datei (`SizerAlternative.exe`). **Keine Abhängigkeiten**, keine Installation und keine AutoHotkey-Laufzeitumgebung auf den Ziel-PCs erforderlich.

---

## 🚀 Schnellstart

### Programm verwenden
1. Kopieren Sie den Ordner auf den gewünschten PC oder einen USB-Stick.
2. Starten Sie **`SizerAlternative.exe`** per Doppelklick.
3. Das Programm erscheint im Infobereich der Taskleiste (System-Tray) mit dem Fensterskalierungs-Symbol.
4. Rufen Sie das Menü an einem beliebigen Zielfenster auf:
   - **Mittelklick** auf die Titelleiste des Fensters, **ODER**
   - Tastenkombination **<kbd>Strg</kbd> + <kbd>Win</kbd> + <kbd>Z</kbd>**, **ODER**
   - **<kbd>Strg</kbd> + Rechtsklick** auf das Fenster.
5. Wählen Sie **`💾 Aktuelle Position & Größe speichern...`**, vergeben Sie einen Namen und drücken Sie <kbd>Enter</kbd>.
6. Das Layout ist sofort dauerhaft gespeichert und steht künftig ganz oben im Menü zur Verfügung!

---

## 📋 Menü-Struktur

```text
┌────────────────────────────────────────────────────────┐
│ Aktuell: 1440 × 900  [Pos: 120, 80]  (Kopieren)        │  <- Klick kopiert Maße
├────────────────────────────────────────────────────────┤
│ 💾 Aktuelle Position & Größe speichern...              │  <- 1-Klick Preset speichern
├────────────────────────────────────────────────────────┤
│ ⭐ Mein Arbeits-Layout (1440 × 900 @ 120, 80)          │  <- Gespeicherte Presets
│ ⭐ Split Screen Links (960 × 1040 @ 0, 0)              │
├────────────────────────────────────────────────────────┤
│ 1920 x 1080 (Full HD, Zentriert)                       │  <- Standard-Presets
│ 1600 x 900 (HD+, Zentriert)                            │
│ 1280 x 720 (HD 720p, Zentriert)                        │
│ 1024 x 768 (XGA, Zentriert)                            │
│ 800 x 600 (SVGA, Zentriert)                            │
├────────────────────────────────────────────────────────┤
│ 📐 Benutzerdefinierte Größe...                         │  <- Eigene Maße eingeben
│ 📍 Positionieren                                    ▶ │  <- Zentrieren, Oben links etc.
│ 🗑️ Preset löschen                                   ▶ │  <- Presets per Klick entfernen
├────────────────────────────────────────────────────────┤
│ ⚙️ Einstellungen bearbeiten (INI)...                   │  <- Öffnet settings.ini
└────────────────────────────────────────────────────────┘
```

---

## ⚙️ Konfigurationsdatei (`settings.ini`)

Die Konfigurationsdatei [`settings.ini`](settings.ini) wird beim ersten Start automatisch im selben Verzeichnis angelegt:

```ini
[Settings]
; Globaler Hotkey (^ = Strg, # = Win, ! = Alt, + = Umschalt)
Hotkey=^#z

; Menü per Mittelklick auf Fenstertitelleiste aufrufen (1 = Ein, 0 = Aus)
MiddleClickTitleBar=1

; Menü per Strg + Rechtsklick auf ein Fenster aufrufen (1 = Ein, 0 = Aus)
CtrlRightClick=1

; Unsichtbare DWM-Schattenränder unter Windows 10/11 ausgleichen (1 = Ein, 0 = Aus)
CompensateBorders=1

[Presets]
; Format: Name|Breite|Höhe|Modus|RelX|RelY
; Modi: fixed, center, topleft, topright, bottomleft, bottomright
Item1=1920 x 1080 (Full HD, Zentriert)|1920|1080|center|0|0
Item2=1600 x 900 (HD+, Zentriert)|1600|900|center|0|0
Item3=1280 x 720 (HD 720p, Zentriert)|1280|720|center|0|0
```

---

## 🛠️ Aus Quelltext kompilieren

Das Projekt enthält sowohl die fertig kompilierte Binärdatei als auch den sauberen, offenen AutoHotkey v2 Quellcode.

### Voraussetzungen (nur zum Kompilieren nötig)
- Windows 10 oder 11
- Installiertes [AutoHotkey v2](https://www.autohotkey.com/) (enthält den Compiler `Ahk2Exe`)

### 1-Klick Build
Führen Sie einfach die beiliegende Stapelverarbeitungsdatei aus:
```cmd
build.bat
```

Oder alternativ über PowerShell:
```powershell
& "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "SizerAlternative.ahk" /out "SizerAlternative.exe" /icon "app.ico" /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /silent
```

---

## 📊 Vergleich mit Alternativen

| Funktion / Eigenschaft | SizerAlternative | Sizer 4.0 | SmartSystemMenu |
| :--- | :---: | :---: | :---: |
| **Position & Größe per Klick speichern** | ✔️ **Ja** | ✔️ Ja | ❌ Nein |
| **Unterstützung moderner Windows Apps** | ✔️ **Voll** (Chrome, Electron, VS Code) | ⚠️ Teilweise | ⚠️ Teilweise (DLL-Hook-Probleme) |
| **Administratorrechte nötig** | ❌ **Nein** | ❌ Nein | ⚠️ Meist ja |
| **DLL-Injection / Antivirus-Fehlalarme** | ❌ **Keine** | ❌ Keine | ⚠️ Nutzt Hook-DLLs |
| **Intelligente Multi-Monitor-Zuordnung** | ✔️ **Ja** | ✔️ Ja | ✔️ Ja |
| **DWM-Schattenrand-Kompensation** | ✔️ **Ja** | ⚠️ Eingeschränkt | ❌ Nein |
| **Portabilität** | ✔️ **1 Datei (1,2 MB)** | ✔️ Ja | ⚠️ Benötigt .NET Runtime |

---

## 📁 Ordnerstruktur des Repositories

```text
├── SizerAlternative.exe   # Fertig kompilierte Standalone-Anwendung (sofort startbar)
├── SizerAlternative.ahk   # Vollständiger AutoHotkey v2 Quellcode
├── settings.ini           # Lokale Konfigurationsdatei für Presets und Optionen
├── app.ico                # Anwendungs- & Tray-Icon (Multi-Resolution)
├── build.bat              # 1-Klick Build-Skript zur Neu-Kompilierung
├── LICENSE                # MIT Open-Source-Lizenz
├── README.md              # Englische Dokumentation
└── README.de.md           # Deutsche Dokumentation
```

---

## 📄 Lizenz

Dieses Projekt ist unter der freien [MIT-Lizenz](LICENSE) veröffentlicht.  
Darf ohne Einschränkungen sowohl privat als auch kommerziell genutzt und modifiziert werden.
