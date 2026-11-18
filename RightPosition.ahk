#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()

; ==============================================================================
; RightPosition - Open-Source Fenster-Skalierung & Platzierung für Windows
; (Zukunftssicherer, auditierbarer Sizer 4.0 Ersatz in AutoHotkey v2)
; ==============================================================================
; Features:
; - Vollständige Lokalisierung (Deutsch & Englisch) mit automatischer Spracherkennung
; - Aktuelle Fensterposition & Größe per Klick als Preset abspeichern
; - Gespeicherte Presets per Klick wieder anwenden (Größe + Position)
; - Konfigurierbare Hotkeys & Shortcuts (über moderne Einstellungen-GUI oder INI)
; - Aufruf per:
;     * Frei wählbarer Hotkey: Standardmäßig Strg + Win + Z / Ctrl + Win + Z
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
global AppLang := "auto"
global CurrentLang := "en"
global SettingsGui := ""

InitConfig()
SetupTrayMenu()
RegisterHotkeys()

; ------------------------------------------------------------------------------
; Spracherkennung & Übersetzungen (i18n: Deutsch & Englisch)
; ------------------------------------------------------------------------------
DetectLanguage() {
    global AppLang, CurrentLang
    if (AppLang = "de" || AppLang = "en") {
        CurrentLang := AppLang
        return
    }
    ; Automatische Erkennung anhand der Windows-Systemsprache (0x07 = Deutsch)
    try {
        isGerman := (SubStr(A_Language, -2) = "07")
        CurrentLang := isGerman ? "de" : "en"
    } catch {
        CurrentLang := "en"
    }
}

