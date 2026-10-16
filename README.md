# windows-setup

New-machine bootstrap: Mac-style keys on Windows (Alt as Cmd) via AutoHotkey,
plus apps, PowerShell profile, Windows Terminal look and a few Explorer tweaks.

## Install on a new machine

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/wuwe1/windows-setup/main/install.ps1 | iex
```

Safe to re-run. In order, it:

1. Installs Git and puts this repo in `~\windows-setup`; sets `git config --global core.autocrlf input`.
2. Installs apps from `configuration.dsc.yaml` via `winget configure`
   (already-installed apps are left alone, not upgraded).
3. Installs the CaskaydiaCove NF Nerd Font with oh-my-posh.
4. Installs the Terminal-Icons module and makes PowerShell 7's `$PROFILE` a one-line stub
   that loads `powershell\profile.ps1` (an existing profile is kept as `.bak`).
5. Merges `terminal\appearance.json` into Windows Terminal's `settings.json`
   (only those keys; backup in `settings.json.bak`).
6. Runs `tweaks.ps1`: show file extensions and hidden files, no Start menu ads, full right-click menu, no Bing in search, no taskbar search box or Task View; then restarts Explorer.
   Turn off taskbar Widgets by hand (Settings > Personalization > Taskbar); Windows blocks scripts from changing it.
7. Registers `mac-keys.ahk` to start at login and starts it.
8. Copies `powertoys\settings\` into PowerToys (which modules are on, plus each module's settings;
   restarts PowerToys) and sets the Command Palette hotkey to Alt+Space (Spotlight position).

Mac-style keys apply only in Chrome/Edge, Windows Terminal and File Explorer windows.

## Apps

AutoHotkey, PowerToys, Everything, YASB, Twinkle Tray, EarTrumpet, Windhawk,
Git, GitHub CLI, PowerShell 7, Oh My Posh. Add or remove one in `configuration.dsc.yaml`.

## Editing

Edit files in `~\windows-setup`, then commit and push.

- `mac-keys.ahk`: double-click it to reload.
- `yasb\`: copy of `~\.config\yasb` (top status bar). Installed only if missing; after changing the live one, copy it back here.
- `powershell\profile.ps1`: open a new terminal tab.
- `powertoys\settings\`: change things in PowerToys Settings, then run `powertoys\save.ps1` to copy them here.
  `powertoys\apply.ps1` goes the other way (overwrites this machine's PowerToys settings).
  Mouse Without Borders is not saved (its security key is per machine).
- `terminal\appearance.json`, `tweaks.ps1`: re-run `install.ps1` (or just that script).

## Optional

- `oled.ps1`: for OLED monitors. Switches text from ClearType to grayscale (no colored fringes)
  and auto-hides the taskbar (burn-in). Not run by `install.ps1`; run it by hand, then restart apps or sign out.
