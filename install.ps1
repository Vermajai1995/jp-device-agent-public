$InstallDir = "$env:USERPROFILE\jp-device-agent"

Write-Host ""
Write-Host "Installing JP Device Agent..."
Write-Host ""

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

Invoke-WebRequest `-Uri "https://github.com/Vermajai1995/jp-device-agent-public/releases/latest/download/jp-device-agent.zip"`
-OutFile "$InstallDir\jp-device-agent.zip"

Expand-Archive `-Path "$InstallDir\jp-device-agent.zip"`
-DestinationPath $InstallDir `
-Force

Write-Host ""
Write-Host "Installed at:"
Write-Host $InstallDir
Write-Host ""
Write-Host "Installation complete."
