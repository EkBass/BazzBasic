' ============================================
' Analog Clock (300x300)
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    ' --- Window & dial geometry ---
    LET SCREEN_W#    = 300
    LET SCREEN_H#    = 300
    LET CX#          = 150          ' dial center
    LET CY#          = 150
    LET RADIUS#      = 140          ' outer edge of the rim
    LET RIM_W#       = 4            ' rim thickness
    LET TICK_OUTER#  = 128          ' ticks run inward from here
    LET TICK_MAJOR#  = 114          ' inner end of 5-minute ticks
    LET TICK_MINOR#  = 121          ' inner end of 1-minute ticks
    LET NUM_RADIUS#  = 100          ' where numerals are centered

    ' --- Hands: length, tail behind center, half-width ---
    LET HOUR_LEN#    = 65
    LET HOUR_TAIL#   = 10
    LET HOUR_HALF_W# = 2.5
    LET MIN_LEN#     = 100
    LET MIN_TAIL#    = 10
    LET MIN_HALF_W#  = 1.5
    LET SEC_LEN#     = 115
    LET SEC_TAIL#    = 22
    LET SEC_HALF_W#  = 0
    LET HUB_R#       = 5

    SCREEN 0, SCREEN_W#, SCREEN_H#, "BazzBasic Clock"

    ' --- Colors (computed once, never inside the loop) ---
    LET COL_BG#         = RGB(40, 40, 50)
    LET COL_RIM#        = RGB(90, 90, 100)
    LET COL_FACE#       = RGB(240, 238, 228)
    LET COL_TICK_MAJOR# = RGB(30, 30, 30)
    LET COL_TICK_MINOR# = RGB(150, 150, 150)
    LET COL_NUM#        = RGB(30, 30, 30)
    LET COL_HOUR#       = RGB(20, 20, 20)
    LET COL_MIN#        = RGB(50, 50, 50)
    LET COL_SEC#        = RGB(200, 30, 30)

    ' --- Time state ---
    LET timeNow$   = ""
    LET lastTime$  = ""
    LET hours$     = 0
    LET minutes$   = 0
    LET seconds$   = 0
    LET hourAngle$ = 0
    LET minAngle$  = 0
    LET secAngle$  = 0

    ' --- Working variables for [sub:drawFace] ---
    LET ang$     = 0
    LET inner$   = 0
    LET tickCol$ = 0
    LET nx$      = 0
    LET ny$      = 0
    LET label$   = ""

    ' --- "Parameters" and working variables for [sub:drawHand] ---
    LET handAngle$ = 0
    LET handLen$   = 0
    LET handTail$  = 0
    LET handHalfW$ = 0
    LET handColor$ = 0
    LET dx$ = 0
    LET dy$ = 0
    LET px$ = 0
    LET py$ = 0

[main]
    WHILE INKEY <> KEY_ESC#
        timeNow$ = TIME()                   ' "HH:mm:ss", read ONCE per pass
        IF timeNow$ <> lastTime$ THEN       ' redraw only when the second changes
            lastTime$ = timeNow$
            GOSUB [sub:readTime]
            GOSUB [sub:drawClock]
        END IF
        SLEEP 50                            ' poll 20x/sec: tick appears promptly
    WEND
END

' --------------------------------------------
' Split "HH:mm:ss" and convert to hand angles.
' Angles are in degrees, clockwise from 12.
' --------------------------------------------
[sub:readTime]
    hours$   = VAL(LEFT(timeNow$, 2))
    minutes$ = VAL(MID(timeNow$, 4, 2))
    seconds$ = VAL(RIGHT(timeNow$, 2))

    secAngle$  = seconds$ * 6                           ' 360 / 60
    minAngle$  = minutes$ * 6 + seconds$ * 0.1          ' creeps every second
    hourAngle$ = MOD(hours$, 12) * 30 + minutes$ * 0.5  ' 360 / 12, creeps every minute
