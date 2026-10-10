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
; - Aufruf per:
;     * Hotkey: Strg + Win + Z (konfigurierbar)
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

InitConfig()
SetupTrayMenu()
RegisterHotkeys()

; ------------------------------------------------------------------------------
; Hotkeys registrieren
; ------------------------------------------------------------------------------
RegisterHotkeys() {
    global HotkeyStr
    if (HotkeyStr != "") {
        try {
            Hotkey(HotkeyStr, (*) => ShowRightPositionMenu())
        } catch as err {
            MsgBox("Fehler beim Registrieren des Hotkeys '" HotkeyStr "':`n" err.Message, "RightPosition", "Icon!")
        }
    }
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
        "Hotkey=^#z`r`n"
        "MiddleClickTitleBar=1`r`n"
        "CtrlRightClick=1`r`n"
        "CompensateBorders=1`r`n"
        "`r`n"
        "[Presets]`r`n"
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

    m.Add() ; Trennlinie
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
        MsgBox("Ungültiges Format. Bitte z. B. '1280 x 720' eingeben.", "SizerAlternative", "Icon!")
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
; Tray Menü & Autostart
; ------------------------------------------------------------------------------
SetupTrayMenu() {
    A_IconTip := "RightPosition (" HotkeyStr ")"

    if FileExist(IconFile) {
        try TraySetIcon(IconFile)
    }

    tray := A_TrayMenu
    tray.Delete()
    tray.Add("RightPosition Menü aufrufen (" HotkeyStr ")", (*) => ShowRightPositionMenu())
    tray.Default := "RightPosition Menü aufrufen (" HotkeyStr ")"
    tray.Add()
    tray.Add("Einstellungen bearbeiten (INI)...", (*) => EditSettings())
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

ToggleAutostart(item, *) {
    regKey := "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
    appName := "RightPosition"

    if IsAutostartEnabled() {
        RegDelete(regKey, appName)
        A_TrayMenu.Uncheck(item)
    } else {
        targetPath := A_IsCompiled ? ('"' A_ScriptFullPath '"') : ('"' A_AhkPath '" "' A_ScriptFullPath '"')
        RegWrite(targetPath, "REG_SZ", regKey, appName)
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

