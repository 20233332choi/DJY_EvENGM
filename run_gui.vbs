Option Explicit

Dim fso, shell, root, gui, command
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
root = fso.GetParentFolderName(WScript.ScriptFullName)
gui = fso.BuildPath(root, "gui\DJY_EvENGM-GUI.ps1")
command = "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File " & Chr(34) & gui & Chr(34)
shell.Run command, 0, False
