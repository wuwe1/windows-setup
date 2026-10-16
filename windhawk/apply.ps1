# Write the repo's Windhawk mod settings (windhawk\mods\*.json) onto this machine.
# Windhawk 1.7 can't install mods from a script: install each mod in Windhawk first
# (Explore > search the file name), then run this. Asks for admin (settings live in HKLM).
$ErrorActionPreference = 'Stop'

$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).
    IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    $Shell = (Get-Process -Id $PID).Path
    Start-Process $Shell -Verb RunAs -Wait -ArgumentList '-NoProfile', '-File', "`"$PSCommandPath`""
    return
}

$Mods = 'HKLM:\SOFTWARE\Windhawk\Engine\Mods'
foreach ($File in Get-ChildItem (Join-Path $PSScriptRoot 'mods') -Filter *.json) {
    $Id  = $File.BaseName
    $Key = Join-Path $Mods $Id
    if (-not (Test-Path $Key)) { Write-Warning "$Id is not installed; install it in Windhawk, then re-run."; continue }

    $Want = Get-Content $File.FullName -Raw | ConvertFrom-Json
    New-Item (Join-Path $Key 'Settings') -Force | Out-Null   # -Force on an existing key clears its values
    foreach ($p in $Want.settings.PSObject.Properties) {
        New-ItemProperty (Join-Path $Key 'Settings') $p.Name -PropertyType $p.Value.type -Value $p.Value.value | Out-Null
    }
    Set-ItemProperty $Key Disabled ([int]$Want.disabled) -Type DWord
    # Bumping this makes running mods reload their settings
    Set-ItemProperty $Key SettingsChangeTime ([int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()) -Type DWord
    Write-Host "  Applied $Id"
}
