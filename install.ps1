# One-shot setup for a new Windows machine:
#   irm https://raw.githubusercontent.com/wuwe1/windows-setup/main/install.ps1 | iex
# Safe to re-run. Works from Windows PowerShell 5.1 or PowerShell 7.
$ErrorActionPreference = 'Stop'

$Repo    = 'wuwe1/windows-setup'
$Dir     = Join-Path $HOME 'windows-setup'
$Script  = Join-Path $Dir 'mac-keys.ahk'

# Pick up PATH changes made by installers in this session
function Update-Path {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

Write-Host '==> Installing Git' -ForegroundColor Cyan
winget install --id Git.Git -e --silent --no-upgrade --accept-package-agreements --accept-source-agreements
Update-Path

Write-Host "==> Fetching config into $Dir" -ForegroundColor Cyan
if (Test-Path (Join-Path $Dir '.git')) { git -C $Dir pull --ff-only }
else { git clone "https://github.com/$Repo.git" $Dir }
git config --global core.autocrlf input

Write-Host '==> Installing apps (configuration.dsc.yaml)' -ForegroundColor Cyan
winget configure -f (Join-Path $Dir 'configuration.dsc.yaml') --accept-configuration-agreements
Update-Path
$Pwsh = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
if (-not $Pwsh) { throw 'pwsh not found after install' }

Write-Host '==> Installing Nerd Fonts' -ForegroundColor Cyan
$Fonts = 'HKCU:', 'HKLM:' | ForEach-Object {
    (Get-ItemProperty "$_\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue).PSObject.Properties.Name
}
# oh-my-posh font name = Windows font family it installs
foreach ($f in @{ CascadiaCode = 'CaskaydiaCove NF' }.GetEnumerator()) {
    if (-not ($Fonts -like "$($f.Value) Regular*")) { oh-my-posh font install $f.Key --headless }
}

Write-Host '==> Setting up PowerShell 7 profile' -ForegroundColor Cyan
& $Pwsh -NoProfile -Command 'if (-not (Get-Module -ListAvailable Terminal-Icons)) { Install-Module Terminal-Icons -Scope CurrentUser -Force }'
# $PROFILE becomes a one-line stub that loads the repo's profile
$Profile7 = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Microsoft.PowerShell_profile.ps1'
$Stub = '. "$HOME\windows-setup\powershell\profile.ps1"'
if (-not ((Test-Path $Profile7) -and (Get-Content $Profile7 -Raw) -like "*$Stub*")) {
    if (Test-Path $Profile7) {
        Move-Item $Profile7 "$Profile7.bak" -Force
        Write-Warning "Old profile saved as $Profile7.bak"
    }
    New-Item -ItemType File -Force $Profile7 -Value "$Stub`n" | Out-Null
}

Write-Host '==> Applying Windows Terminal appearance' -ForegroundColor Cyan
& $Pwsh -NoProfile -File (Join-Path $Dir 'terminal\apply.ps1')

Write-Host '==> YASB status bar config' -ForegroundColor Cyan
# Copy only if missing, so local tweaks on this machine are never overwritten
$YasbDir = Join-Path $HOME '.config\yasb'
New-Item -ItemType Directory -Force $YasbDir | Out-Null
foreach ($f in 'config.yaml', 'styles.css') {
    $To = Join-Path $YasbDir $f
    if (-not (Test-Path $To)) { Copy-Item (Join-Path $Dir "yasb\$f") $To }
}

Write-Host '==> Applying Windows tweaks (tweaks.ps1)' -ForegroundColor Cyan
& $Pwsh -NoProfile -File (Join-Path $Dir 'tweaks.ps1')

$Ahk = @(
    "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe",
    "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $Ahk) { throw 'AutoHotkey64.exe not found after install' }

Write-Host '==> Registering mac-keys to run at login' -ForegroundColor Cyan
$Lnk = (New-Object -ComObject WScript.Shell).CreateShortcut(
    (Join-Path ([Environment]::GetFolderPath('Startup')) 'mac-keys.lnk'))
$Lnk.TargetPath = $Ahk
$Lnk.Arguments  = "`"$Script`""
$Lnk.Save()

Start-Process $Ahk -ArgumentList "`"$Script`""

Write-Host '==> Applying PowerToys settings (powertoys\settings)' -ForegroundColor Cyan
& $Pwsh -NoProfile -File (Join-Path $Dir 'powertoys\apply.ps1')

Write-Host '==> Setting Command Palette hotkey to Alt+Space' -ForegroundColor Cyan
# Settings file only appears after Command Palette's first run, so start PowerToys and wait for it
$CmdPalSettings = "$env:LOCALAPPDATA\Packages\Microsoft.CommandPalette_8wekyb3d8bbwe\LocalState\settings.json"
$PowerToys = "$env:LOCALAPPDATA\PowerToys\PowerToys.exe"
if (-not (Get-Process PowerToys -ErrorAction SilentlyContinue) -and (Test-Path $PowerToys)) { Start-Process $PowerToys }
for ($i = 0; $i -lt 60 -and -not (Test-Path $CmdPalSettings); $i++) { Start-Sleep 1 }
if (Test-Path $CmdPalSettings) {
    $CmdPal = Get-Process Microsoft.CmdPal.UI -ErrorAction SilentlyContinue
    $CmdPalExe = $CmdPal.Path | Select-Object -First 1
    $CmdPal | Stop-Process -Force
    Start-Sleep 1
    $Json = Get-Content $CmdPalSettings -Raw
    $Json = $Json -replace '(?s)("Hotkey":\s*\{\s*"win":\s*)true', '${1}false'
    [IO.File]::WriteAllText($CmdPalSettings, $Json)
    if ($CmdPalExe) { Start-Process $CmdPalExe }
} else {
    Write-Warning 'Command Palette settings not found; set Alt+Space manually in its settings.'
}

Write-Host '==> Done. mac-keys is running; open a new Windows Terminal tab to see the prompt.' -ForegroundColor Green
