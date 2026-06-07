$InstallDir = "$env:USERPROFILE\jp-device-agent"

Write-Host ""
Write-Host "Installing JP Device Agent..."
Write-Host ""

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$ZipFile = "$InstallDir\jp-device-agent.zip"

Write-Host "Downloading latest release..."

Invoke-WebRequest `  -Uri "https://github.com/Vermajai1995/jp-device-agent-public/releases/latest/download/jp-device-agent.zip"`
-OutFile $ZipFile

Write-Host "Extracting files..."

Expand-Archive `  -Path $ZipFile`
-DestinationPath $InstallDir `
-Force

Remove-Item $ZipFile -Force

Write-Host ""
Write-Host "Installed at:"
Write-Host $InstallDir
Write-Host ""
Write-Host "Next step:"
Write-Host "cd $InstallDir"
Write-Host "npm install"
Write-Host "npm start"
Write-Host ""
Write-Host "Installation complete."
