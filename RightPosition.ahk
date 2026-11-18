#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()

; ==============================================================================
; RightPosition - Open-Source Fenster-Skalierung & Platzierung für Windows
; (Zukunftssicherer, auditierbarer Sizer 4.0 Ersatz in AutoHotkey v2)
; ==============================================================================
; Features:
; - Aktuelle Fensterposition & Größe per Klick als Preset abspeichern
; - Gespeicherte Presets per Klick wieder anwenden (Größe + Position)
; - Konfigurierbare Hotkeys & Shortcuts (über moderne Einstellungen-GUI oder INI)
; - Aufruf per:
;     * Frei wählbarer Hotkey: Standardmäßig Strg + Win + Z
;     * Mittelklick auf die Titelleiste des Fensters
;     * Strg + Rechtsklick auf beliebiges Fenster
; - Multi-Monitor-Unterstützung (bleibt auf dem aktuellen Monitor)
; - Windows 10/11 DWM Rahmenkorrektur (pixelgenaue Maße)
; - Presets verwalten & löschen direkt im Menü
;@Ahk2Exe-SetMainIcon app.ico

global IniFile := A_ScriptDir "\settings.ini"
global IconFile := A_ScriptDir "\app.ico"
global Presets := []
global HotkeyStr := "^#z"
global MiddleClickTitleBar := true
global CtrlRightClick := true
global CompensateBorders := true
global SettingsGui := ""

InitConfig()
SetupTrayMenu()
RegisterHotkeys()

; ------------------------------------------------------------------------------
; Hotkeys registrieren & verwalten
; ------------------------------------------------------------------------------
RegisterHotkeys() {
    global HotkeyStr
    if (HotkeyStr != "") {
        try {
            Hotkey(HotkeyStr, (*) => ShowRightPositionMenu(), "On")
        } catch as err {
            MsgBox("Fehler beim Registrieren des Hotkeys '" FormatHotkeyFriendly(HotkeyStr) "' (" HotkeyStr "):`n" err.Message, "RightPosition", "Icon!")
        }
    }
}

UpdateHotkey(newHk) {
    global HotkeyStr, IniFile
    if (newHk = HotkeyStr)
        return true

    ; Erst versuchen, den neuen Hotkey zu aktivieren
    try {
        Hotkey(newHk, (*) => ShowRightPositionMenu(), "On")
    } catch as err {
        MsgBox("Der Shortcut '" FormatHotkeyFriendly(newHk) "' konnte nicht aktiviert werden:`n`n" err.Message "`n`nMöglicherweise ist dieser Shortcut bereits vom System oder einem anderen Programm belegt.", "RightPosition", "Icon!")
        return false
    }

    ; Bisherigen Hotkey deaktivieren
    if (HotkeyStr != "") {
        try Hotkey(HotkeyStr, "Off")
    }

    HotkeyStr := newHk
    try IniWrite(HotkeyStr, IniFile, "Settings", "Hotkey")
    SetupTrayMenu()
    return true
}

; ------------------------------------------------------------------------------
; Formatierung & Parser für lesbare Hotkeys
; ------------------------------------------------------------------------------
FormatHotkeyFriendly(hk) {
    if (hk = "")
        return "Keiner"
    str := ""
    if InStr(hk, "^")
        str .= "Strg + "
    if InStr(hk, "#")
        str .= "Win + "
    if InStr(hk, "!")
        str .= "Alt + "
    if InStr(hk, "+")
        str .= "Shift + "
    
    keyPart := RegExReplace(hk, "[\^#!+]")
    switch StrLower(keyPart) {
        case "space": keyPart := "Leertaste"
        case "enter": keyPart := "Eingabetaste"
        case "tab": keyPart := "Tab"
        case "esc": keyPart := "Escape"
        case "delete", "del": keyPart := "Entf"
        case "insert", "ins": keyPart := "Einfg"
        case "home": keyPart := "Pos1"
        case "end": keyPart := "Ende"
        case "pgup": keyPart := "BildAuf"
        case "pgdn": keyPart := "BildAb"
        case "up": keyPart := "Pfeil Oben"
        case "down": keyPart := "Pfeil Unten"
        case "left": keyPart := "Pfeil Links"
        case "right": keyPart := "Pfeil Rechts"
        default: keyPart := StrUpper(keyPart)
    }
    return str keyPart
}

