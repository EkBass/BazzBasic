REM KEYDOWN Test
SCREEN 12

LET x$ = 320
LET y$ = 240

WHILE INKEY <> KEY_ESC#
    SCREENLOCK ON
    LINE (0,0)-(640,480), 0, BF
    
    IF KEYDOWN(KEY_W#) THEN y$ = y$ - 2
    IF KEYDOWN(KEY_S#) THEN y$ = y$ + 2
    IF KEYDOWN(KEY_A#) THEN x$ = x$ - 2
    IF KEYDOWN(KEY_D#) THEN x$ = x$ + 2
    
    IF KEYDOWN(KEY_LSHIFT#) THEN
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