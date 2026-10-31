' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Console gamepad test that prints the name of pad 0 and lists the buttons held and the stick and trigger values, with START triggering rumble.
' CATEGORY: input
' TAGS: gamepad, padbutton, padaxis, rumble, padname
' MINVERSION: 1.5
' ============================================
REM Press buttons / move sticks. START = rumble, BACK = quit.
REM Runs max 30 seconds.

PRINT "Gamepads connected: "; GAMEPADS()
IF GAMEPADS() > 0 THEN PRINT "Pad 0: "; PADNAME(0)
PRINT "Waiting for input... (BACK quits)"

LET start$ = TICKS
WHILE TICKS - start$ < 30000
    IF PADBUTTON(0, PAD_BACK#) THEN GOTO [done]

    LET line$ = ""
    IF PADBUTTON(0, PAD_A#) THEN line$ += "A "
    IF PADBUTTON(0, PAD_B#) THEN line$ += "B "
    IF PADBUTTON(0, PAD_X#) THEN line$ += "X "
    IF PADBUTTON(0, PAD_Y#) THEN line$ += "Y "
    IF PADBUTTON(0, PAD_UP#) THEN line$ += "UP "
    IF PADBUTTON(0, PAD_DOWN#) THEN line$ += "DOWN "
    IF PADBUTTON(0, PAD_LEFT#) THEN line$ += "LEFT "
    IF PADBUTTON(0, PAD_RIGHT#) THEN line$ += "RIGHT "
    IF PADBUTTON(0, PAD_LB#) THEN line$ += "LB "
    IF PADBUTTON(0, PAD_RB#) THEN line$ += "RB "
    IF PADBUTTON(0, PAD_LSTICK#) THEN line$ += "LSTICK "
    IF PADBUTTON(0, PAD_RSTICK#) THEN line$ += "RSTICK "
    IF PADBUTTON(0, PAD_GUIDE#) THEN line$ += "GUIDE "
    IF PADBUTTON(0, PAD_MISC#) THEN line$ += "MISC "
    IF PADBUTTON(0, PAD_TOUCHPAD#) THEN line$ += "TOUCHPAD "
    IF PADBUTTON(0, PAD_START#) THEN
        line$ += "START(rumble) "
        PADRUMBLE 0, 0.6, 200
    ENDIF

    LET lx$ = PADAXIS(0, PAD_LX#)
    LET ly$ = PADAXIS(0, PAD_LY#)
    LET rx$ = PADAXIS(0, PAD_RX#)
    LET ry$ = PADAXIS(0, PAD_RY#)
    LET lt$ = PADAXIS(0, PAD_LT#)
    LET rt$ = PADAXIS(0, PAD_RT#)
    IF lx$ <> 0 OR ly$ <> 0 THEN line$ += "LX=" + STR(ROUND(lx$ * 100) / 100) + " LY=" + STR(ROUND(ly$ * 100) / 100) + " "
    IF rx$ <> 0 OR ry$ <> 0 THEN line$ += "RX=" + STR(ROUND(rx$ * 100) / 100) + " RY=" + STR(ROUND(ry$ * 100) / 100) + " "
    IF lt$ > 0 THEN line$ += "LT=" + STR(ROUND(lt$ * 100) / 100) + " "
    IF rt$ > 0 THEN line$ += "RT=" + STR(ROUND(rt$ * 100) / 100)

    IF line$ <> "" THEN PRINT line$
    SLEEP 100
WEND

[done]
PRINT "Done!"
END
