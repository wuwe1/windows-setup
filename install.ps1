# One-shot setup for a new Windows machine:
#   irm https://raw.githubusercontent.com/wuwe1/windows-setup/main/install.ps1 | iex
$ErrorActionPreference = 'Stop'

$Repo    = 'wuwe1/windows-setup'
$Dir     = Join-Path $HOME 'windows-setup'
$Script  = Join-Path $Dir 'mac-keys.ahk'

Write-Host '==> Installing AutoHotkey and PowerToys' -ForegroundColor Cyan
foreach ($id in 'AutoHotkey.AutoHotkey', 'Microsoft.PowerToys') {
    winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements
}

Write-Host "==> Fetching config into $Dir" -ForegroundColor Cyan
if (Get-Command git -ErrorAction SilentlyContinue) {
    if (Test-Path (Join-Path $Dir '.git')) { git -C $Dir pull --ff-only }
    else { git clone "https://github.com/$Repo.git" $Dir }
} else {
    New-Item -ItemType Directory -Force $Dir | Out-Null
    Invoke-WebRequest "https://raw.githubusercontent.com/$Repo/main/mac-keys.ahk" -OutFile $Script
}

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

Write-Host '==> Done. mac-keys is running.' -ForegroundColor Green
