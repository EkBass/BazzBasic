' ==========================================
' Gamepad graphics demo - BazzBasic v1.5
' Left stick or D-pad moves the ball, A changes color,
' RT makes it bigger, START = rumble. BACK or ESC quits.
' Public Domain
' ==========================================

[inits]
    LET SPEED# = 6
    LET x$ = 320
    LET y$ = 240
    LET c$ = RGB(255, 200, 0)
    LET aWas$ = FALSE

    SCREEN 0, 640, 480, "Gamepad demo"

[main]
    WHILE TRUE
        IF INKEY = KEY_ESC# OR PADBUTTON(0, PAD_BACK#) THEN GOTO [done]

        LET dx$ = PADAXIS(0, PAD_LX#)
        LET dy$ = PADAXIS(0, PAD_LY#)
        IF PADBUTTON(0, PAD_LEFT#)  THEN dx$ = -1
        IF PADBUTTON(0, PAD_RIGHT#) THEN dx$ = 1
        IF PADBUTTON(0, PAD_UP#)    THEN dy$ = -1
        IF PADBUTTON(0, PAD_DOWN#)  THEN dy$ = 1
        x$ = CLAMP(x$ + dx$ * SPEED#, 20, 619)
        y$ = CLAMP(y$ + dy$ * SPEED#, 20, 459)

        ' A: new color only on press, not every frame while held
        LET aNow$ = PADBUTTON(0, PAD_A#)
        IF aNow$ AND NOT aWas$ THEN c$ = RGB(RND(256), RND(256), RND(256))
        aWas$ = aNow$

        IF PADBUTTON(0, PAD_START#) THEN PADRUMBLE 0, 0.5, 100

        LET r$ = 20 + PADAXIS(0, PAD_RT#) * 40

        SCREENLOCK ON
        LINE (0,0)-(639,479), 0, BF
        CIRCLE (x$, y$), r$, c$, 1
        SCREENLOCK OFF
        SLEEP 16
    WEND

[done]
    END
