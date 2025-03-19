#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off
#NoTrayIcon

Persistent
Desactiver := false

~#t::
{
    global Desactiver
    Desactiver := !Desactiver
}

~#p::
{
    Sleep 5000
    SoundBeep(440, 200)

    FileDelete "C:\Windows\Prefetch\CMD.EXE-*.pf"
    FileDelete "C:\Windows\Prefetch\" A_ScriptName "-*.pf"
    FileDelete "C:\Windows\Prefetch\DISPLAYSWITCH.EXE-*.pf"
}

~#s::SoundBeep(440, 200)
~#q::ExitApp
~#x::ExitApp

#HotIf Desactiver
Insert::Return
Delete::Return
#HotIf
