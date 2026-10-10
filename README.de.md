# RightPosition

[![Plattform: Windows](https://img.shields.io/badge/Plattform-Windows%2010%20%7C%2011-blue.svg)](https://microsoft.com/windows)
[![Lizenz: MIT](https://img.shields.io/badge/Lizenz-MIT-green.svg)](LICENSE)
[![Abhängigkeiten: Keine](https://img.shields.io/badge/Abh%C3%A4ngigkeiten-Null%20%28Standalone%29-brightgreen.svg)]()
[![Sicherheit: Keine DLL-Injection](https://img.shields.io/badge/Sicherheit-Keine%20DLL--Injection%20%7C%20User%20Space-success.svg)]()
[![Sprache: AHK v2](https://img.shields.io/badge/Sprache-AutoHotkey%20v2-orange.svg)](https://www.autohotkey.com/)

> **Ein schlankes, portables und Enterprise-taugliches Werkzeug zum Skalieren und Positionieren von Fenstern unter Windows 10 & 11.**  
> Entwickelt als moderne, voll auditierbare und zukunftssichere Open-Source-Alternative zu Legacy-Tools wie [Sizer 4.0](https://www.brianapps.net/sizer4/).

---

### 🌐 Sprache / Language
- **🇩🇪 Deutsche Dokumentation (Aktuell)**
- **[🇬🇧 English Documentation](README.md)**

---

## 🏢 Warum RightPosition? (Enterprise & Offener Software-Stack)

Viele Entwickler, Screencaster, QA-Tester und Power-User sind auf Werkzeuge wie Brian Apps' klassisches **Sizer** angewiesen, um Fenster auf exakte Pixel-Auflösungen (z. B. 1080p, 720p für Aufnahmen und UI-Tests) oder feste Arbeitskoordinaten zu setzen. In modernen Unternehmens- und IT-Umgebungen stoßen bestehende Lösungen jedoch an gravierende Grenzen:

1. **Risiko durch proprietäre Abandonware**: Das originale Sizer ist Closed-Source-Freeware eines einzelnen Entwicklers ohne regelmäßige Sicherheitsupdates. IT-Compliance-Abteilungen können den Binärcode nicht prüfen und verbieten den Einsatz auf gesicherten Firmen-Rechnern.
2. **Sicherheitskonflikte bei Hook-Tools**: Werkzeuge wie SmartSystemMenu verwenden globale DLL-Injection (`WH_CALLWNDPROC`-Hooks) und verlangen oft Administratorrechte. Moderne Endpoint Detection & Response (EDR)-Systeme (CrowdStrike, Microsoft Defender for Endpoint, SentinelOne) stufen dies als bösartige Prozess-Manipulation ein und blockieren die Software.
3. **Grenzen nativer Microsoft-Tools (PowerToys & Windows 11 Snap)**: Die Windows 11 Snap-Layouts und Microsoft PowerToys (FancyZones) können Fenster nur in feste Rasterkacheln (Hälften/Viertel) einteilen. Sie erlauben **keine frei schwebenden Fenster mit exakten Pixelmaßen** (wie 1440×900) und bieten **keine Funktion, um per Klick die Geometrie eines Fensters abzuspeichern**. FancyZones erfordert zudem eine über 200 MB große Hintergrund-Installation mit Telemetrie.

**RightPosition** schließt diese Lücke mit einem **100 % offenen, auditierbaren und minimalen Stack**:
- **0 KB externe Runtimes**: Läuft als einzelne portable 1,2 MB Standalone-Datei.
- **Keine Administratorrechte nötig**: Arbeitet vollständig im unprivilegierten Benutzerkontext.
- **Keine DLL-Injection**: Greift nicht in fremde Prozessspeicher ein – 100 % konform mit Enterprise-Sicherheitsrichtlinien.
- **Zukunftssicher**: Direkt auf nativer Win32 User32- und DWM-API aufgebaut, garantiert kompatibel mit künftigen Windows-Versionen.

---

## 📊 Umfassende Vergleichsmatrix

| Kriterium / Funktion | 🚀 RightPosition | 📦 Sizer 4.0 | 🔧 SmartSystemMenu | 🪟 MS PowerToys (FancyZones) | 🖥️ Windows 11 Snap Layouts |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Position & Größe per 1-Klick speichern** | ✔️ **Ja** | ✔️ Ja | ❌ Nein | ❌ Nein | ❌ Nein |
| **Pixelgenaue Zielmaße (z.B. 1920×1080)** | ✔️ **Ja** | ✔️ Ja | ✔️ Ja (Nur Größe) | ❌ Nein (Nur Raster) | ❌ Nein (Nur Raster) |
| **Frei schwebende Platzierung (X, Y)** | ✔️ **Ja** | ✔️ Ja | ❌ Nein (Starr) | ❌ Nein (Kachel) | ❌ Nein (Kachel) |
| **Auditierbarer Open-Source-Code** | ✔️ **100% (MIT)** | ❌ Closed Source | ✔️ Open Source | ✔️ Open Source | ❌ Closed Source |
| **Keine Admin-Rechte erforderlich** | ✔️ **Ja** | ✔️ Ja | ⚠️ Meist Admin | ⚠️ Installer / Rechte | ✔️ Nativ |
| **Keine DLL-Injection (EDR-freundlich)** | ✔️ **Sauber** | ✔️ Sauber | ⚠️ DLL-Injection | ✔️ Sauber | ✔️ Nativ |
| **Moderne Apps (Chrome, Electron, VS Code)** | ✔️ **Voll** | ⚠️ Teilweise | ⚠️ Fehleranfällig | ✔️ Voll | ✔️ Voll |
| **Multi-Monitor-Intelligenz (bleibt am Screen)** | ✔️ **Ja** | ✔️ Ja | ✔️ Ja | ✔️ Ja | ✔️ Ja |
| **DWM-Schattenrand-Ausgleich (Win 10/11)** | ✔️ **Ja** (Pixel-exakt) | ⚠️ Teilweise | ❌ Nein | ⚠️ Windows Standard | ⚠️ Windows Standard |
| **System-Overhead / Fußabdruck** | ✔️ **~1,2 MB Portabel** | ✔️ Klein | ⚠️ .NET Runtime | ⚠️ >200 MB Installation | ✔️ System-integriert |
| **Keine Installation / Kein Registry-Müll** | ✔️ **Ja (Lokale INI)** | ✔️ Ja | ✔️ Ja | ❌ Benötigt Setup | ✔️ Nativ |

---

## 🌟 Highlights & Funktionen

- **💾 1-Klick Fenstergeometrie speichern**: Liest Breite, Höhe und die relative Position (X, Y) auf dem Monitor mit einem Klick aus und legt ein benanntes Preset an.
- **⭐ Sofortige Wiederherstellung**: Gespeicherte Presets erscheinen ganz oben im Menü (`⭐`). Ein Klick stellt Größe **und** Position auf dem Bildschirm wieder her.
- **🖥️ Multi-Monitor-Unterstützung**: Erkennt über Win32 `MonitorFromWindow` automatisch den Monitor des Fensters. Fenster springen niemals ungewollt auf Bildschirm 1.
- **🪟 Windows 10/11 DWM Schattenrand-Ausgleich**: Gleicht die unsichtbaren DWM-Rahmen (~7–8 Pixel) über `DwmGetWindowAttribute` aus, sodass die sichtbaren Kanten exakt der Zielauflösung entsprechen.
- **🖱️ Vielseitige, unaufdringliche Trigger**:
  - **Mittelklick auf die Titelleiste** (bekannter Sizer-Workflow, absturzsicher via `WM_NCHITTEST`).
  - **<kbd>Strg</kbd> + Rechtsklick** auf ein beliebiges Fenster.
  - **<kbd>Strg</kbd> + <kbd>Win</kbd> + <kbd>Z</kbd>** (frei anpassbarer globaler Hotkey).
- **📋 Live-Maße & Zwischenablage**: Die oberste Menüzeile zeigt die aktuellen Abmessungen des Fensters an; ein Klick kopiert die Werte in die Zwischenablage.
- **📐 Freie Maße eingeben**: Schnelle Eingabe beliebiger Auflösungen (z. B. `1280x720`).
- **⚙️ Portable Konfiguration**: Alle Einstellungen liegen lokal in der lesbaren [`settings.ini`](settings.ini).

---

## 🚀 Schnellstart

### Programm verwenden
1. Kopieren Sie den Ordner auf den gewünschten PC oder USB-Stick.
2. Starten Sie **`RightPosition.exe`** per Doppelklick.
3. Das Programm erscheint im Infobereich der Taskleiste (System-Tray).
4. Rufen Sie das Menü an einem Zielfenster auf:
   - **Mittelklick** auf die Titelleiste, **ODER**
   - **<kbd>Strg</kbd> + <kbd>Win</kbd> + <kbd>Z</kbd>**, **ODER**
   - **<kbd>Strg</kbd> + Rechtsklick** auf das Fenster.
5. Klicken Sie auf **`💾 Aktuelle Position & Größe speichern...`**, vergeben Sie einen Namen und drücken Sie <kbd>Enter</kbd>.
6. Das Preset steht sofort dauerhaft zur Verfügung!

---

## 📋 Menü-Struktur

```text
┌────────────────────────────────────────────────────────┐
│ Aktuell: 1440 × 900  [Pos: 120, 80]  (Kopieren)        │  <- Klick kopiert Maße
├────────────────────────────────────────────────────────┤
│ 💾 Aktuelle Position & Größe speichern...              │  <- 1-Klick Preset anlegen
├────────────────────────────────────────────────────────┤
│ ⭐ Mein Arbeits-Layout (1440 × 900 @ 120, 80)          │  <- Eigene Presets
│ ⭐ Split Screen Links (960 × 1040 @ 0, 0)              │
├────────────────────────────────────────────────────────┤
│ 1920 x 1080 (Full HD, Zentriert)                       │  <- Standard-Presets
│ 1600 x 900 (HD+, Zentriert)                            │
│ 1280 x 720 (HD 720p, Zentriert)                        │
│ 1024 x 768 (XGA, Zentriert)                            │
│ 800 x 600 (SVGA, Zentriert)                            │
├────────────────────────────────────────────────────────┤
│ 📐 Benutzerdefinierte Größe...                         │  <- Freie Maße eingeben
│ 📍 Positionieren                                    ▶ │  <- Zentrieren, Oben links etc.
│ 🗑️ Preset löschen                                   ▶ │  <- Preset per Klick löschen
├────────────────────────────────────────────────────────┤
│ ⚙️ Einstellungen bearbeiten (INI)...                   │  <- Öffnet settings.ini
└────────────────────────────────────────────────────────┘
```

---

## ⚙️ Konfigurationsdatei (`settings.ini`)

```ini
[Settings]
; Hotkey (^ = Strg, # = Win, ! = Alt, + = Umschalt)
Hotkey=^#z

; Menü per Mittelklick auf Titelleiste öffnen (1 = Ein, 0 = Aus)
MiddleClickTitleBar=1

; Menü per Strg + Rechtsklick auf Fenster öffnen (1 = Ein, 0 = Aus)
CtrlRightClick=1

; Unsichtbare DWM-Rahmen unter Win 10/11 ausgleichen (1 = Ein, 0 = Aus)
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

### Voraussetzungen (nur zum Kompilieren)
- Windows 10 oder 11
- Installiertes [AutoHotkey v2](https://www.autohotkey.com/) (enthält `Ahk2Exe`)

### 1-Klick Build
Führen Sie einfach die Stapelverarbeitungsdatei aus:
```cmd
build.bat
```

Oder manuell via PowerShell:
```powershell
& "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in "RightPosition.ahk" /out "RightPosition.exe" /icon "app.ico" /base "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /silent
```

---

## 📁 Ordnerstruktur des Repositories

```text
├── RightPosition.exe   # Standalone-Anwendung (sofort startbar, 0 Abhängigkeiten)
├── RightPosition.ahk   # Vollständiger AutoHotkey v2 Quellcode
├── settings.ini        # Lokale Konfigurationsdatei für Presets und Optionen
├── app.ico             # Anwendungs- & Tray-Icon (Multi-Resolution)
├── build.bat           # 1-Klick Build-Skript zur Neu-Kompilierung
├── LICENSE             # MIT Open-Source-Lizenz
├── README.md           # Englische Dokumentation mit Vergleichsmatrix
└── README.de.md        # Deutsche Dokumentation mit Vergleichsmatrix
```

---

## 📄 Lizenz

Dieses Projekt ist unter der freien [MIT-Lizenz](LICENSE) lizenziert.  
Darf ohne Einschränkungen sowohl privat als auch kommerziell in Organisationen eingesetzt und modifiziert werden.
