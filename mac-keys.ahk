#Requires AutoHotkey v2.0
#SingleInstance Force

; Mac-style Cmd keys, scoped to specific apps only.
; Alt sits where Cmd is on a Mac keyboard. Everywhere else, Alt is untouched.

GroupAdd "Browser", "ahk_exe chrome.exe"
GroupAdd "Browser", "ahk_exe msedge.exe"

; --- Browser: Alt+key -> Ctrl+key ---
#HotIf WinActive("ahk_group Browser")
!t::  Send "^t"      ; new tab
!+t:: Send "^+t"     ; reopen closed tab
!w::  Send "^w"      ; close tab
!n::  Send "^n"      ; new window
!+n:: Send "^+n"     ; new incognito window
!l::  Send "^l"      ; address bar
!r::  Send "^r"      ; reload
!f::  Send "^f"      ; find
!a::  Send "^a"
!c::  Send "^c"
!x::  Send "^x"
!v::  Send "^v"
!z::  Send "^z"
!+z:: Send "^+z"     ; redo
!+[:: Send "^+{Tab}" ; previous tab
!+]:: Send "^{Tab}"  ; next tab
!1::  Send "^1"
!2::  Send "^2"
!3::  Send "^3"
!4::  Send "^4"
!5::  Send "^5"
!6::  Send "^6"
!7::  Send "^7"
!8::  Send "^8"
!9::  Send "^9"

; --- Windows Terminal: Alt+key -> Terminal's own shortcuts ---
#HotIf WinActive("ahk_exe WindowsTerminal.exe")
!t:: Send "^+t"      ; new tab
!w:: Send "^+w"      ; close tab
!c:: Send "^+c"      ; copy selection
$!v:: {
    ; Image on clipboard: pass real Alt+V through (Claude Code pastes images with it)
    if DllCall("IsClipboardFormatAvailable", "UInt", 8)
        Send "!v"
    else
        Send "^+v"
}
!1:: Send "^!1"
!2:: Send "^!2"
!3:: Send "^!3"
!4:: Send "^!4"
!5:: Send "^!5"
!6:: Send "^!6"
!7:: Send "^!7"
!8:: Send "^!8"
!9:: Send "^!9"
#HotIf
