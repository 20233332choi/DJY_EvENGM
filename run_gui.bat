@echo off
setlocal EnableExtensions
cd /d "%~dp0"

wscript.exe "%~dp0run_gui.vbs"

endlocal
