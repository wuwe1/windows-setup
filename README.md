# windows-setup

Mac-style keys on Windows (Alt as Cmd) via AutoHotkey, plus PowerToys.

## Install on a new machine

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/wuwe1/windows-setup/main/install.ps1 | iex
```

This installs AutoHotkey + PowerToys (via winget), puts this repo in `~\windows-setup`,
registers `mac-keys.ahk` to start at login, and starts it.

## Editing

Edit `~\windows-setup\mac-keys.ahk`, double-click it to reload, then commit and push.
