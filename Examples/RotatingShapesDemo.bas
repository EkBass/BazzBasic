' BazzBasic; Rotating shapes demo
' https://github.com/EkBass/BazzBasic


SCREEN 12, 640, 480, "Rotating Shapes Demo"
CLS

REM Create shapes
DIM square$
DIM circle$
DIM triangle$

LET square$ = LOADSHAPE("RECTANGLE", 60, 60, RGB(255, 0, 0))
LET circle$ = LOADSHAPE("CIRCLE", 60, 60, RGB(0, 255, 0))
LET triangle$ = LOADSHAPE("TRIANGLE", 60, 60, RGB(0, 0, 255))

MOVESHAPE square$, 160, 240
MOVESHAPE circle$, 320, 240
MOVESHAPE triangle$, 480, 240

DIM angle$
LET angle$ = 0

WHILE INKEY <> 27
        
    LET angle$ = angle$ + 2
    IF angle$ >= 360 THEN
        LET angle$ = 0
    ENDIF
    
    ROTATESHAPE square$, angle$
    ROTATESHAPE circle$, angle$ * 0.5
    ROTATESHAPE triangle$, angle$ * -1
    
	SCREENLOCK ON
	
	' Filling screen with LINE... BF is actually faster than CLS which works better with console
    COLOR 0, 0
    LINE (0, 80)-(640, 480), 0, BF
	
	' Draw the shapes
    DRAWSHAPE square$
    DRAWSHAPE circle$
    DRAWSHAPE triangle$
    
    COLOR 15, 0
    LOCATE 1, 1
    PRINT "Angle: "; angle$; "   "
    PRINT "Press ESC to exit"
    SCREENLOCK OFF
	
    SLEEP 16
WEND

REMOVESHAPE square$
REMOVESHAPE circle$
REMOVESHAPE triangle$
END