ParseHotkeyToParts(hk, &hasCtrl, &hasWin, &hasAlt, &hasShift, &keyName) {
    hasCtrl := InStr(hk, "^") ? 1 : 0
    hasWin := InStr(hk, "#") ? 1 : 0
    hasAlt := InStr(hk, "!") ? 1 : 0
    hasShift := InStr(hk, "+") ? 1 : 0
    keyName := RegExReplace(hk, "[\^#!+]")
    if (keyName = "")
        keyName := "Z"
    else
        keyName := StrUpper(keyName)
}

; ------------------------------------------------------------------------------
; Maus-Trigger: Mittelklick auf Titelleiste oder Strg + Rechtsklick
; ------------------------------------------------------------------------------
#HotIf MiddleClickTitleBar && MouseIsOverTitleBar()
MButton:: {
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mX, &mY, &mHwnd)
    if mHwnd {
        try WinActivate(mHwnd)
        Sleep(40)
        ShowRightPositionMenu(mHwnd)
    }
}
#HotIf

#HotIf CtrlRightClick
^RButton:: {
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mX, &mY, &mHwnd)
    if (mHwnd && mHwnd != WinExist("ahk_class Shell_TrayWnd")) {
        try WinActivate(mHwnd)
        Sleep(40)
        ShowRightPositionMenu(mHwnd)
    }
}
#HotIf

MouseIsOverTitleBar() {
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mX, &mY, &mHwnd)
    if (!mHwnd || mHwnd = WinExist("ahk_class Shell_TrayWnd"))
        return false

    lParam := (mX & 0xFFFF) | ((mY & 0xFFFF) << 16)
    res := Buffer(A_PtrSize, 0)
    ; SMTO_ABORTIFHUNG = 2, 120ms Timeout
    if DllCall("User32\SendMessageTimeoutW", "Ptr", mHwnd, "UInt", 0x84, "Ptr", 0, "Ptr", lParam, "UInt", 2, "UInt", 120, "Ptr", res) {
        hit := NumGet(res, 0, "Int")
        return (hit == 2) ; 2 = HTCAPTION (Titelleiste)
    }
    return false
}

; ------------------------------------------------------------------------------
; Konfiguration laden & verwalten
; ------------------------------------------------------------------------------
InitConfig() {
    global Presets, HotkeyStr, MiddleClickTitleBar, CtrlRightClick, CompensateBorders

    if !FileExist(IniFile) {
        CreateDefaultIni()
    }

    try HotkeyStr := IniRead(IniFile, "Settings", "Hotkey", "^#z")
    try MiddleClickTitleBar := (IniRead(IniFile, "Settings", "MiddleClickTitleBar", "1") = "1")
    try CtrlRightClick := (IniRead(IniFile, "Settings", "CtrlRightClick", "1") = "1")
    try CompensateBorders := (IniRead(IniFile, "Settings", "CompensateBorders", "1") = "1")

    Presets := []
    try {
        presetsSection := IniRead(IniFile, "Presets")
        loop parse, presetsSection, "`n", "`r" {
            line := Trim(A_LoopField)
            if (line = "" || SubStr(line, 1, 1) = ";")
                continue
            eqPos := InStr(line, "=")
            if (eqPos > 0) {
                val := SubStr(line, eqPos + 1)
                parts := StrSplit(val, "|")
                if (parts.Length >= 3) {
                    name := Trim(parts[1])
                    w := Integer(Trim(parts[2]))
                    h := Integer(Trim(parts[3]))
                    pos := (parts.Length >= 4) ? StrLower(Trim(parts[4])) : "center"
                    rx := (parts.Length >= 5) ? Integer(Trim(parts[5])) : 0
                    ry := (parts.Length >= 6) ? Integer(Trim(parts[6])) : 0
                    isFixed := (pos == "fixed")
                    Presets.Push({ title: name, width: w, height: h, position: pos, relX: rx, relY: ry, isFixed: isFixed })
                }
            }
        }
    } catch {
        CreateDefaultIni()
    }
}

