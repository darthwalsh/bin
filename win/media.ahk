#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

#F7::Send {Media_Prev}
#F8::Send {Media_Play_Pause}
#F9::Send {Media_Next}
#F10::Send {Volume_Mute}
#F11::Send {Volume_Down 2}
#F12::Send {Volume_Up 2}
