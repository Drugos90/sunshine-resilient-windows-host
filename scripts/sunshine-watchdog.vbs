Set FileSystem = CreateObject("Scripting.FileSystemObject")
Set WshShell = CreateObject("WScript.Shell")

InstallDirectory = FileSystem.GetParentFolderName(WScript.ScriptFullName)
PowerShellPath = WshShell.ExpandEnvironmentStrings("%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe")
WatchdogPath = FileSystem.BuildPath(InstallDirectory, "sunshine-watchdog.ps1")

WshShell.CurrentDirectory = InstallDirectory
WshShell.Run """" & PowerShellPath & """ -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File """ & WatchdogPath & """", 0, False