T(key, p1 := "", p2 := "", p3 := "", p4 := "") {
    global CurrentLang
    static dict := Map(
        "cur_info", Map(
            "de", "Aktuell: {1} × {2}  [Pos: {3}, {4}]  (Kopieren)",
            "en", "Current: {1} × {2}  [Pos: {3}, {4}]  (Copy)"
        ),
        "toast_copied", Map(
            "de", "Maße in die Zwischenablage kopiert!",
            "en", "Dimensions copied to clipboard!"
        ),
        "menu_save_preset", Map(
            "de", "💾 Aktuelle Position & Größe speichern...",
            "en", "💾 Save current position & size..."
        ),
        "menu_custom_size", Map(
            "de", "📐 Benutzerdefinierte Größe...",
            "en", "📐 Custom window size..."
        ),
        "menu_position", Map(
            "de", "📍 Positionieren",
            "en", "📍 Position window"
        ),
        "pos_center", Map(
            "de", "Fenster zentrieren",
            "en", "Center window"
        ),
        "pos_topleft", Map(
            "de", "Oben links",
            "en", "Top left"
        ),
        "pos_topright", Map(
            "de", "Oben rechts",
            "en", "Top right"
        ),
        "pos_bottomleft", Map(
            "de", "Unten links",
            "en", "Bottom left"
        ),
        "pos_bottomright", Map(
            "de", "Unten rechts",
            "en", "Bottom right"
        ),
        "menu_del_preset", Map(
            "de", "🗑️ Preset löschen",
            "en", "🗑️ Delete preset"
        ),
        "menu_settings", Map(
            "de", "⌨️ Shortcut & Einstellungen ({1})...",
            "en", "⌨️ Shortcut & Settings ({1})..."
        ),
        "menu_edit_ini", Map(
            "de", "⚙️ Einstellungen bearbeiten (INI)...",
            "en", "⚙️ Edit settings (INI)..."
        ),
        "save_dlg_title", Map(
            "de", "Aktuelle Position & Größe speichern",
            "en", "Save Current Position & Size"
        ),
        "save_dlg_prompt", Map(
            "de", "Geben Sie einen Namen für das neue Preset ein:`n`n• Breite: {1} px`n• Höhe: {2} px`n• Position X: {3} px (relativ zum Monitor)`n• Position Y: {4} px (relativ zum Monitor)",
            "en", "Enter a name for the new preset:`n`n• Width: {1} px`n• Height: {2} px`n• Position X: {3} px (relative to monitor)`n• Position Y: {4} px (relative to monitor)"
        ),
        "toast_preset_saved", Map(
            "de", "Preset '{1}' gespeichert!",
            "en", "Preset '{1}' saved!"
        ),
        "del_dlg_title", Map(
            "de", "Preset löschen",
            "en", "Delete Preset"
        ),
        "del_dlg_prompt", Map(
            "de", "Möchten Sie das Preset '{1}' wirklich löschen?",
            "en", "Are you sure you want to delete preset '{1}'?"
        ),
        "toast_preset_deleted", Map(
            "de", "Preset gelöscht!",
            "en", "Preset deleted!"
        ),
        "custom_dlg_title", Map(
            "de", "Benutzerdefinierte Größe",
            "en", "Custom Window Size"
        ),
        "custom_dlg_prompt", Map(
            "de", "Breite und Höhe eingeben (z. B. 1280x720 oder 1280 720):",
            "en", "Enter width and height (e.g. 1280x720 or 1280 720):"
        ),
        "custom_dlg_invalid", Map(
            "de", "Ungültiges Format. Bitte z. B. '1280 x 720' eingeben.",
            "en", "Invalid format. Please enter e.g. '1280 x 720'."
        ),
        "tray_open", Map(
            "de", "RightPosition Menü aufrufen ({1})",
            "en", "Open RightPosition menu ({1})"
        ),
        "tray_settings", Map(
            "de", "⌨️ Shortcut & Einstellungen...",
            "en", "⌨️ Shortcut & Settings..."
        ),
        "tray_reload", Map(
            "de", "Neu laden",
            "en", "Reload"
        ),
        "tray_autostart", Map(
            "de", "Mit Windows starten",
            "en", "Start with Windows"
        ),
        "tray_exit", Map(
            "de", "Beenden",
            "en", "Exit"
        ),
        "gui_title", Map(
            "de", "RightPosition - Shortcut & Einstellungen",
            "en", "RightPosition - Shortcut & Settings"
        ),
        "grp_shortcut", Map(
            "de", "Tastatur-Shortcut (Menü aufrufen)",
            "en", "Keyboard Shortcut (Open menu)"
        ),
        "lbl_preset_quick", Map(
            "de", "Schnellauswahl beliebter Tastenkombinationen:",
            "en", "Quick select popular shortcuts:"
        ),
        "preset_default", Map(
            "de", "Strg + Win + Z (Standard / Sizer)",
            "en", "Ctrl + Win + Z (Default / Sizer)"
        ),
        "preset_custom", Map(
            "de", "Benutzerdefiniert...",
            "en", "Custom..."
        ),
        "lbl_modifiers", Map(
            "de", "Zusatztasten (Modifikatoren):",
            "en", "Modifier keys:"
        ),
        "chk_ctrl", Map(
            "de", "Strg (Ctrl)",
            "en", "Ctrl"
        ),
        "chk_win", Map(
            "de", "Windows (Win)",
            "en", "Windows (Win)"
        ),
        "chk_alt", Map(
            "de", "Alt",
            "en", "Alt"
        ),
        "chk_shift", Map(
            "de", "Umschalt (Shift)",
            "en", "Shift"
        ),
        "lbl_key", Map(
            "de", "Taste:",
            "en", "Key:"
        ),
        "lbl_active", Map(
            "de", "Aktiv: ",
            "en", "Active: "
        ),
        "lbl_preview", Map(
            "de", "Vorschau: ",
            "en", "Preview: "
        ),
        "grp_mouse", Map(
            "de", "Maus-Auslöser",
            "en", "Mouse Triggers"
        ),
        "chk_mouse_middle", Map(
            "de", "Menü per Mittelklick auf Fenstertitelleiste öffnen",
            "en", "Open menu via middle-click on window title bar"
        ),
        "chk_mouse_ctrl_right", Map(
            "de", "Menü per Strg + Rechtsklick auf beliebiges Fenster öffnen",
            "en", "Open menu via Ctrl + Right-click on any window"
        ),
        "grp_behavior", Map(
            "de", "Fenster-Verhalten & System",
            "en", "Window Behavior & System"
        ),
        "chk_compensate", Map(
            "de", "Unsichtbare Windows 10/11 Schattenränder ausgleichen (pixelgenau)",
            "en", "Compensate invisible Windows 10/11 shadow borders (pixel-exact)"
        ),
        "chk_autostart", Map(
            "de", "Programm automatisch mit Windows starten",
            "en", "Start program automatically with Windows"
        ),
        "grp_language", Map(
            "de", "Sprache / Language",
            "en", "Language / Sprache"
        ),
        "lang_auto", Map(
            "de", "Automatisch (Systemsprache)",
            "en", "Automatic (System language)"
        ),
        "btn_save", Map(
            "de", "💾 Speichern & Aktivieren",
            "en", "💾 Save & Apply"
        ),
        "btn_cancel", Map(
            "de", "Abbrechen",
            "en", "Cancel"
        ),
        "btn_reset", Map(
            "de", "Standard (Strg + Win + Z)",
            "en", "Default (Ctrl + Win + Z)"
        ),
        "err_no_key", Map(
            "de", "Bitte geben Sie eine Taste ein oder wählen Sie eine aus der Liste.",
            "en", "Please enter a key or select one from the list."
        ),
        "warn_single_key", Map(
            "de", "Sie haben keine Zusatztaste (Strg, Win, Alt, Shift) ausgewählt.`n`nEine Einzeltaste wie '{1}' würde die normale Eingabe dieser Taste in allen Programmen blockieren!`n`nMöchten Sie wirklich fortfahren?",
            "en", "You haven't selected any modifier keys (Ctrl, Win, Alt, Shift).`n`nA single key like '{1}' will block normal typing of that key across all applications!`n`nAre you sure you want to proceed?"
        ),
        "err_hotkey_failed", Map(
            "de", "Der Shortcut '{1}' konnte nicht aktiviert werden:`n`n{2}`n`nMöglicherweise ist dieser Shortcut bereits vom System oder einem anderen Programm belegt.",
            "en", "The shortcut '{1}' could not be registered:`n`n{2}`n`nIt may already be reserved by Windows or another running application."
        ),
        "toast_settings_saved", Map(
            "de", "Einstellungen & Shortcut ({1}) gespeichert!",
            "en", "Settings & Shortcut ({1}) saved!"
        )
    )

    if !dict.Has(key)
        return key

    subMap := dict[key]
    str := subMap.Has(CurrentLang) ? subMap[CurrentLang] : subMap["en"]
    if (p1 != "")
        str := StrReplace(str, "{1}", p1)
    if (p2 != "")
        str := StrReplace(str, "{2}", p2)
    if (p3 != "")
        str := StrReplace(str, "{3}", p3)
    if (p4 != "")
        str := StrReplace(str, "{4}", p4)
    return str
}

