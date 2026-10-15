# PowerShell 7 profile. $PROFILE dot-sources this file (stub written by install.ps1).
# Needs: oh-my-posh, Terminal-Icons module, a Nerd Font.

# ===== Oh My Posh - Beautiful Prompt =====
oh-my-posh init pwsh --config "gruvbox" | Invoke-Expression

# ===== Terminal Icons - File Icons in ls =====
Import-Module Terminal-Icons

# ===== PSReadLine - Smart Autocompletion =====
if ($Host.UI.SupportsVirtualTerminal) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
}
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# ===== Aliases =====
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name which -Value Get-Command

# ===== Utility Functions =====
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }
function ~ { Set-Location $HOME }
