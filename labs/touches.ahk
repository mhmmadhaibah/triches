#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off
#NoTrayIcon

Persistent
desactive := false

#t::Trigger()

Insert::TSend("{Insert}")
Delete::TSend("{Delete}")

#x::ExitApp

Trigger()
{
    global desactive
    if (!desactive) {
        desactive := true
    } else {
        desactive := false
    }
}

TSend(key)
{
    global desactive
    if (!desactive) {
        Send(key)
    }
}
