REM ============================================
REM Test: PNG with Alpha transparency
REM ============================================

SCREEN 0, 640, 480, "PNG Alpha Test"

REM Draw a colorful background first
LINE (0, 0)-(320, 480), RGB(255, 0, 0), BF
LINE (320, 0)-(640, 480), RGB(0, 255, 0), BF

REM Load PNG image (use icon.png from project root)
DIM img$
img$ = LOADIMAGE("icon.png")

IF img$ = "" THEN
    LOCATE 10, 10
    PRINT "Failed to load PNG!"
    SLEEP 3000
    END
ENDIF

REM Move and draw the image - alpha should blend with background
MOVESHAPE img$, 320, 240
DRAWSHAPE img$

SLEEP 2000

REM Move around to show transparency
DIM i#
FOR i# = 0 TO 360 STEP 15
    DIM x#
    DIM y#
    x# = 320 + COS(i# * 3.14159 / 180) * 100
    y# = 240 + SIN(i# * 3.14159 / 180) * 100
    
    REM Redraw background
    LINE (0, 0)-(320, 480), RGB(255, 0, 0), BF
    LINE (320, 0)-(640, 480), RGB(0, 255, 0), BF
    
    MOVESHAPE img$, x#, y#
    DRAWSHAPE img$
    
    SLEEP 30
NEXT

SLEEP 2000
END
