# Small Windows tweaks. Current user only, no admin. Safe to re-run.
# Each block is one tweak; delete it to skip.
function Set-Reg($Path, $Name, $Value, $Type = 'DWord') {
    if (-not (Test-Path $Path)) { New-Item $Path -Force | Out-Null }
    Set-ItemProperty $Path $Name $Value -Type $Type
}
$Adv = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$Cdm = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'

# Show file extensions and hidden files
Set-Reg $Adv HideFileExt 0
Set-Reg $Adv Hidden 1

# Start menu: no promoted apps, tips or account nags (recent files stay)
Set-Reg $Adv Start_IrisRecommendations 0
Set-Reg $Adv Start_AccountNotifications 0
Set-Reg $Cdm SubscribedContent-338388Enabled 0
Set-Reg $Cdm SystemPaneSuggestionsEnabled 0
Set-Reg $Cdm SilentInstalledAppsEnabled 0

# Full (Windows 10 style) right-click menu, no "Show more options"
Set-Reg 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' '(Default)' '' String

# Windows search: no Bing web results
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' BingSearchEnabled 0

# Restart Explorer so the changes show up now (taskbar blinks, open folder windows close)
Stop-Process -Name explorer -Force
Start-Sleep 2
if (-not (Get-Process explorer -ErrorAction SilentlyContinue)) { Start-Process explorer }
