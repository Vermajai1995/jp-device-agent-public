```powershell
$InstallDir = "$env:USERPROFILE\jp-device-agent"

Write-Host ""
Write-Host "Installing JP Device Agent..."
Write-Host ""

# Remove old installation completely
if (Test-Path $InstallDir) {
    Write-Host "Removing previous installation..."
    Remove-Item $InstallDir -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$ZipFile = Join-Path $InstallDir "jp-device-agent.zip"

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

npm install --omit=dev

Write-Host "Starting agent..."

Start-Process powershell `
    -WindowStyle Hidden `
    -ArgumentList "-Command `"cd '$InstallDir'; npm start`""

Write-Host ""
Write-Host "Installed at:"
Write-Host $InstallDir
Write-Host ""
Write-Host "Agent started in background."
Write-Host ""
Write-Host "Installation complete."
Write-Host ""
```
