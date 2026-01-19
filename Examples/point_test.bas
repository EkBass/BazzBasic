REM ============================================
REM Test: POINT command - read pixel color
REM ============================================

SCREEN 0, 640, 480, "POINT Test"

REM Draw some colored rectangles using RGB values
LINE(50, 50)-(150, 150), RGB(255, 0, 0), BF
LINE(200, 50)-(300, 150), RGB(0, 255, 0), BF
LINE(350, 50)-(450, 150), RGB(0, 0, 255), BF

SLEEP 500

REM Read pixel colors using POINT
LET c1$
LET c2$
LET c3$

c1$ = POINT(100, 100)
c2$ = POINT(250, 100)
c3$ = POINT(400, 100)

REM Display results
LOCATE 20, 5
PRINT "Red box at (100,100): ";
PRINT c1$

LOCATE 22, 5
PRINT "Green box at (250,100): ";
PRINT c2$

LOCATE 24, 5
PRINT "Blue box at (400,100): ";
PRINT c3$

REM Test reading background (should be 0)
LET bg$
bg$ = POINT(500, 300)
LOCATE 26, 5
PRINT "Background at (500,300): ";
PRINT bg$

SLEEP 5000
End
