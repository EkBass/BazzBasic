REM ============================================
REM Test: DISTANCE function (2D and 3D)
REM ============================================

PRINT "Testing DISTANCE function..."
PRINT ""

REM Test 1: Classic 3-4-5 triangle
PRINT "2D: distance(0,0, 3,4) = "; DISTANCE(0, 0, 3, 4)
PRINT "Expected: 5"
PRINT ""

REM Test 2: Same point
PRINT "2D: distance(5,5, 5,5) = "; DISTANCE(5, 5, 5, 5)
PRINT "Expected: 0"
PRINT ""

REM Test 3: Horizontal
PRINT "2D: distance(0,0, 10,0) = "; DISTANCE(0, 0, 10, 0)
PRINT "Expected: 10"
PRINT ""

REM Test 4: Negative coords
PRINT "2D: distance(-3,0, 3,0) = "; DISTANCE(-3, 0, 3, 0)
PRINT "Expected: 6"
PRINT ""

REM Test 5: 3D basic
PRINT "3D: distance(0,0,0, 1,1,1) = "; DISTANCE(0, 0, 0, 1, 1, 1)
PRINT "Expected: 1.732... (sqrt 3)"
PRINT ""

REM Test 6: 3D axis-aligned
PRINT "3D: distance(0,0,0, 0,0,5) = "; DISTANCE(0, 0, 0, 0, 0, 5)
PRINT "Expected: 5"
PRINT ""

REM Test 7: With variables
LET x1$ = 10, y1$ = 20
LET x2$ = 40, y2$ = 60
PRINT "2D with vars: "; DISTANCE(x1$, y1$, x2$, y2$)
PRINT "Expected: 50"

PRINT ""
PRINT "All tests done!"
END
