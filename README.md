# JP Device Agent Public

Public distribution repository for JP Device Agent.

This repository contains:

- Windows installer
- macOS installer
- Latest release artifacts

## Windows

Run PowerShell as Administrator:

```powershell
irm https://raw.githubusercontent.com/Vermajai1995/jp-device-agent-public/main/install.ps1 | iex

macOS

Run Terminal:

curl -fsSL https://raw.githubusercontent.com/Vermajai1995/jp-device-agent-public/main/install.sh | bash
Notes
Device agent reports machine status to Jai Command Center.
Source code is maintained in a separate private repository.

---

# install.ps1

Abhi ZIP download karke extract karega.

```powershell
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
Write-Host "Files installed to:"
Write-Host $InstallDir
Write-Host ""
Write-Host "Installation complete."