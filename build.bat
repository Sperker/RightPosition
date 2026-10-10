@echo off
setlocal
cd /d "%~dp0"

echo ===================================================
echo Building RightPosition.exe
echo ===================================================

set "AHK2EXE="
if exist "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" set "AHK2EXE=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
if not defined AHK2EXE if exist "%LOCALAPPDATA%\Programs\AutoHotkey\Compiler\Ahk2Exe.exe" set "AHK2EXE=%LOCALAPPDATA%\Programs\AutoHotkey\Compiler\Ahk2Exe.exe"

set "BASE_AHK="
if exist "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" set "BASE_AHK=C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
if not defined BASE_AHK if exist "%LOCALAPPDATA%\Programs\AutoHotkey\v2\AutoHotkey64.exe" set "BASE_AHK=%LOCALAPPDATA%\Programs\AutoHotkey\v2\AutoHotkey64.exe"

if not defined AHK2EXE (
    echo [ERROR] Ahk2Exe.exe was not found. Please ensure AutoHotkey v2 + Compiler is installed.
    pause
    exit /b 1
)

if not defined BASE_AHK (
    echo [ERROR] AutoHotkey64.exe was not found.
    pause
    exit /b 1
)

echo Stopping any running instance of RightPosition.exe...
taskkill /F /IM RightPosition.exe >nul 2>&1
timeout /t 1 /nobreak >nul

echo Compiling RightPosition.ahk into RightPosition.exe with app.ico...
"%AHK2EXE%" /in "RightPosition.ahk" /out "RightPosition.exe" /icon "app.ico" /base "%BASE_AHK%" /silent

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCCESS] RightPosition.exe built successfully!
    echo ===================================================
) else (
    echo.
    echo [FAILED] Compilation failed with error code %ERRORLEVEL%.
)

pause
