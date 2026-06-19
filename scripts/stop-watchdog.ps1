$pidFile = Join-Path $PSScriptRoot "watchdog.pid"
$watchdogPath = Join-Path $PSScriptRoot "sunshine-watchdog.ps1"

if (-not (Test-Path -LiteralPath $pidFile -PathType Leaf)) {
    Write-Output "The watchdog PID file does not exist."
    exit 0
}

$watchdogPid = (Get-Content -LiteralPath $pidFile -First 1).Trim()
if ($watchdogPid -notmatch '^\d+$') {
    throw "The watchdog PID file is invalid."
}

$process = Get-CimInstance Win32_Process -Filter "ProcessId = $watchdogPid" -ErrorAction SilentlyContinue
if (-not $process) {
    Remove-Item -LiteralPath $pidFile -Force
    Write-Output "Removed a stale watchdog PID file."
    exit 0
}

if ($process.CommandLine -notlike "*$watchdogPath*") {
    throw "PID $watchdogPid is not the Sunshine watchdog; refusing to stop it."
}

Stop-Process -Id ([int]$watchdogPid) -Force
Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
Write-Output "Stopped Sunshine watchdog PID $watchdogPid."

