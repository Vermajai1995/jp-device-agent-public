$InstallDir = "$env:USERPROFILE\jp-device-agent"

Write-Host ""
Write-Host "Installing JP Device Agent..."
Write-Host ""

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$ZipFile = "$InstallDir\jp-device-agent.zip"

Invoke-WebRequest `  -Uri "https://github.com/Vermajai1995/jp-device-agent-public/releases/latest/download/jp-device-agent.zip"`
-OutFile $ZipFile

Expand-Archive `  -Path $ZipFile`
-DestinationPath $InstallDir `
-Force

Remove-Item $ZipFile -Force

Set-Location $InstallDir

Write-Host "Installing dependencies..."
npm install

$TaskName = "JP Device Agent"

schtasks /Delete /TN "$TaskName" /F 2>$null

schtasks /Create ` /SC ONLOGON`
/RL HIGHEST ` /TN "$TaskName"`
/TR "cmd /c cd /d $InstallDir && npm start" `
/F

schtasks /Run /TN "$TaskName"

Write-Host ""
Write-Host "JP Device Agent installed."
Write-Host "Scheduled task created."
Write-Host "Agent started."
Write-Host ""
