# Merge appearance.json into Windows Terminal's settings.json (PowerShell 7).
# Only the keys in appearance.json are set; everything else is kept. Safe to re-run.
$ErrorActionPreference = 'Stop'

$Settings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$Want = Get-Content (Join-Path $PSScriptRoot 'appearance.json') -Raw | ConvertFrom-Json -AsHashtable

# No settings.json yet (Terminal never opened): start from an empty one, Terminal fills in the rest
$Old = if (Test-Path $Settings) { Get-Content $Settings -Raw } else { '{}' }
$Json = $Old | ConvertFrom-Json -AsHashtable

# Top-level settings (defaultProfile = PowerShell 7, whose GUID is the same on every machine)
foreach ($k in $Want.global.Keys) { $Json[$k] = $Want.global[$k] }

# Color schemes: add, or replace one with the same name
$Schemes = [System.Collections.ArrayList]@($Json.schemes | Where-Object { $_ })
foreach ($s in $Want.schemes) {
    $Schemes = [System.Collections.ArrayList]@($Schemes | Where-Object { $_.name -ne $s.name })
    [void]$Schemes.Add($s)
}
$Json.schemes = @($Schemes)

if (-not $Json.profiles) { $Json.profiles = [ordered]@{} }
if (-not $Json.profiles.defaults) { $Json.profiles.defaults = [ordered]@{} }
foreach ($k in $Want.defaults.Keys) { $Json.profiles.defaults[$k] = $Want.defaults[$k] }

# Per-profile settings, matched by name (only profiles already listed, e.g. once WSL Ubuntu exists)
foreach ($name in $Want.profiles.Keys) {
    $Matched = @($Json.profiles.list | Where-Object { $_.name -eq $name })
    if (-not $Matched) { Write-Host "  Terminal profile '$name' not found yet; re-run later." }
    foreach ($p in $Matched) {
        # null = drop the override so the profile follows defaults
        foreach ($k in $Want.profiles[$name].Keys) {
            if ($null -eq $Want.profiles[$name][$k]) { $p.Remove($k) } else { $p[$k] = $Want.profiles[$name][$k] }
        }
    }
}

$New = $Json | ConvertTo-Json -Depth 32
if ($New -ne $Old.Trim()) {
    if (Test-Path $Settings) { Copy-Item $Settings "$Settings.bak" -Force }
    else { New-Item -ItemType Directory -Force (Split-Path $Settings) | Out-Null }
    Set-Content $Settings $New
    Write-Host "  Updated $Settings"
}