CreateDefaultIni() {
    defaultIni := 
    (
        "[Settings]`r`n"
        "; Tastenkombination zum Öffnen des Menüs (^ = Strg, # = Win, ! = Alt, + = Umschalt)`r`n"
        "Hotkey=^#z`r`n"
        "`r`n"
        "; Menü per Mittelklick auf die Fenstertitelleiste öffnen (1 = Ein, 0 = Aus)`r`n"
        "MiddleClickTitleBar=1`r`n"
        "`r`n"
        "; Menü per Strg + Rechtsklick auf ein beliebiges Fenster öffnen (1 = Ein, 0 = Aus)`r`n"
        "CtrlRightClick=1`r`n"
        "`r`n"
        "; Unsichtbare Fensterrahmen von Windows 10/11 ausgleichen (1 = Ja, 0 = Nein)`r`n"
        "CompensateBorders=1`r`n"
        "`r`n"
        "[Presets]`r`n"
        "; Format: Name|Breite|Höhe|Modus|RelX|RelY`r`n"
        "Item1=1920 x 1080 (Full HD, Zentriert)|1920|1080|center|0|0`r`n"
        "Item2=1600 x 900 (HD+, Zentriert)|1600|900|center|0|0`r`n"
        "Item3=1280 x 720 (HD 720p, Zentriert)|1280|720|center|0|0`r`n"
        "Item4=1024 x 768 (XGA, Zentriert)|1024|768|center|0|0`r`n"
        "Item5=800 x 600 (SVGA, Zentriert)|800|600|center|0|0`r`n"
    )
    try FileAppend(defaultIni, IniFile, "UTF-8")
}

WritePresetsToIni() {
    global Presets, IniFile
    try IniDelete(IniFile, "Presets")
    for idx, p in Presets {
        val := p.title "|" p.width "|" p.height "|" p.position "|" p.relX "|" p.relY
        IniWrite(val, IniFile, "Presets", "Item" idx)
    }
}

; ------------------------------------------------------------------------------
; RightPosition Hauptmenü
; ------------------------------------------------------------------------------
ShowRightPositionMenu(targetHwnd := 0) {
    hwnd := targetHwnd ? targetHwnd : WinExist("A")
    if (!hwnd || hwnd = WinExist("ahk_class Shell_TrayWnd") || hwnd = WinExist("ahk_class WorkerW")) {
        return
    }

    GetVisibleWindowRect(hwnd, &vx, &vy, &vw, &vh)
    GetMonitorWorkArea(hwnd, &mLeft, &mTop, &mRight, &mBottom)
    relX := vx - mLeft
    relY := vy - mTop

    m := Menu()

    ; Infozeile mit aktueller Größe und Position
    curInfo := "Aktuell: " vw " × " vh "  [Pos: " relX ", " relY "]  (Kopieren)"
    m.Add(curInfo, (*) => (A_Clipboard := vw " x " vh " @ " relX ", " relY, ShowToast("Maße in die Zwischenablage kopiert!")))
    m.Add() ; Trennlinie

    ; KILLER-FEATURE: Aktuelle Größe & Position als Preset speichern
    m.Add("💾 Aktuelle Position & Größe speichern...", (*) => SaveCurrentAsPreset(hwnd))
    m.Add() ; Trennlinie

    ; Gespeicherte / Benutzerdefinierte Presets (mit fester Position)
    hasCustom := false
    for pItem in Presets {
        if (pItem.isFixed) {
            hasCustom := true
            iconPrefix := "⭐ "
            m.Add(iconPrefix pItem.title, ((p, *) => ApplyPreset(hwnd, p)).Bind(pItem))
        }
    }

    if (hasCustom)
        m.Add() ; Trennlinie

    ; Standard-Auflösungen (Zentriert / Relativ)
    for pItem in Presets {
        if (!pItem.isFixed) {
            m.Add(pItem.title, ((p, *) => ApplyPreset(hwnd, p)).Bind(pItem))
        }
    }

    m.Add() ; Trennlinie
    m.Add("📐 Benutzerdefinierte Größe...", (*) => PromptCustomSize(hwnd))

    ; Submenü für Positionierung
    posMenu := Menu()
    posMenu.Add("Fenster zentrieren", (*) => PositionTarget(hwnd, "center"))
    posMenu.Add("Oben links", (*) => PositionTarget(hwnd, "topleft"))
    posMenu.Add("Oben rechts", (*) => PositionTarget(hwnd, "topright"))
    posMenu.Add("Unten links", (*) => PositionTarget(hwnd, "bottomleft"))
    posMenu.Add("Unten rechts", (*) => PositionTarget(hwnd, "bottomright"))
    m.Add("📍 Positionieren", posMenu)

    ; Submenü zum Löschen von Presets
    if (Presets.Length > 0) {
        delMenu := Menu()
        for idx, pItem in Presets {
            delMenu.Add(pItem.title, ((delIdx, *) => DeletePresetByIndex(delIdx)).Bind(idx))
        }
        m.Add("🗑️ Preset löschen", delMenu)
    }

    friendlyHk := FormatHotkeyFriendly(HotkeyStr)
    m.Add() ; Trennlinie
    m.Add("⌨️ Shortcut & Einstellungen (" friendlyHk ")...", (*) => ShowSettingsGui())
    m.Add("⚙️ Einstellungen bearbeiten (INI)...", (*) => EditSettings())

    ; Menü an der aktuellen Mausposition öffnen
    m.Show()
}

