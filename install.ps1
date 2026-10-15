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
Write-Host '==> Done. mac-keys is running.' -ForegroundColor Green
