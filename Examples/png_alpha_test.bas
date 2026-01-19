REM ============================================
REM Test: PNG with Alpha transparency
REM ============================================

SCREEN 0, 640, 480, "PNG Alpha Test"

REM Draw a colorful background first
LINE(0, 0)-(320, 480), RGB(255, 0, 0), BF
LINE(320, 0)-(640, 480), RGB(0, 255, 0), BF

REM Load PNG image (use icon.png from project root)
LET img# = LOADIMAGE("icon.png")

If img# = "" Then
LOCATE 10, 10
    PRINT "Failed to load PNG!"
    SLEEP 3000
    End
End If

REM Move and draw the image - alpha should blend with background
MOVESHAPE img#, 320, 240
DRAWSHAPE img#

SLEEP 2000

REM Move around to show transparency
LET x$, y$
For i$ = 0 To 360 Step 15
Dim x$
Dim y$
x$ = 320 + COS(i$ * 3.14159 / 180) * 100
y$ = 240 + SIN(i$ * 3.14159 / 180) * 100

SCREENLOCK ON
    REM Redraw background
    LINE(0, 0)-(320, 480), RGB(255, 0, 0), BF
    LINE(320, 0)-(640, 480), RGB(0, 255, 0), BF
    
    MOVESHAPE img#, x$, y$
    DRAWSHAPE img#
    SCREENLOCK OFF
SLEEP 30
Next

SLEEP 2000
End