; ------------------------------------------------------------------------------
; Preset speichern
; ------------------------------------------------------------------------------
SaveCurrentAsPreset(hwnd) {
    if !WinExist(hwnd)
        return

    GetVisibleWindowRect(hwnd, &vx, &vy, &vw, &vh)
    GetMonitorWorkArea(hwnd, &mLeft, &mTop, &mRight, &mBottom)
    relX := vx - mLeft
    relY := vy - mTop

    winTitle := WinGetTitle(hwnd)
    shortTitle := (winTitle != "") ? (SubStr(winTitle, 1, 22) " - ") : ""
    defaultName := shortTitle vw "x" vh " (Pos: " relX ", " relY ")"

    promptText := 
    (
        "Geben Sie einen Namen für das neue Preset ein:`n`n"
        "• Breite: " vw " px`n"
        "• Höhe: " vh " px`n"
        "• Position X: " relX " px (relativ zum Monitor)`n"
        "• Position Y: " relY " px (relativ zum Monitor)"
    )

    ib := InputBox(promptText, "Aktuelle Position & Größe speichern", "W380 H230", defaultName)
    if (ib.Result != "OK" || Trim(ib.Value) == "")
        return

    newName := Trim(ib.Value)

    ; Am Anfang einfügen, damit das neue Preset sofort oben steht
    newEntry := { title: newName, width: vw, height: vh, position: "fixed", relX: relX, relY: relY, isFixed: true }
    Presets.InsertAt(1, newEntry)
    WritePresetsToIni()

    ShowToast("Preset '" newName "' gespeichert!")
}

DeletePresetByIndex(index) {
    if (index < 1 || index > Presets.Length)
        return

    targetItem := Presets[index]
    ans := MsgBox("Möchten Sie das Preset '" targetItem.title "' wirklich löschen?", "Preset löschen", "YesNo Icon?")
    if (ans == "Yes") {
        Presets.RemoveAt(index)
        WritePresetsToIni()
        ShowToast("Preset gelöscht!")
    }
}

; ------------------------------------------------------------------------------
; Preset anwenden
; ------------------------------------------------------------------------------
ApplyPreset(hwnd, preset) {
    ResizeTarget(hwnd, preset.width, preset.height, preset.position, preset.relX, preset.relY)
}

ResizeTarget(hwnd, targetW, targetH, posMode := "center", relX := 0, relY := 0) {
    if !WinExist(hwnd)
        return

    ; Wenn maximiert, wiederherstellen
    if (WinGetMinMax(hwnd) == 1)
        WinRestore(hwnd)

    GetMonitorWorkArea(hwnd, &mLeft, &mTop, &mRight, &mBottom)
    GetWindowBorderOffsets(hwnd, &offL, &offT, &offR, &offB)

    effW := CompensateBorders ? (targetW + offL + offR) : targetW
    effH := CompensateBorders ? (targetH + offT + offB) : targetH

    GetVisibleWindowRect(hwnd, &curVX, &curVY, &curVW, &curVH)

    targetVX := curVX
    targetVY := curVY

    switch posMode {
        case "fixed":
            targetVX := mLeft + relX
            targetVY := mTop + relY
        case "center":
            targetVX := mLeft + ((mRight - mLeft) - targetW) // 2
            targetVY := mTop + ((mBottom - mTop) - targetH) // 2
        case "topleft":
            targetVX := mLeft
            targetVY := mTop
        case "topright":
            targetVX := mRight - targetW
            targetVY := mTop
        case "bottomleft":
            targetVX := mLeft
            targetVY := mBottom - targetH
        case "bottomright":
            targetVX := mRight - targetW
            targetVY := mBottom - targetH
        default: ; "keep"
            if (targetVX + targetW > mRight)
                targetVX := mRight - targetW
            if (targetVY + targetH > mBottom)
                targetVY := mBottom - targetH
            if (targetVX < mLeft)
                targetVX := mLeft
            if (targetVY < mTop)
                targetVY := mTop
    }

    finalX := CompensateBorders ? (targetVX - offL) : targetVX
    finalY := CompensateBorders ? (targetVY - offT) : targetVY

    WinMove(finalX, finalY, effW, effH, hwnd)
}

