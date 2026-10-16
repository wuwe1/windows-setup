# Save each installed Windhawk mod's settings into the repo (windhawk\mods\<mod-id>.json).
# Run after changing a mod in Windhawk, then commit.
$ErrorActionPreference = 'Stop'

$Mods = 'HKLM:\SOFTWARE\Windhawk\Engine\Mods'
$Repo = Join-Path $PSScriptRoot 'mods'

Remove-Item $Repo -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $Repo | Out-Null
foreach ($Mod in Get-ChildItem $Mods) {
    $Settings = [ordered]@{}
    $Key = Get-Item (Join-Path $Mod.PSPath 'Settings') -ErrorAction SilentlyContinue
    foreach ($Name in $Key.GetValueNames()) {
        $Settings[$Name] = [ordered]@{ type = "$($Key.GetValueKind($Name))"; value = $Key.GetValue($Name) }
    }
    $Out = [ordered]@{ disabled = [bool]$Mod.GetValue('Disabled'); settings = $Settings }
    $Out | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $Repo "$($Mod.PSChildName).json")
    Write-Host "  Saved $($Mod.PSChildName)"
}
