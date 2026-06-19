$installDirectory = $PSScriptRoot
$sunshinePath = Join-Path $installDirectory "sunshine.exe"
$pidFile = Join-Path $installDirectory "watchdog.pid"
$logFile = Join-Path $installDirectory "watchdog.log"
$mutex = [System.Threading.Mutex]::new($false, "Local\SunshineWatchdog")
$ownsMutex = $false

function Write-WatchdogLog {
    param([Parameter(Mandatory)][string]$Message)

    try {
        if ((Test-Path -LiteralPath $logFile) -and
            (Get-Item -LiteralPath $logFile).Length -ge 1MB) {
            Move-Item -LiteralPath $logFile -Destination "$logFile.old" -Force
        }

        Add-Content -LiteralPath $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
    }
    catch {
        # Logging must never terminate the recovery loop.
    }
}

try {
    try {
        $ownsMutex = $mutex.WaitOne(0, $false)
    }
    catch [System.Threading.AbandonedMutexException] {
        $ownsMutex = $true
    }

    if (-not $ownsMutex) {
        exit 0
    }

    if (-not (Test-Path -LiteralPath $sunshinePath -PathType Leaf)) {
        throw "Sunshine executable not found: $sunshinePath"
    }

    Set-Content -LiteralPath $pidFile -Value $PID
    Write-WatchdogLog "Watchdog started (PID $PID)."

    while ($true) {
        if (-not (Get-Process -Name "sunshine" -ErrorAction SilentlyContinue)) {
            try {
                $process = Start-Process -FilePath $sunshinePath `
                    -WorkingDirectory $installDirectory -PassThru -ErrorAction Stop
                Write-WatchdogLog "Started Sunshine (PID $($process.Id))."
            }
            catch {
                Write-WatchdogLog "Failed to start Sunshine: $($_.Exception.Message)"
            }
        }

        Start-Sleep -Seconds 15
    }
}
catch {
    Write-WatchdogLog "Watchdog stopped with an error: $($_.Exception.Message)"
}
finally {
    if ($ownsMutex) {
        if ((Test-Path -LiteralPath $pidFile) -and
            ((Get-Content -LiteralPath $pidFile -First 1) -eq $PID)) {
            Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
        }

        $mutex.ReleaseMutex()
    }

    $mutex.Dispose()
}

