' ============================================
' GRAPHICS SNIPPET 2: The Animation Loop Pattern
' SCREENLOCK, LINE...BF clearing instead of CLS, SLEEP framing,
' and why math/logic stays OUTSIDE the SCREENLOCK block.
' Self-contained - no external files needed.
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    SCREEN 12   ' 640x480

    LET SCREEN_W# = 640
    LET SCREEN_H# = 480
    LET RADIUS#   = 20
    LET BALL_COLOR# = RGB(90, 200, 255)

    LET ballX$ = 320
    LET ballY$ = 240
    LET velX$  = 4
    LET velY$  = 3

[main]
    ' VSYNC is ON by default as soon as SCREEN is called, which already
    ' caps this at roughly the monitor refresh rate. SLEEP 16 below is
    ' still worth keeping explicit: it's what makes the intended frame
    ' budget visible in the code, rather than relying only on VSYNC.
    WHILE INKEY <> KEY_ESC#
        ' --- 1. LOGIC: keep all math outside SCREENLOCK ---
        ballX$ = ballX$ + velX$
        ballY$ = ballY$ + velY$

        IF ballX$ - RADIUS# <= 0 THEN
            ballX$ = RADIUS#
            velX$ = velX$ * -1
        END IF
        IF ballX$ + RADIUS# >= SCREEN_W# THEN
            ballX$ = SCREEN_W# - RADIUS#
            velX$ = velX$ * -1
        END IF
        IF ballY$ - RADIUS# <= 0 THEN
            ballY$ = RADIUS#
            velY$ = velY$ * -1
        END IF
        IF ballY$ + RADIUS# >= SCREEN_H# THEN
            ballY$ = SCREEN_H# - RADIUS#
            velY$ = velY$ * -1
        END IF

        ' --- 2. DRAW: everything visual happens inside the lock ---
        SCREENLOCK ON
            LINE (0, 0)-(SCREEN_W#, SCREEN_H#), 0, BF
            CIRCLE (ballX$, ballY$), RADIUS#, BALL_COLOR#, 1
            DRAWSTRING "ESC to quit", 10, 10, RGB(255, 255, 255)
        SCREENLOCK OFF

        ' --- 3. PACE: hand time back so this doesn't spin the CPU ---
        SLEEP 16
    WEND
END