RETURN

' --------------------------------------------
' Draw one complete frame
' --------------------------------------------
[sub:drawClock]
    SCREENLOCK ON
    LINE (0, 0)-(SCREEN_W#, SCREEN_H#), COL_BG#, BF
    GOSUB [sub:drawFace]

    handAngle$ = hourAngle$
    handLen$   = HOUR_LEN#
    handTail$  = HOUR_TAIL#
    handHalfW$ = HOUR_HALF_W#
    handColor$ = COL_HOUR#
    GOSUB [sub:drawHand]

    handAngle$ = minAngle$
    handLen$   = MIN_LEN#
    handTail$  = MIN_TAIL#
    handHalfW$ = MIN_HALF_W#
    handColor$ = COL_MIN#
    GOSUB [sub:drawHand]

    handAngle$ = secAngle$
    handLen$   = SEC_LEN#
    handTail$  = SEC_TAIL#
    handHalfW$ = SEC_HALF_W#
    handColor$ = COL_SEC#
    GOSUB [sub:drawHand]

    CIRCLE (CX#, CY#), HUB_R#, COL_SEC#, 1
    SCREENLOCK OFF
RETURN

' --------------------------------------------
' Rim, face, 60 ticks and the numerals 1..12
' --------------------------------------------
[sub:drawFace]
    CIRCLE (CX#, CY#), RADIUS#, COL_RIM#, 1
    CIRCLE (CX#, CY#), RADIUS# - RIM_W#, COL_FACE#, 1

    FOR tick$ = 0 TO 59
        ang$ = RAD(tick$ * 6)
        IF MOD(tick$, 5) = 0 THEN
            inner$   = TICK_MAJOR#
            tickCol$ = COL_TICK_MAJOR#
        ELSE
            inner$   = TICK_MINOR#
            tickCol$ = COL_TICK_MINOR#
        END IF
        LINE (CX# + SIN(ang$) * inner$,      CY# - COS(ang$) * inner$)-
             (CX# + SIN(ang$) * TICK_OUTER#, CY# - COS(ang$) * TICK_OUTER#), tickCol$
    NEXT

    FOR num$ = 1 TO 12
        ang$   = RAD(num$ * 30)
        nx$    = CX# + SIN(ang$) * NUM_RADIUS#
        ny$    = CY# - COS(ang$) * NUM_RADIUS#
        label$ = STR(num$)
        ' DRAWSTRING anchors at top-left; shift by an estimated half text size
        ' (default Arial 16px: ~9 px per digit, ~18 px tall). Approximate centering.
        DRAWSTRING label$, nx$ - LEN(label$) * 4.5, ny$ - 9, COL_NUM#
    NEXT
RETURN

' --------------------------------------------
' Draw one hand. Inputs (shared GOSUB scope):
'   handAngle$, handLen$, handTail$, handHalfW$, handColor$
' Thickness = several parallel 1px lines offset
' along the perpendicular, every 0.5 px.
' --------------------------------------------
[sub:drawHand]
    dx$ = SIN(RAD(handAngle$))      ' unit vector toward the hand's tip
    dy$ = -COS(RAD(handAngle$))     ' (screen Y grows downward)
    px$ = -dy$                      ' perpendicular unit vector
    py$ = dx$
    FOR off$ = -handHalfW$ TO handHalfW$ STEP 0.5
        LINE (CX# - dx$ * handTail$ + px$ * off$, CY# - dy$ * handTail$ + py$ * off$)-
             (CX# + dx$ * handLen$  + px$ * off$, CY# + dy$ * handLen$  + py$ * off$), handColor$
    NEXT
RETURN

' Output:
' A 300x300 window titled "BazzBasic Clock" shows a cream clock face with a grey rim,
' 60 tick marks (longer and darker every 5 minutes) and numerals 1-12.
' Black hour and minute hands and a red second hand show the current system time.
' The second hand ticks once per second. ESC closes the program.