PositionTarget(hwnd, posMode) {
    if !WinExist(hwnd)
        return

    if (WinGetMinMax(hwnd) == 1)
        WinRestore(hwnd)

    GetVisibleWindowRect(hwnd, &vx, &vy, &vw, &vh)
    ResizeTarget(hwnd, vw, vh, posMode)
}

PromptCustomSize(hwnd) {
    GetVisibleWindowRect(hwnd, &vx, &vy, &curW, &curH)

    ib := InputBox("Breite und Höhe eingeben (z. B. 1280x720 oder 1280 720):", "Benutzerdefinierte Größe", "W320 H130", curW " x " curH)
    if (ib.Result != "OK")
        return

    text := RegExReplace(ib.Value, "[^\d]+", " ")
    parts := StrSplit(Trim(text), " ")

    if (parts.Length >= 2) {
        newW := Integer(parts[1])
        newH := Integer(parts[2])
        if (newW > 50 && newH > 50) {
            ResizeTarget(hwnd, newW, newH, "center")
        }
    } else {
        MsgBox("Ungültiges Format. Bitte z. B. '1280 x 720' eingeben.", "RightPosition", "Icon!")
    }
}

; ------------------------------------------------------------------------------
; Win32 & DWM Hilfsfunktionen
; ------------------------------------------------------------------------------
GetMonitorWorkArea(hwnd, &mLeft, &mTop, &mRight, &mBottom) {
    ; MONITOR_DEFAULTTONEAREST = 2
    hMon := DllCall("User32\MonitorFromWindow", "Ptr", hwnd, "UInt", 2, "Ptr")
    mi := Buffer(40, 0)
    NumPut("UInt", 40, mi, 0)

    if DllCall("User32\GetMonitorInfoW", "Ptr", hMon, "Ptr", mi) {
        mLeft := NumGet(mi, 20, "Int")
        mTop := NumGet(mi, 24, "Int")
        mRight := NumGet(mi, 28, "Int")
        mBottom := NumGet(mi, 32, "Int")
        return true
    }

    MonitorGetWorkArea(1, &mLeft, &mTop, &mRight, &mBottom)
    return false
}

GetVisibleWindowRect(hwnd, &vx, &vy, &vw, &vh) {
    ; DWMWA_EXTENDED_FRAME_BOUNDS = 9
    rect := Buffer(16, 0)
    hr := DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 9, "Ptr", rect, "UInt", 16)
    if (hr == 0) {
        vx := NumGet(rect, 0, "Int")
        vy := NumGet(rect, 4, "Int")
        vr := NumGet(rect, 8, "Int")
        vb := NumGet(rect, 12, "Int")
        vw := vr - vx
        vh := vb - vy
        return
    }
    WinGetPos(&vx, &vy, &vw, &vh, hwnd)
}

GetWindowBorderOffsets(hwnd, &offL, &offT, &offR, &offB) {
    rect := Buffer(16, 0)
    hr := DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 9, "Ptr", rect, "UInt", 16)
    if (hr == 0) {
        fLeft := NumGet(rect, 0, "Int")
        fTop := NumGet(rect, 4, "Int")
        fRight := NumGet(rect, 8, "Int")
        fBottom := NumGet(rect, 12, "Int")

        WinGetPos(&wx, &wy, &ww, &wh, hwnd)
        offL := fLeft - wx
        offT := fTop - wy
        offR := (wx + ww) - fRight
        offB := (wy + wh) - fBottom
        return
    }
    offL := offT := offR := offB := 0
}

ShowToast(msg) {
    ToolTip(msg)
    SetTimer(() => ToolTip(), -2500)
}

