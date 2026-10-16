# Copy the repo's PowerToys settings (powertoys\settings\) onto this machine.
# Overwrites those files; run save.ps1 first if you changed PowerToys here and want to keep it.
$ErrorActionPreference = 'Stop'

$Live = "$env:LOCALAPPDATA\Microsoft\PowerToys"
$Repo = Join-Path $PSScriptRoot 'settings'
$Exe  = "$env:LOCALAPPDATA\PowerToys\PowerToys.exe"

# PowerToys rewrites its settings on exit, so stop it before copying
Get-Process PowerToys* -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 2

Get-ChildItem $Repo -Recurse -File | ForEach-Object {
    $To = Join-Path $Live $_.FullName.Substring($Repo.Length + 1)
    New-Item -ItemType Directory -Force (Split-Path $To) | Out-Null
    Copy-Item $_.FullName $To -Force
}

if (Test-Path $Exe) { Start-Process $Exe }
Write-Host "  Applied PowerToys settings to $Live"
