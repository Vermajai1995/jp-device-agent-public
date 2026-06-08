# JP Device Agent Installer

Macbook Pro	curl -fsSL https://raw.githubusercontent.com/Vermajai1995/jp-device-agent-public/main/install.sh | DEVICE_ID=macbook-m2 DEVICE_NAME="MacBook Pro" bash
Mini PC	$env:DEVICE_ID="mini-pc"; $env:DEVICE_NAME="Mini PC"; irm https://raw.githubusercontent.com/Vermajai1995/jp-device-agent-public/main/install.ps1 | iex
Acer PC	$env:DEVICE_ID="acer-pc"; $env:DEVICE_NAME="Acer PC"; irm https://raw.githubusercontent.com/Vermajai1995/jp-device-agent-public/main/install.ps1 | iex

## Windows

Run PowerShell as Administrator:

```powershell
irm https://raw.githubusercontent.com/Vermajai1995/jp-device-agent-public/main/install.ps1 | iex
```

## macOS

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/Vermajai1995/jp-device-agent-public/main/install.sh | bash
```

The installer always downloads the latest release from the private JP Device Agent repository.
