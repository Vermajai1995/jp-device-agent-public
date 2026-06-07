$InstallDir = "$env:ProgramData\JPDeviceAgent"

Write-Host ""
Write-Host "Installing JP Device Agent..."
Write-Host ""

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$ZipFile = "$InstallDir\jp-device-agent.zip"

Invoke-WebRequest `
  -Uri "https://github.com/Vermajai1995/jp-device-agent/releases/latest/download/jp-device-agent.zip" `
  -OutFile $ZipFile

Expand-Archive `
  -Path $ZipFile `
  -DestinationPath $InstallDir `
  -Force

Write-Host ""
Write-Host "Installed at:"
Write-Host $InstallDir
Write-Host ""
Write-Host "Installation complete."