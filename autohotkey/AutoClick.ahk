#SingleInstance, Force

RControl::
    While(GetKeyState("RControl", "P")) {
        Click
        Sleep, 30 ; Adjust this value to control the click speed (in milliseconds)
    }
return
