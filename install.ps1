$InstallDir = "$env:USERPROFILE\jp-device-agent"
$PidFile = Join-Path $InstallDir "agent.pid"
$LogFile = Join-Path $InstallDir "agent.log"
$ZipFile = Join-Path $InstallDir "jp-device-agent.zip"

# ── Step 1 ──
Write-Host "[1/8] Preparing installation..."
Write-Host ""
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Write-Host "  Install directory: $InstallDir"

# ── Step 2 ──
Write-Host ""
Write-Host "[2/8] Stopping existing agent..."
$AgentStopped = $false

if (Test-Path $PidFile) {
    $OldPid = Get-Content $PidFile -Raw | ForEach-Object { $_.Trim() }

    if ($OldPid -and (Get-Process -Id $OldPid -ErrorAction SilentlyContinue)) {
        Write-Host "  Stopping PID $OldPid..."
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
            Write-Host "  Process did not stop gracefully, force killing..."
            Stop-Process -Id $OldPid -Force
        }

        Write-Host "✓ Existing agent stopped"
        $AgentStopped = $true
    }

    Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
}

if (-not $AgentStopped) {
    Write-Host "  No existing agent found."
}

# ── Step 3 ──
Write-Host ""
Write-Host "[3/8] Downloading latest release..."

Invoke-WebRequest `
    -Uri "https://github.com/Vermajai1995/jp-device-agent-public/releases/latest/download/jp-device-agent.zip" `
    -OutFile $ZipFile `
    -UseBasicParsing

if (-not (Test-Path $ZipFile)) {
    throw "Download failed."
}

Write-Host "✓ Release downloaded"

# ── Step 4 ──
Write-Host ""
Write-Host "[4/8] Extracting files..."

Expand-Archive `
    -Path $ZipFile `
    -DestinationPath $InstallDir `
    -Force

Remove-Item $ZipFile -Force

Write-Host "✓ Files extracted"

Set-Location $InstallDir

# ── Step 5 ──
Write-Host ""
Write-Host "[5/8] Writing configuration..."

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

Write-Host "✓ Configuration written"

# ── Step 6 ──
Write-Host ""
Write-Host "[6/8] Installing dependencies..."

npm ci --omit=dev 2>&1 | Select-Object -Last 1

Write-Host "✓ Dependencies installed"

# ── Step 7 ──
Write-Host ""
Write-Host "[7/8] Starting agent..."

$Process = Start-Process powershell `
    -WindowStyle Hidden `
    -PassThru `
    -ArgumentList "-Command `"cd '$InstallDir'; npm start`""

$Process.Id | Out-File -FilePath $PidFile -Force
Start-Sleep -Seconds 3

Write-Host "✓ Agent started (PID $($Process.Id))"

# ── Step 8 ──
Write-Host ""
Write-Host "[8/8] Installation complete."
Write-Host ""
Write-Host "## Installation Summary"
Write-Host ""
Write-Host "  Install Directory: $InstallDir"
Write-Host "  Device ID:         $env:DEVICE_ID"
Write-Host "  Device Name:       $env:DEVICE_NAME"
Write-Host "  Backend URL:       $env:CORE_BACKEND_URL"
Write-Host "  Agent PID:         $($Process.Id)"
Write-Host ""
Write-Host "  View logs:"
Write-Host "  Get-Content -Wait `"$LogFile`""
Write-Host ""