; ------------------------------------------------------------------------------
; Einstellungen & Shortcut Dialog (GUI)
; ------------------------------------------------------------------------------
ShowSettingsGui(*) {
    global SettingsGui, HotkeyStr, MiddleClickTitleBar, CtrlRightClick, CompensateBorders, IniFile, IconFile

    ; Falls bereits geöffnet, in den Vordergrund bringen
    if (SettingsGui is Gui && WinExist("ahk_id " SettingsGui.Hwnd)) {
        SettingsGui.Show()
        WinActivate("ahk_id " SettingsGui.Hwnd)
        return
    }

    SettingsGui := Gui("+AlwaysOnTop -MinimizeBox", "RightPosition - Shortcut & Einstellungen")
    SettingsGui.SetFont("s9", "Segoe UI")

    ; Fenster-Icon setzen falls app.ico vorhanden
    if FileExist(IconFile) {
        try {
            hIcon := DllCall("LoadImage", "Ptr", 0, "Str", IconFile, "UInt", 1, "Int", 32, "Int", 32, "UInt", 0x10, "Ptr")
            if hIcon
                DllCall("SendMessage", "Ptr", SettingsGui.Hwnd, "UInt", 0x80, "Ptr", 1, "Ptr", hIcon)
        }
    }

    ParseHotkeyToParts(HotkeyStr, &curCtrl, &curWin, &curAlt, &curShift, &curKey)

    ; --------------------------------------------------------------------------
    ; Bereich 1: Tastatur-Shortcut
    ; --------------------------------------------------------------------------
    SettingsGui.Add("GroupBox", "x15 y10 w480 h175", "Tastatur-Shortcut (Menü aufrufen)")

    SettingsGui.Add("Text", "x30 yp+25", "Schnellauswahl beliebter Tastenkombinationen:")
    presetChoices := [
        "Strg + Win + Z (Standard / Sizer)",
        "Strg + Alt + Z",
        "Win + Z",
        "Strg + Alt + S",
        "Strg + Shift + Z",
        "Alt + Leertaste",
        "Strg + F12",
        "Benutzerdefiniert..."
    ]
    cbPreset := SettingsGui.Add("DropDownList", "x30 y+5 w280", presetChoices)

    SettingsGui.Add("Text", "x30 y+12", "Zusatztasten (Modifikatoren):")
    chkCtrl := SettingsGui.Add("Checkbox", "x30 y+5 Checked" curCtrl, "Strg (Ctrl)")
    chkWin := SettingsGui.Add("Checkbox", "x+15 yp Checked" curWin, "Windows (Win)")
    chkAlt := SettingsGui.Add("Checkbox", "x+15 yp Checked" curAlt, "Alt")
    chkShift := SettingsGui.Add("Checkbox", "x+15 yp Checked" curShift, "Umschalt (Shift)")

    SettingsGui.Add("Text", "x30 y+12", "Taste:")
    keyList := [
        "A","B","C","D","E","F","G","H","I","J","K","L","M",
        "N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
        "0","1","2","3","4","5","6","7","8","9",
        "F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12",
        "Space","Tab","Enter","Esc","Delete","Insert","Home","End","PgUp","PgDn",
        "Up","Down","Left","Right"
    ]
    cbKey := SettingsGui.Add("ComboBox", "x75 yp-3 w110", keyList)
    cbKey.Text := curKey

    txtPreview := SettingsGui.Add("Text", "x200 yp+3 w280 cBlue", "Aktiv: " FormatHotkeyFriendly(HotkeyStr))
    txtPreview.SetFont("s9 Bold")

    ; --------------------------------------------------------------------------
    ; Bereich 2: Maus-Trigger
    ; --------------------------------------------------------------------------
    SettingsGui.Add("GroupBox", "x15 y+25 w480 h80", "Maus-Auslöser")
    chkMiddle := SettingsGui.Add("Checkbox", "x30 yp+25 Checked" MiddleClickTitleBar, "Menü per Mittelklick auf Fenstertitelleiste öffnen")
    chkCtrlRight := SettingsGui.Add("Checkbox", "x30 y+8 Checked" CtrlRightClick, "Menü per Strg + Rechtsklick auf beliebiges Fenster öffnen")

    ; --------------------------------------------------------------------------
    ; Bereich 3: Fenster-Verhalten & Autostart
    ; --------------------------------------------------------------------------
    SettingsGui.Add("GroupBox", "x15 y+20 w480 h80", "Fenster-Verhalten & System")
    chkComp := SettingsGui.Add("Checkbox", "x30 yp+25 Checked" CompensateBorders, "Unsichtbare Windows 10/11 Schattenränder ausgleichen (pixelgenau)")
    chkAuto := SettingsGui.Add("Checkbox", "x30 y+8 Checked" IsAutostartEnabled(), "Programm automatisch mit Windows starten")

    ; --------------------------------------------------------------------------
    ; Buttons
    ; --------------------------------------------------------------------------
    btnSave := SettingsGui.Add("Button", "x15 y+25 w160 h34 Default", "💾 Speichern && Aktivieren")
    btnCancel := SettingsGui.Add("Button", "x+10 yp w110 h34", "Abbrechen")
    btnReset := SettingsGui.Add("Button", "x+10 yp w190 h34", "Standard (Strg + Win + Z)")

    ; Helper: Konstruiert Hotkey aus Checkboxen & Taste
    GetSelectedHotkey() {
        m := (chkCtrl.Value ? "^" : "") (chkWin.Value ? "#" : "") (chkAlt.Value ? "!" : "") (chkShift.Value ? "+" : "")
        k := Trim(cbKey.Text)
        return m (k != "" ? StrLower(k) : "")
    }

    UpdatePreview() {
        hk := GetSelectedHotkey()
        txtPreview.Text := "Vorschau: " FormatHotkeyFriendly(hk)
    }

    SelectMatchingPreset() {
        hk := GetSelectedHotkey()
        switch hk {
            case "^#z": cbPreset.Choose(1)
            case "^!z": cbPreset.Choose(2)
            case "#z": cbPreset.Choose(3)
            case "^!s": cbPreset.Choose(4)
            case "^+z": cbPreset.Choose(5)
            case "!space": cbPreset.Choose(6)
            case "^f12": cbPreset.Choose(7)
            default: cbPreset.Choose(8) ; Benutzerdefiniert...
        }
    }

    OnPresetChanged() {
        switch cbPreset.Value {
            case 1: ; Strg + Win + Z
                chkCtrl.Value := 1, chkWin.Value := 1, chkAlt.Value := 0, chkShift.Value := 0, cbKey.Text := "Z"
            case 2: ; Strg + Alt + Z
                chkCtrl.Value := 1, chkWin.Value := 0, chkAlt.Value := 1, chkShift.Value := 0, cbKey.Text := "Z"
            case 3: ; Win + Z
                chkCtrl.Value := 0, chkWin.Value := 1, chkAlt.Value := 0, chkShift.Value := 0, cbKey.Text := "Z"
            case 4: ; Strg + Alt + S
                chkCtrl.Value := 1, chkWin.Value := 0, chkAlt.Value := 1, chkShift.Value := 0, cbKey.Text := "S"
            case 5: ; Strg + Shift + Z
                chkCtrl.Value := 1, chkWin.Value := 0, chkAlt.Value := 0, chkShift.Value := 1, cbKey.Text := "Z"
            case 6: ; Alt + Leertaste
                chkCtrl.Value := 0, chkWin.Value := 0, chkAlt.Value := 1, chkShift.Value := 0, cbKey.Text := "Space"
            case 7: ; Strg + F12
                chkCtrl.Value := 1, chkWin.Value := 0, chkAlt.Value := 0, chkShift.Value := 0, cbKey.Text := "F12"
        }
        UpdatePreview()
    }

    OnModifierOrKeyChanged(*) {
        UpdatePreview()
        SelectMatchingPreset()
    }

    cbPreset.OnEvent("Change", (*) => OnPresetChanged())
    chkCtrl.OnEvent("Click", OnModifierOrKeyChanged)
    chkWin.OnEvent("Click", OnModifierOrKeyChanged)
    chkAlt.OnEvent("Click", OnModifierOrKeyChanged)
    chkShift.OnEvent("Click", OnModifierOrKeyChanged)
    cbKey.OnEvent("Change", OnModifierOrKeyChanged)

    SelectMatchingPreset()
    UpdatePreview()

    btnReset.OnEvent("Click", (*) => (cbPreset.Choose(1), OnPresetChanged()))
    btnCancel.OnEvent("Click", (*) => SettingsGui.Destroy())
    SettingsGui.OnEvent("Escape", (*) => SettingsGui.Destroy())
    SettingsGui.OnEvent("Close", (*) => SettingsGui.Destroy())

    btnSave.OnEvent("Click", (*) => OnSave())
    OnSave() {
        rawKey := Trim(cbKey.Text)
        if (rawKey = "") {
            MsgBox("Bitte geben Sie eine Taste ein oder wählen Sie eine aus der Liste.", "RightPosition", "Icon!")
            return
        }

        hasMod := chkCtrl.Value || chkWin.Value || chkAlt.Value || chkShift.Value
        isSpecial := RegExMatch(rawKey, "i)^(F\d{1,2}|Pause|PrintScreen|ScrollLock)$")
        if (!hasMod && !isSpecial) {
            ans := MsgBox("Sie haben keine Zusatztaste (Strg, Win, Alt, Shift) ausgewählt.`n`nEine Einzeltaste wie '" rawKey "' würde die normale Eingabe dieser Taste in allen Programmen blockieren!`n`nMöchten Sie wirklich fortfahren?", "RightPosition", "YesNo Icon!")
            if (ans != "Yes")
                return
        }

        targetHk := GetSelectedHotkey()

        ; Hotkey aktualisieren falls geändert
        if (targetHk != HotkeyStr) {
            if !UpdateHotkey(targetHk)
                return
        }

        ; Maus-Auslöser & Fensterverhalten speichern
        MiddleClickTitleBar := chkMiddle.Value
        CtrlRightClick := chkCtrlRight.Value
        CompensateBorders := chkComp.Value

        try IniWrite(MiddleClickTitleBar ? "1" : "0", IniFile, "Settings", "MiddleClickTitleBar")
        try IniWrite(CtrlRightClick ? "1" : "0", IniFile, "Settings", "CtrlRightClick")
        try IniWrite(CompensateBorders ? "1" : "0", IniFile, "Settings", "CompensateBorders")

        ; Autostart
        if (chkAuto.Value != IsAutostartEnabled()) {
            ToggleAutostart()
        }

        SettingsGui.Destroy()
        ShowToast("Einstellungen & Shortcut (" FormatHotkeyFriendly(HotkeyStr) ") gespeichert!")
    }

    SettingsGui.Show("w510")
}

