@echo off
setlocal EnableExtensions
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0gui\DJY_EvENGM-GUI.ps1"
if errorlevel 1 (
    echo.
    echo GUI launch failed.
    pause
)

endlocal
