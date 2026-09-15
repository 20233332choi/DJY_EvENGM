@echo off
setlocal
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0gui\DJY_EvENGM-GUI.ps1"
if errorlevel 1 (
    echo.
    echo GUI 실행에 실패했습니다.
    pause
)

endlocal
