REM ============================================
REM Test: FastTrig System
REM ============================================

PRINT "Testing FastTrig lookup table system"
PRINT

REM Enable FastTrig
PRINT "Enabling FastTrig lookup tables..."
FASTTRIG(TRUE)
PRINT "FastTrig enabled!"
PRINT

REM Test FastSin
PRINT "FastSin tests:"
PRINT "  FastSin(0) = "; FASTSIN(0); " (should be ~0)"
PRINT "  FastSin(90) = "; FASTSIN(90); " (should be 1)"
PRINT "  FastSin(180) = "; FASTSIN(180); " (should be ~0)"
PRINT "  FastSin(270) = "; FASTSIN(270); " (should be -1)"
PRINT

REM Test FastCos
PRINT "FastCos tests:"
PRINT "  FastCos(0) = "; FASTCOS(0); " (should be 1)"
PRINT "  FastCos(90) = "; FASTCOS(90); " (should be ~0)"
PRINT "  FastCos(180) = "; FASTCOS(180); " (should be -1)"
PRINT "  FastCos(270) = "; FASTCOS(270); " (should be ~0)"
PRINT

REM Test FastRad
PRINT "FastRad tests:"
PRINT "  FastRad(0) = "; FASTRAD(0); " radians"
PRINT "  FastRad(90) = "; FASTRAD(90); " radians (should be ~1.571)"
PRINT "  FastRad(180) = "; FASTRAD(180); " radians (should be ~3.142)"
PRINT "  FastRad(360) = "; FASTRAD(360); " radians (should be ~6.283)"
PRINT

REM Performance comparison
PRINT "Performance test: 10000 iterations"
LET start$ = TICKS()

FOR i$ = 0 TO 9999
    LET dummy$ = FASTSIN(i$)
    LET dummy$ = FASTCOS(i$)
NEXT

LET elapsed$ = TICKS() - start$
PRINT "FastTrig: "; elapsed$; " ms for 20000 lookups"
PRINT

REM Test angle wrapping (negative and > 360)
PRINT "Angle wrapping tests:"
PRINT "  FastSin(-90) = "; FASTSIN(-90); " (should be -1)"
PRINT "  FastSin(450) = "; FASTSIN(450); " (should be 1, wraps to 90)"
PRINT "  FastCos(720) = "; FASTCOS(720); " (should be 1, wraps to 0)"
PRINT

REM Disable FastTrig
PRINT "Disabling FastTrig..."
FASTTRIG(FALSE)
PRINT "FastTrig disabled!"
PRINT

PRINT "All tests completed!"
END
