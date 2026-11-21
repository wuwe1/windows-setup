# PowerShell profile, shared by 7 and Windows PowerShell 5.1 (Tern, the old console).
# Both $PROFILEs dot-source this file (stubs written by install.ps1).
# Needs: oh-my-posh, a Nerd Font; Terminal-Icons and PSReadLine 2.1+ where available.

# ===== Oh My Posh - Beautiful Prompt =====
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "gruvbox" | Invoke-Expression
}

# ===== Terminal Icons - File Icons in ls =====
if (Get-Module -ListAvailable Terminal-Icons) {
    Import-Module Terminal-Icons
}

# ===== PSReadLine - Smart Autocompletion =====
$ReadLine = Get-Module -ListAvailable PSReadLine | Sort-Object Version -Descending | Select-Object -First 1
if ($ReadLine.Version -ge [version]'2.1') {
    if ($Host.UI.SupportsVirtualTerminal) {
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle ListView
    }
}
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -BellStyle None
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# ===== Aliases =====
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name which -Value Get-Command
function yolo { claude --dangerously-skip-permissions @args }

# ===== Utility Functions =====
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }
function ~ { Set-Location $HOME }
