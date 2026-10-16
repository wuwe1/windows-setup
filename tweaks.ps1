# Small Windows tweaks. Current user; one UAC prompt for the few that need admin. Safe to re-run.
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

# Taskbar: hide search box and Task View button (Widgets can only be turned off by hand in Settings)
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' SearchboxTaskbarMode 0
Set-Reg $Adv ShowTaskViewButton 0

# Policy keys and HKLM need admin: Set-AdminReg queues them, and one UAC prompt at the end
# writes whatever isn't set yet (none on a re-run once applied)
$AdminRegs = [Collections.Generic.List[string]]::new()
function Set-AdminReg($Path, $Name, $Value) {
    if ((Get-ItemProperty $Path -ErrorAction SilentlyContinue).$Name -ne $Value) {
        $AdminRegs.Add("reg add `"$($Path -replace ':', '')`" /v $Name /t REG_DWORD /d $Value /f")
    }
}

# Copilot and Recall: no taskbar button, no Copilot app, no Recall snapshots
Set-Reg $Adv ShowCopilotButton 0
Set-AdminReg 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot' TurnOffWindowsCopilot 1
Set-AdminReg 'HKCU:\Software\Policies\Microsoft\Windows\WindowsAI' DisableAIDataAnalysis 1
Get-AppxPackage Microsoft.Copilot | Remove-AppxPackage

# Windows search: no "search highlights" (doodles and trending searches)
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings' IsDynamicSearchBoxEnabled 0

# Lock screen fun facts, Windows tips, suggestions in Settings, "finish setting up your PC" nags
Set-Reg $Cdm RotatingLockScreenOverlayEnabled 0
Set-Reg $Cdm SubscribedContent-338387Enabled 0
Set-Reg $Cdm SubscribedContent-338389Enabled 0
Set-Reg $Cdm SubscribedContent-310093Enabled 0
Set-Reg $Cdm SubscribedContent-338393Enabled 0
Set-Reg $Cdm SubscribedContent-353694Enabled 0
Set-Reg $Cdm SubscribedContent-353696Enabled 0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement' ScoobeSystemSettingEnabled 0

# Edge: no first-run pages, recommendations, shopping, Copilot sidebar, Rewards or default-browser nags
# (Edge then shows "managed by your organization"; that's these policies)
$Edge = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
Set-AdminReg $Edge HideFirstRunExperience 1
Set-AdminReg $Edge ShowRecommendationsEnabled 0
Set-AdminReg $Edge SpotlightExperiencesAndRecommendationsEnabled 0
Set-AdminReg $Edge EdgeShoppingAssistantEnabled 0
Set-AdminReg $Edge HubsSidebarEnabled 0
Set-AdminReg $Edge ShowMicrosoftRewards 0
Set-AdminReg $Edge DefaultBrowserSettingsCampaignEnabled 0

# File Explorer like Finder: open to This PC, no Home or Gallery in the sidebar, no recent/frequent files
Set-Reg $Adv LaunchTo 1
Set-Reg 'HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}' System.IsPinnedToNameSpaceTree 0
Set-Reg 'HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}' System.IsPinnedToNameSpaceTree 0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' ShowRecent 0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' ShowFrequent 0

# Fast Startup off, so Shut down really shuts down
Set-AdminReg 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' HiberbootEnabled 0

if ($AdminRegs.Count) {
    $Cmd = Join-Path $env:TEMP 'windows-setup-admin.cmd'
    Set-Content $Cmd ($AdminRegs -join "`r`n") -Encoding ascii
    Start-Process cmd -Verb RunAs -Wait -WindowStyle Hidden -ArgumentList '/c', "`"$Cmd`""
    Remove-Item $Cmd
}

# Restart Explorer so the changes show up now (taskbar blinks, open folder windows close)
Stop-Process -Name explorer -Force
Start-Sleep 2
if (-not (Get-Process explorer -ErrorAction SilentlyContinue)) { Start-Process explorer }
