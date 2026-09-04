' ==========================================
' Keydown_demo.bas — BazzBasic
' https://ekbass.github.io/BazzBasic/
' ==========================================
[inits]
    LET x$    = 320
    LET y$    = 240
    LET big$  = FALSE
    SCREEN 12

[main]
    WHILE INKEY <> KEY_ESC#

        ' --- LOGIC ---
        IF KEYDOWN(KEY_W#) THEN y$ = y$ - 2
        IF KEYDOWN(KEY_S#) THEN y$ = y$ + 2
        IF KEYDOWN(KEY_A#) THEN x$ = x$ - 2
        IF KEYDOWN(KEY_D#) THEN x$ = x$ + 2
        big$ = KEYDOWN(KEY_LSHIFT#)

        ' --- DRAW ---
        SCREENLOCK ON
            LINE (0,0)-(640,480), 0, BF
            IF big$ THEN
                CIRCLE (x$, y$), 20, RGB(255, 0, 0), 1
            ELSE
                CIRCLE (x$, y$), 10, RGB(0, 255, 0), 1
            END IF
            LOCATE 1, 1
            COLOR 15, 0
            PRINT "WASD=Move  SHIFT=Big  ESC=Quit"
            LOCATE 2, 1
            PRINT "X:"; x$; " Y:"; y$; "   "
        SCREENLOCK OFF

        SLEEP 16
    WEND
END