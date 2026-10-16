# Optional, for OLED monitors (WOLED / QD-OLED). 1) Grayscale text instead of ClearType,
# which assumes an RGB-stripe LCD and leaves colored fringes on OLED subpixel layouts.
# Not run by install.ps1. Run by hand, then restart apps (or sign out).
# 2) Taskbar auto-hide.
# Undo: "Adjust ClearType text" > turn ClearType on; Settings > Taskbar > untick auto-hide.

Add-Type -Namespace W -Name Spi -MemberDefinition '[DllImport("user32.dll")] public static extern bool SystemParametersInfo(uint a, uint b, System.IntPtr c, uint d);'
[void][W.Spi]::SystemParametersInfo(0x004B, 1, [IntPtr]::Zero, 3)  # SPI_SETFONTSMOOTHING: on
[void][W.Spi]::SystemParametersInfo(0x200B, 0, [IntPtr]1, 3)        # SPI_SETFONTSMOOTHINGTYPE: standard (grayscale)

# DirectWrite apps (Chrome, Edge, Electron) read per-display ClearType settings
Add-Type -AssemblyName System.Windows.Forms
foreach ($s in [System.Windows.Forms.Screen]::AllScreens) {
    $k = 'HKCU:\Software\Microsoft\Avalon.Graphics\' + ($s.DeviceName -replace '^\\\\\.\\', '')
    New-Item $k -Force | Out-Null
    Set-ItemProperty $k ClearTypeLevel 0 -Type DWord
    Set-ItemProperty $k PixelStructure 0 -Type DWord
}
Write-Host 'Grayscale text on. Restart apps (chrome://restart) or sign out to apply everywhere.'

# Auto-hide the taskbar: it's the most static thing on screen (burn-in risk)
Add-Type -Namespace W -Name AppBar -MemberDefinition @'
[StructLayout(LayoutKind.Sequential)] public struct APPBARDATA { public uint cbSize; public System.IntPtr hWnd; public uint uCallbackMessage; public uint uEdge; public int l, t, r, b; public System.IntPtr lParam; }
[DllImport("shell32.dll")] public static extern System.UIntPtr SHAppBarMessage(uint msg, ref APPBARDATA d);
[DllImport("user32.dll")] public static extern System.IntPtr FindWindow(string c, string w);
'@
$Bar = New-Object W.AppBar+APPBARDATA
$Bar.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($Bar)
$Bar.hWnd   = [W.AppBar]::FindWindow('Shell_TrayWnd', $null)
$Bar.lParam = [IntPtr]1  # ABS_AUTOHIDE
[void][W.AppBar]::SHAppBarMessage(0xA, [ref]$Bar)  # ABM_SETSTATE
Write-Host 'Taskbar auto-hide on.'
