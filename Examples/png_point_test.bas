REM ============================================
REM Test: PNG loading with Alpha + POINT command
REM ============================================

SCREEN 0, 640, 480, "PNG and POINT Test"

REM Draw some colored rectangles as test pattern
COLOR 4
LINE(10, 10)-(100, 100), RGB(255, 0, 0), BF
LINE(110, 10)-(200, 100), RGB(0, 255, 0), BF
LINE(210, 10)-(300, 100), RGB(0, 0, 255), BF

REM Test POINT - read back the colors
LET redPixel$
LET greenPixel$
LET bluePixel$

SLEEP 100

REM Read pixel from red rectangle
LET c1$
c1$ = POINT(50, 50)
LOCATE 15, 1
PRINT "Red area POINT(50,50) = "; c1$

REM Read pixel from green rectangle  
LET c2$
c2$ = POINT(150, 50)
LOCATE 16, 1
PRINT "Green area POINT(150,50) = "; c2$

REM Read pixel from blue rectangle
LET c3$
c3$ = POINT(250, 50)
LOCATE 17, 1
PRINT "Blue area POINT(250,50) = "; c3$

REM Read pixel from black background
LET c4$
c4$ = POINT(400, 300)
LOCATE 18, 1
PRINT "Background POINT(400,300) = "; c4$

LOCATE 20, 1
SLEEP 5000

End