; ------------------------------------------------------------------------------
; Hotkeys registrieren & verwalten
; ------------------------------------------------------------------------------
RegisterHotkeys() {
    global HotkeyStr
    if (HotkeyStr != "") {
        try {
            Hotkey(HotkeyStr, (*) => ShowRightPositionMenu(), "On")
        } catch as err {
            MsgBox(T("err_hotkey_failed", FormatHotkeyFriendly(HotkeyStr), err.Message), "RightPosition", "Icon!")
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
        MsgBox(T("err_hotkey_failed", FormatHotkeyFriendly(newHk), err.Message), "RightPosition", "Icon!")
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
FormatHotkeyFriendly(hk, lang := "") {
    global CurrentLang
    useEn := (lang = "en" || (lang = "" && CurrentLang = "en"))
    if (hk = "")
        return useEn ? "None" : "Keiner"
    
    str := ""
    if InStr(hk, "^")
        str .= useEn ? "Ctrl + " : "Strg + "
    if InStr(hk, "#")
        str .= "Win + "
    if InStr(hk, "!")
        str .= "Alt + "
    if InStr(hk, "+")
        str .= "Shift + "
    
    keyPart := RegExReplace(hk, "[\^#!+]")
    switch StrLower(keyPart) {
        case "space": keyPart := useEn ? "Space" : "Leertaste"
        case "enter": keyPart := useEn ? "Enter" : "Eingabetaste"
        case "tab": keyPart := "Tab"
        case "esc": keyPart := "Escape"
        case "delete", "del": keyPart := useEn ? "Delete" : "Entf"
        case "insert", "ins": keyPart := useEn ? "Insert" : "Einfg"
        case "home": keyPart := useEn ? "Home" : "Pos1"
        case "end": keyPart := useEn ? "End" : "Ende"
        case "pgup": keyPart := useEn ? "PageUp" : "BildAuf"
        case "pgdn": keyPart := useEn ? "PageDown" : "BildAb"
        case "up": keyPart := useEn ? "Arrow Up" : "Pfeil Oben"
        case "down": keyPart := useEn ? "Arrow Down" : "Pfeil Unten"
        case "left": keyPart := useEn ? "Arrow Left" : "Pfeil Links"
        case "right": keyPart := useEn ? "Arrow Right" : "Pfeil Rechts"
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
    global Presets, HotkeyStr, MiddleClickTitleBar, CtrlRightClick, CompensateBorders, AppLang

    if !FileExist(IniFile) {
        CreateDefaultIni()
    }

    try HotkeyStr := IniRead(IniFile, "Settings", "Hotkey", "^#z")
    try MiddleClickTitleBar := (IniRead(IniFile, "Settings", "MiddleClickTitleBar", "1") = "1")
    try CtrlRightClick := (IniRead(IniFile, "Settings", "CtrlRightClick", "1") = "1")
    try CompensateBorders := (IniRead(IniFile, "Settings", "CompensateBorders", "1") = "1")
    try AppLang := IniRead(IniFile, "Settings", "Language", "auto")

    DetectLanguage()

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
    global CurrentLang
    DetectLanguage()
    isDe := (CurrentLang = "de")

    n1 := isDe ? "1920 x 1080 (Full HD, Zentriert)" : "1920 x 1080 (Full HD, Centered)"
    n2 := isDe ? "1600 x 900 (HD+, Zentriert)" : "1600 x 900 (HD+, Centered)"
    n3 := isDe ? "1280 x 720 (HD 720p, Zentriert)" : "1280 x 720 (HD 720p, Centered)"
    n4 := isDe ? "1024 x 768 (XGA, Zentriert)" : "1024 x 768 (XGA, Centered)"
    n5 := isDe ? "800 x 600 (SVGA, Zentriert)" : "800 x 600 (SVGA, Centered)"

    defaultIni := 
    (
        "[Settings]`r`n"
        "; Hotkey (^ = Ctrl, # = Win, ! = Alt, + = Shift)`r`n"
        "Hotkey=^#z`r`n"
        "`r`n"
        "; Language: auto, de, en`r`n"
        "Language=auto`r`n"
        "`r`n"
        "; MiddleClickTitleBar (1 = On, 0 = Off)`r`n"
        "MiddleClickTitleBar=1`r`n"
        "`r`n"
        "; CtrlRightClick (1 = On, 0 = Off)`r`n"
        "CtrlRightClick=1`r`n"
        "`r`n"
        "; CompensateBorders (1 = On, 0 = Off)`r`n"
        "CompensateBorders=1`r`n"
        "`r`n"
        "[Presets]`r`n"
        "; Format: Name|Width|Height|Mode|RelX|RelY`r`n"
        "Item1=" n1 "|1920|1080|center|0|0`r`n"
        "Item2=" n2 "|1600|900|center|0|0`r`n"
        "Item3=" n3 "|1280|720|center|0|0`r`n"
        "Item4=" n4 "|1024|768|center|0|0`r`n"
        "Item5=" n5 "|800|600|center|0|0`r`n"
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
    curInfo := T("cur_info", vw, vh, relX, relY)
    m.Add(curInfo, (*) => (A_Clipboard := vw " x " vh " @ " relX ", " relY, ShowToast(T("toast_copied"))))
    m.Add() ; Trennlinie

    ; KILLER-FEATURE: Aktuelle Größe & Position als Preset speichern
    m.Add(T("menu_save_preset"), (*) => SaveCurrentAsPreset(hwnd))
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
    m.Add(T("menu_custom_size"), (*) => PromptCustomSize(hwnd))

    ; Submenü für Positionierung
    posMenu := Menu()
    posMenu.Add(T("pos_center"), (*) => PositionTarget(hwnd, "center"))
    posMenu.Add(T("pos_topleft"), (*) => PositionTarget(hwnd, "topleft"))
    posMenu.Add(T("pos_topright"), (*) => PositionTarget(hwnd, "topright"))
    posMenu.Add(T("pos_bottomleft"), (*) => PositionTarget(hwnd, "bottomleft"))
    posMenu.Add(T("pos_bottomright"), (*) => PositionTarget(hwnd, "bottomright"))
    m.Add(T("menu_position"), posMenu)

    ; Submenü zum Löschen von Presets
    if (Presets.Length > 0) {
        delMenu := Menu()
        for idx, pItem in Presets {
            delMenu.Add(pItem.title, ((delIdx, *) => DeletePresetByIndex(delIdx)).Bind(idx))
        }
        m.Add(T("menu_del_preset"), delMenu)
    }

    friendlyHk := FormatHotkeyFriendly(HotkeyStr)
    m.Add() ; Trennlinie
    m.Add(T("menu_settings", friendlyHk), (*) => ShowSettingsGui())
    m.Add(T("menu_edit_ini"), (*) => EditSettings())

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

    promptText := T("save_dlg_prompt", vw, vh, relX, relY)

    ib := InputBox(promptText, T("save_dlg_title"), "W380 H230", defaultName)
    if (ib.Result != "OK" || Trim(ib.Value) == "")
        return

    newName := Trim(ib.Value)

    ; Am Anfang einfügen, damit das neue Preset sofort oben steht
    newEntry := { title: newName, width: vw, height: vh, position: "fixed", relX: relX, relY: relY, isFixed: true }
    Presets.InsertAt(1, newEntry)
    WritePresetsToIni()

    ShowToast(T("toast_preset_saved", newName))
}

DeletePresetByIndex(index) {
    if (index < 1 || index > Presets.Length)
        return

    targetItem := Presets[index]
    ans := MsgBox(T("del_dlg_prompt", targetItem.title), T("del_dlg_title"), "YesNo Icon?")
    if (ans == "Yes") {
        Presets.RemoveAt(index)
        WritePresetsToIni()
        ShowToast(T("toast_preset_deleted"))
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

    ib := InputBox(T("custom_dlg_prompt"), T("custom_dlg_title"), "W320 H130", curW " x " curH)
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
        MsgBox(T("custom_dlg_invalid"), "RightPosition", "Icon!")
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
CloseSettingsGui() {
    global SettingsGui
    if (SettingsGui is Gui) {
        try SettingsGui.Destroy()
        SettingsGui := ""
    }
}

ShowSettingsGui(*) {
    global SettingsGui, HotkeyStr, MiddleClickTitleBar, CtrlRightClick, CompensateBorders, IniFile, IconFile, AppLang, CurrentLang

    ; Falls bereits geöffnet und aktiv, in den Vordergrund bringen
    if (SettingsGui is Gui) {
        try {
            if WinExist("ahk_id " SettingsGui.Hwnd) {
                SettingsGui.Show()
                WinActivate("ahk_id " SettingsGui.Hwnd)
                return
            }
        } catch {
            SettingsGui := ""
        }
    }

    DetectLanguage()

    SettingsGui := Gui("+AlwaysOnTop -MinimizeBox", T("gui_title"))
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
    SettingsGui.Add("GroupBox", "x15 y10 w480 h175", T("grp_shortcut"))

    SettingsGui.Add("Text", "x30 yp+25", T("lbl_preset_quick"))
    presetChoices := [
        T("preset_default"),
        FormatHotkeyFriendly("^!z") " (" (CurrentLang = "de" ? "Strg+Alt+Z" : "Ctrl+Alt+Z") ")",
        FormatHotkeyFriendly("#z") " (" (CurrentLang = "de" ? "Win+Z" : "Win+Z") ")",
        FormatHotkeyFriendly("^!s") " (" (CurrentLang = "de" ? "Strg+Alt+S" : "Ctrl+Alt+S") ")",
        FormatHotkeyFriendly("^+z") " (" (CurrentLang = "de" ? "Strg+Shift+Z" : "Ctrl+Shift+Z") ")",
        FormatHotkeyFriendly("!space") " (" (CurrentLang = "de" ? "Alt+Leertaste" : "Alt+Space") ")",
        FormatHotkeyFriendly("^f12") " (" (CurrentLang = "de" ? "Strg+F12" : "Ctrl+F12") ")",
        T("preset_custom")
    ]
    cbPreset := SettingsGui.Add("DropDownList", "x30 y+5 w280", presetChoices)

    SettingsGui.Add("Text", "x30 y+12", T("lbl_modifiers"))
    chkCtrl := SettingsGui.Add("Checkbox", "x30 y+5 Checked" curCtrl, T("chk_ctrl"))
    chkWin := SettingsGui.Add("Checkbox", "x+15 yp Checked" curWin, T("chk_win"))
    chkAlt := SettingsGui.Add("Checkbox", "x+15 yp Checked" curAlt, T("chk_alt"))
    chkShift := SettingsGui.Add("Checkbox", "x+15 yp Checked" curShift, T("chk_shift"))

    SettingsGui.Add("Text", "x30 y+12", T("lbl_key"))
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

    txtPreview := SettingsGui.Add("Text", "x200 yp+3 w280 cBlue", T("lbl_active") FormatHotkeyFriendly(HotkeyStr))
    txtPreview.SetFont("s9 Bold")

    ; --------------------------------------------------------------------------
    ; Bereich 2: Maus-Trigger
    ; --------------------------------------------------------------------------
    SettingsGui.Add("GroupBox", "x15 y+25 w480 h80", T("grp_mouse"))
    chkMiddle := SettingsGui.Add("Checkbox", "x30 yp+25 Checked" MiddleClickTitleBar, T("chk_mouse_middle"))
    chkCtrlRight := SettingsGui.Add("Checkbox", "x30 y+8 Checked" CtrlRightClick, T("chk_mouse_ctrl_right"))

    ; --------------------------------------------------------------------------
    ; Bereich 3: Fenster-Verhalten & System
    ; --------------------------------------------------------------------------
    SettingsGui.Add("GroupBox", "x15 y+20 w480 h80", T("grp_behavior"))
    chkComp := SettingsGui.Add("Checkbox", "x30 yp+25 Checked" CompensateBorders, T("chk_compensate"))
    chkAuto := SettingsGui.Add("Checkbox", "x30 y+8 Checked" IsAutostartEnabled(), T("chk_autostart"))

    ; --------------------------------------------------------------------------
    ; Bereich 4: Sprache / Language
    ; --------------------------------------------------------------------------
    SettingsGui.Add("GroupBox", "x15 y+20 w480 h55", T("grp_language"))
    langChoices := [
        T("lang_auto"),
        "Deutsch (German)",
        "English"
    ]
    curLangIdx := (AppLang = "de") ? 2 : (AppLang = "en" ? 3 : 1)
    cbLang := SettingsGui.Add("DropDownList", "x30 yp+20 w280 Choose" curLangIdx, langChoices)

    ; --------------------------------------------------------------------------
    ; Buttons
    ; --------------------------------------------------------------------------
    btnSave := SettingsGui.Add("Button", "x15 y+25 w160 h34 Default", T("btn_save"))
    btnCancel := SettingsGui.Add("Button", "x+10 yp w110 h34", T("btn_cancel"))
    btnReset := SettingsGui.Add("Button", "x+10 yp w190 h34", T("btn_reset"))

    ; Helper: Konstruiert Hotkey aus Checkboxen & Taste
    GetSelectedHotkey() {
        m := (chkCtrl.Value ? "^" : "") (chkWin.Value ? "#" : "") (chkAlt.Value ? "!" : "") (chkShift.Value ? "+" : "")
        k := Trim(cbKey.Text)
        return m (k != "" ? StrLower(k) : "")
    }

    UpdatePreview() {
        hk := GetSelectedHotkey()
        txtPreview.Text := T("lbl_preview") FormatHotkeyFriendly(hk)
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
    btnCancel.OnEvent("Click", (*) => CloseSettingsGui())
    SettingsGui.OnEvent("Escape", (*) => CloseSettingsGui())
    SettingsGui.OnEvent("Close", (*) => CloseSettingsGui())

    btnSave.OnEvent("Click", (*) => OnSave())
    OnSave() {
        rawKey := Trim(cbKey.Text)
        if (rawKey = "") {
            MsgBox(T("err_no_key"), "RightPosition", "Icon!")
            return
        }

        hasMod := chkCtrl.Value || chkWin.Value || chkAlt.Value || chkShift.Value
        isSpecial := RegExMatch(rawKey, "i)^(F\d{1,2}|Pause|PrintScreen|ScrollLock)$")
        if (!hasMod && !isSpecial) {
            ans := MsgBox(T("warn_single_key", rawKey), "RightPosition", "YesNo Icon!")
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

        ; Spracheinstellung speichern
        newAppLang := (cbLang.Value = 2) ? "de" : (cbLang.Value = 3 ? "en" : "auto")
        AppLang := newAppLang
        try IniWrite(AppLang, IniFile, "Settings", "Language")
        DetectLanguage()

        ; Autostart
        if (chkAuto.Value != IsAutostartEnabled()) {
            ToggleAutostart()
        }

        SetupTrayMenu()
        savedMsg := T("toast_settings_saved", FormatHotkeyFriendly(HotkeyStr))
        CloseSettingsGui()
        ShowToast(savedMsg)
    }

    SettingsGui.Show("w510")
}

; ------------------------------------------------------------------------------
; Tray Menü & Autostart
; ------------------------------------------------------------------------------
SetupTrayMenu() {
    DetectLanguage()
    friendlyHk := FormatHotkeyFriendly(HotkeyStr)
    A_IconTip := "RightPosition (" friendlyHk ")"

    if FileExist(IconFile) {
        try TraySetIcon(IconFile)
    }

    tray := A_TrayMenu
    tray.Delete()
    tray.Add(T("tray_open", friendlyHk), (*) => ShowRightPositionMenu())
    tray.Default := T("tray_open", friendlyHk)
    tray.Add()
    tray.Add(T("tray_settings"), (*) => ShowSettingsGui())
    tray.Add(T("menu_edit_ini"), (*) => EditSettings())
    tray.Add(T("tray_reload"), (*) => Reload())
    tray.Add(T("tray_autostart"), ToggleAutostart)

    if IsAutostartEnabled()
        tray.Check(T("tray_autostart"))
    else
        tray.Uncheck(T("tray_autostart"))

    tray.Add()
    tray.Add(T("tray_exit"), (*) => ExitApp())
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
