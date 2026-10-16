# Optional, for OLED monitors (WOLED / QD-OLED): grayscale text instead of ClearType,
# which assumes an RGB-stripe LCD and leaves colored fringes on OLED subpixel layouts.
# Not run by install.ps1. Run by hand, then restart apps (or sign out).
# Undo: search "Adjust ClearType text" and turn ClearType back on.

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
