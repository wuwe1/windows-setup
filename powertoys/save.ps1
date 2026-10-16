# Copy PowerToys settings from this machine into the repo (powertoys\settings\).
# Run after changing something in PowerToys Settings, then commit.
$ErrorActionPreference = 'Stop'

$Live = "$env:LOCALAPPDATA\Microsoft\PowerToys"
$Repo = Join-Path $PSScriptRoot 'settings'

# General settings (which modules are on) + each module's settings file.
# Skipped: logs, history, window positions, and Mouse Without Borders (per-machine security key).
$Files = @('settings.json') + (Get-ChildItem $Live -Directory |
    Where-Object Name -ne 'MouseWithoutBorders' |
    Get-ChildItem -File -Filter '*settings.json' |
    ForEach-Object { "$($_.Directory.Name)\$($_.Name)" })

Remove-Item $Repo -Recurse -Force -ErrorAction SilentlyContinue
foreach ($f in $Files) {
    $To = Join-Path $Repo $f
    New-Item -ItemType Directory -Force (Split-Path $To) | Out-Null
    Copy-Item (Join-Path $Live $f) $To
}
Write-Host "  Saved $($Files.Count) files to $Repo"
