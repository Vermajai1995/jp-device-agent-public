$InstallDir = "$env:USERPROFILE\jp-device-agent"
$PidFile = Join-Path $InstallDir "agent.pid"
$LogFile = Join-Path $InstallDir "agent.log"
$ZipFile = Join-Path $InstallDir "jp-device-agent.zip"

Write-Host ""
Write-Host "Installing JP Device Agent..."
Write-Host ""

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

# ── Stop existing agent process if running ──
# Strategy: read PID from agent.pid file and stop only that specific process.
# This kills ONLY jp-device-agent, never unrelated node processes.
if (Test-Path $PidFile) {
    $OldPid = Get-Content $PidFile -Raw | ForEach-Object { $_.Trim() }

    if ($OldPid -and (Get-Process -Id $OldPid -ErrorAction SilentlyContinue)) {
        Write-Host "Stopping existing JP Device Agent (PID $OldPid)..."
        $Process = Get-Process -Id $OldPid

        # Try graceful shutdown via CloseMainWindow
        $Process.CloseMainWindow() | Out-Null

        # Wait up to 5 seconds for graceful shutdown
        $waited = 0
        while ($waited -lt 5) {
            if (-not (Get-Process -Id $OldPid -ErrorAction SilentlyContinue)) {
                break
            }
            Start-Sleep -Seconds 1
            $waited++
        }

        # Force kill if still running
        if (Get-Process -Id $OldPid -ErrorAction SilentlyContinue) {
            Write-Host "Agent did not stop gracefully, force killing..."
            Stop-Process -Id $OldPid -Force
        }

        Write-Host "Agent stopped."
    }

    Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
}

Write-Host "Downloading latest release..."

Invoke-WebRequest `
    -Uri "https://github.com/Vermajai1995/jp-device-agent-public/releases/latest/download/jp-device-agent.zip" `
    -OutFile $ZipFile

if (-not (Test-Path $ZipFile)) {
    throw "Download failed."
}

Write-Host "Extracting files..."

Expand-Archive `
    -Path $ZipFile `
    -DestinationPath $InstallDir `
    -Force

Remove-Item $ZipFile -Force

Set-Location $InstallDir

if (-not $env:DEVICE_ID) {
    $env:DEVICE_ID = "other"
}

if (-not $env:DEVICE_NAME) {
    $env:DEVICE_NAME = "other"
}

if (-not $env:CORE_BACKEND_URL) {
    $env:CORE_BACKEND_URL = "https://core-backend-navy.vercel.app"
}

@"
DEVICE_ID=$env:DEVICE_ID
DEVICE_NAME=$env:DEVICE_NAME
CORE_BACKEND_URL=$env:CORE_BACKEND_URL
"@ | Set-Content "$InstallDir\.env.local"

Write-Host "Installing dependencies..."

npm ci --omit=dev

Write-Host "Starting agent..."

$Process = Start-Process powershell `
    -WindowStyle Hidden `
    -PassThru `
    -ArgumentList "-Command `"cd '$InstallDir'; npm start`""

# Save PID for future upgrades
$Process.Id | Out-File -FilePath $PidFile -Force

Write-Host ""
Write-Host "Installed at:"
Write-Host $InstallDir
Write-Host ""
Write-Host "Agent started (PID $($Process.Id))."
Write-Host ""
Write-Host "View logs:"
Write-Host "Get-Content -Wait `"$LogFile`""
Write-Host ""
Write-Host "Installation complete."
Write-Host ""