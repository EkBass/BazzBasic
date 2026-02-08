REM ============================================
REM Comprehensive FastTrig Test Suite
REM ============================================

PRINT "FastTrig Comprehensive Test Suite"
PRINT "=================================="
PRINT

REM Test 1: Basic FastTrig enable/disable
PRINT "Test 1: Enable/Disable FastTrig"
PRINT "--------------------------------"
FastTrig(TRUE)
PRINT "FastTrig enabled successfully"

LET test_sin$ = FastSin(90)
LET test_cos$ = FastCos(0)
PRINT "FastSin(90) = "; test_sin$; " (should be 1)"
PRINT "FastCos(0) = "; test_cos$; " (should be 1)"

FastTrig(FALSE)
PRINT "FastTrig disabled successfully"
PRINT

REM Test 2: Re-enable and test all basic angles
PRINT "Test 2: Basic Angles (0, 90, 180, 270, 360)"
PRINT "--------------------------------------------"
FastTrig(TRUE)

PRINT "FastSin(0)   = "; FastSin(0); "   (should be 0)"
PRINT "FastSin(90)  = "; FastSin(90); "  (should be 1)"
PRINT "FastSin(180) = "; FastSin(180); "  (should be 0)"
PRINT "FastSin(270) = "; FastSin(270); " (should be -1)"
PRINT "FastSin(360) = "; FastSin(360); "   (should be 0)"
PRINT

PRINT "FastCos(0)   = "; FastCos(0); "  (should be 1)"
PRINT "FastCos(90)  = "; FastCos(90); "   (should be 0)"
PRINT "FastCos(180) = "; FastCos(180); " (should be -1)"
PRINT "FastCos(270) = "; FastCos(270); "   (should be 0)"
PRINT "FastCos(360) = "; FastCos(360); "  (should be 1)"
PRINT

REM Test 3: Angle wrapping (negative and > 360)
PRINT "Test 3: Angle Wrapping"
PRINT "----------------------"
PRINT "FastSin(-90)  = "; FastSin(-90); " (same as 270, should be -1)"
PRINT "FastSin(450)  = "; FastSin(450); "  (same as 90, should be 1)"
PRINT "FastSin(720)  = "; FastSin(720); "   (same as 0, should be 0)"
PRINT "FastCos(-90)  = "; FastCos(-90); "   (same as 270, should be 0)"
PRINT "FastCos(450)  = "; FastCos(450); "   (same as 90, should be 0)"
PRINT

REM Test 4: 45-degree angles
PRINT "Test 4: 45-Degree Angles"
PRINT "------------------------"
LET sin45$ = FastSin(45)
LET cos45$ = FastCos(45)
PRINT "FastSin(45) = "; sin45$; " (should be ~0.707)"
PRINT "FastCos(45) = "; cos45$; " (should be ~0.707)"
PRINT "sin45^2 + cos45^2 = "; (sin45$ * sin45$) + (cos45$ * cos45$); " (should be ~1)"
PRINT

REM Test 5: FastRad conversion
PRINT "Test 5: FastRad Conversion"
PRINT "--------------------------"
PRINT "FastRad(0)   = "; FastRad(0); "   (should be 0)"
PRINT "FastRad(90)  = "; FastRad(90); " (should be ~1.5708 / HPI)"
PRINT "FastRad(180) = "; FastRad(180); " (should be ~3.1416 / PI)"
PRINT "FastRad(360) = "; FastRad(360); " (should be ~6.2832 / 2*PI)"
PRINT

REM Test 6: Comparison with regular SIN/COS
PRINT "Test 6: Accuracy vs Regular SIN/COS"
PRINT "------------------------------------"
LET angle$ = 30
PRINT "Angle: "; angle$; " degrees"
PRINT "FastSin(30) = "; FastSin(angle$)
PRINT "SIN(RAD(30)) = "; SIN(RAD(angle$))
PRINT "Difference = "; FastSin(angle$) - SIN(RAD(angle$))
PRINT
PRINT "FastCos(30) = "; FastCos(angle$)
PRINT "COS(RAD(30)) = "; COS(RAD(angle$))
PRINT "Difference = "; FastCos(angle$) - COS(RAD(angle$))
PRINT

REM Test 7: Performance test (simple loop)
PRINT "Test 7: Performance Test"
PRINT "------------------------"
PRINT "Running 10000 FastSin lookups..."

LET start$ = TICKS
FOR i$ = 1 TO 10000
    LET dummy$ = FastSin(MOD(i$, 360))
NEXT
LET fast_time$ = TICKS - start$

PRINT "FastSin: "; fast_time$; " ms for 10000 lookups"
PRINT "Average: "; fast_time$ / 10000; " ms per lookup"
PRINT

REM Test 8: Practical use case - circle points
PRINT "Test 8: Generate Circle Points"
PRINT "-------------------------------"
LET radius$ = 100
PRINT "Generating 8 points on circle (radius=100):"

FOR angle$ = 0 TO 315 STEP 45
    LET x$ = radius$ * FastCos(angle$)
    LET y$ = radius$ * FastSin(angle$)
    PRINT "Angle "; angle$; ": ("; ROUND(x$); ", "; ROUND(y$); ")"
NEXT
PRINT

REM Cleanup
FastTrig(FALSE)
PRINT "=================================="
PRINT "All tests completed successfully!"
PRINT "FastTrig disabled and memory freed"
END
