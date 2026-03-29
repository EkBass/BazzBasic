' ==========================================
' Distance_test.bas — BazzBasic
' Tests the built-in DISTANCE function
' in both 2D (4 args) and 3D (6 args) forms.
' https://github.com/EkBass/BazzBasic
' ==========================================

[inits]
    LET x1$ = 10
    LET y1$ = 20
    LET x2$ = 40
    LET y2$ = 60

[main]
    PRINT "=== 2D tests ==="
    PRINT ""

    PRINT "3-4-5 triangle:"
    PRINT "  DISTANCE(0,0, 3,4)    = "; DISTANCE(0, 0, 3, 4)
    PRINT "  Expected              : 5"
    PRINT ""

    PRINT "Same point:"
    PRINT "  DISTANCE(5,5, 5,5)    = "; DISTANCE(5, 5, 5, 5)
    PRINT "  Expected              : 0"
    PRINT ""

    PRINT "Horizontal:"
    PRINT "  DISTANCE(0,0, 10,0)   = "; DISTANCE(0, 0, 10, 0)
    PRINT "  Expected              : 10"
    PRINT ""

    PRINT "Negative coords:"
    PRINT "  DISTANCE(-3,0, 3,0)   = "; DISTANCE(-3, 0, 3, 0)
    PRINT "  Expected              : 6"
    PRINT ""

    PRINT "With variables:"
    PRINT "  DISTANCE(x1$,y1$, x2$,y2$) = "; DISTANCE(x1$, y1$, x2$, y2$)
    PRINT "  Expected                   : 50"
    PRINT ""

    PRINT "=== 3D tests ==="
    PRINT ""

    PRINT "Unit diagonal:"
    PRINT "  DISTANCE(0,0,0, 1,1,1) = "; DISTANCE(0, 0, 0, 1, 1, 1)
    PRINT "  Expected               : 1.732... (sqrt 3)"
    PRINT ""

    PRINT "Axis-aligned:"
    PRINT "  DISTANCE(0,0,0, 0,0,5) = "; DISTANCE(0, 0, 0, 0, 0, 5)
    PRINT "  Expected               : 5"
    PRINT ""

    PRINT "All tests done."
END

' Output:
' === 2D tests ===
' 
' 3-4-5 triangle:
'   DISTANCE(0,0, 3,4)    = 5
'   Expected              : 5
' 
' Same point:
'   DISTANCE(5,5, 5,5)    = 0
'   Expected              : 0
' 
' Horizontal:
'   DISTANCE(0,0, 10,0)   = 10
'   Expected              : 10
' 
' Negative coords:
'   DISTANCE(-3,0, 3,0)   = 6
'   Expected              : 6
' 
' With variables:
'   DISTANCE(x1$,y1$, x2$,y2$) = 50
'   Expected                   : 50
' 
' === 3D tests ===
' 
' Unit diagonal:
'   DISTANCE(0,0,0, 1,1,1) = 1.7320508075688772
'   Expected               : 1.732... (sqrt 3)
' 
' Axis-aligned:
'   DISTANCE(0,0,0, 0,0,5) = 5
'   Expected               : 5
' 
' All tests done.
