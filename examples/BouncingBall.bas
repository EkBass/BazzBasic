SCREEN 12, 640, 480, "Bouncing Ball"
CLS

DIM ball$
LET ball$ = LOADSHAPE("CIRCLE", 30, 30, RGB(255, 255, 0))

DIM x$
DIM y$
DIM dx$
DIM dy$

LET x$ = 320
LET y$ = 240
LET dx$ = 3
LET dy$ = 2

WHILE INKEY <> 27
        
    REM Update position
    LET x$ = x$ + dx$
    LET y$ = y$ + dy$
    
    REM Bounce off walls
    IF x$ <= 15 OR x$ >= 625 THEN
        LET dx$ = dx$ * -1
    ENDIF
    
    IF y$ <= 15 OR y$ >= 465 THEN
        LET dy$ = dy$ * -1
    ENDIF
    
    REM Draw
	SCREENLOCK ON
	
	' Filling screen with LINE... BF is actually faster than CLS which works better with console
    COLOR 0, 0
    LINE (0, 80)-(640, 480), 0, BF
	
    MOVESHAPE ball$, x$, y$
    DRAWSHAPE ball$
    
    COLOR 15, 0
    LOCATE 1, 1
    PRINT "Press ESC to exit"
    
    SCREENLOCK OFF
    SLEEP 16
WEND

REMOVESHAPE ball$
END
