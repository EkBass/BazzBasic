' Bouncing Ball — BazzBasic v1.1
' krisu.virtanen@gmail.com
' https://github.com/EkBass/BazzBasic

' ── 1. CONSTANTS ────────────────────────────
LET SCREEN_W#  = 640
LET SCREEN_H#  = 480
LET BALL_SIZE# = 30
LET BALL_COL#  = RGB(255, 255, 0)

' ── 2. INIT ─────────────────────────────────
[inits]
    SCREEN 0, SCREEN_W#, SCREEN_H#, "Bouncing Ball"

    LET BALL# = LOADSHAPE("CIRCLE", BALL_SIZE#, BALL_SIZE#, BALL_COL#)

    LET x$       = 320
    LET y$       = 240
    LET dx$      = 3
    LET dy$      = 2
    LET running$ = TRUE

' ── 3. MAIN LOOP ────────────────────────────
[main]
    WHILE running$
        IF INKEY = KEY_ESC# THEN running$ = FALSE
        GOSUB [sub:update]
        GOSUB [sub:draw]
        SLEEP 16
    WEND
    REMOVESHAPE BALL#
END

' ── 4. SUBROUTINES ──────────────────────────
[sub:update]
    x$ = x$ + dx$
    y$ = y$ + dy$

    IF x$ <= 0 OR x$ >= SCREEN_W# - BALL_SIZE# THEN
        dx$ = dx$ * -1
    ENDIF

    IF y$ <= 0 OR y$ >= SCREEN_H# - BALL_SIZE# THEN
        dy$ = dy$ * -1
    ENDIF
RETURN

[sub:draw]
    SCREENLOCK ON
    LINE (0,0)-(SCREEN_W#, SCREEN_H#), 0, BF
    MOVESHAPE BALL#, x$, y$
    DRAWSHAPE BALL#
    COLOR 15, 0
    LOCATE 1, 1
    PRINT "Press ESC to exit"
    SCREENLOCK OFF
RETURN