; ------------------------------------------------------------------------------
; Tray Menü & Autostart
; ------------------------------------------------------------------------------
SetupTrayMenu() {
    friendlyHk := FormatHotkeyFriendly(HotkeyStr)
    A_IconTip := "RightPosition (" friendlyHk ")"

    if FileExist(IconFile) {
        try TraySetIcon(IconFile)
    }

    tray := A_TrayMenu
    tray.Delete()
    tray.Add("RightPosition Menü aufrufen (" friendlyHk ")", (*) => ShowRightPositionMenu())
    tray.Default := "RightPosition Menü aufrufen (" friendlyHk ")"
    tray.Add()
    tray.Add("⌨️ Shortcut & Einstellungen...", (*) => ShowSettingsGui())
    tray.Add("⚙️ Einstellungen bearbeiten (INI)...", (*) => EditSettings())
    tray.Add("Neu laden", (*) => Reload())
    tray.Add("Mit Windows starten", ToggleAutostart)

    if IsAutostartEnabled()
        tray.Check("Mit Windows starten")
    else
        tray.Uncheck("Mit Windows starten")

    tray.Add()
    tray.Add("Beenden", (*) => ExitApp())
}

EditSettings(*) {
    Run(IniFile)
}

ToggleAutostart(item := "", *) {
    regKey := "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
    appName := "RightPosition"

    if IsAutostartEnabled() {
        RegDelete(regKey, appName)
        if (item != "" && Type(item) = "String")
            A_TrayMenu.Uncheck(item)
    } else {
        targetPath := A_IsCompiled ? ('"' A_ScriptFullPath '"') : ('"' A_AhkPath '" "' A_ScriptFullPath '"')
        RegWrite(targetPath, "REG_SZ", regKey, appName)
        if (item != "" && Type(item) = "String")
            A_TrayMenu.Check(item)
    }
}

IsAutostartEnabled() {
    regKey := "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
    appName := "RightPosition"
    try {
        val := RegRead(regKey, appName)
        return (val != "")
    }
    return false
}
