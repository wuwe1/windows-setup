#Requires AutoHotkey v2.0
#SingleInstance Force

; Mac-style key remapping for Windows
; $ prefix prevents hotkey from being triggered by Send commands

; --- Edit ---
$^w:: {
    Send "^{Backspace}"
}
!z:: {
    Send "^z"
}
!+z:: {
    Send "^y"
}
!x:: {
    Send "^x"
}
!c:: {
    Send "^c"
}
$!v:: {
    ; In Windows Terminal, pass real Alt+V through when clipboard has an image
    ; (Claude Code uses Alt+V to paste images; Ctrl+V only pastes text there)
    if WinActive("ahk_exe WindowsTerminal.exe") && DllCall("IsClipboardFormatAvailable", "UInt", 8)
        Send "!v"
    else
        Send "^v"
}
!a:: {
    Send "^a"
}
!s:: {
    Send "^s"
}
!f:: {
    Send "^f"
}

; --- Text navigation ---
!Left:: {
    Send "{Home}"
}
!Right:: {
    Send "{End}"
}
!Up:: {
    Send "^{Home}"
}
!Down:: {
    Send "^{End}"
}

; --- Browser/Window ---
!w:: {
    Send "^w"
}
!t:: {
    Send "^t"
}
!+t:: {
    Send "^+t"
}
!r:: {
    Send "^r"
}
!l:: {
    Send "^l"
}
!n:: {
    Send "^n"
}
!+n:: {
    Send "^+n"
}
!q:: {
    Send "!{F4}"
}

; --- Tab switching ---
!+[:: {
    Send "^+{Tab}"
}
!+]:: {
    Send "^{Tab}"
}

; --- Switch to tab 1-9 (Terminal uses Ctrl+Alt+N) ---
SwitchTab(n) {
    if WinActive("ahk_exe WindowsTerminal.exe")
        Send "^!{" n "}"
    else
        Send "^{" n "}"
}
!1:: SwitchTab("1")
!2:: SwitchTab("2")
!3:: SwitchTab("3")
!4:: SwitchTab("4")
!5:: SwitchTab("5")
!6:: SwitchTab("6")
!7:: SwitchTab("7")
!8:: SwitchTab("8")
!9:: SwitchTab("9")
