' ==========================================
' Fasttrig_comprehensive_test.bas — BazzBasic
' Tests the FastTrig lookup table system:
' FastTrig(), FastSin(), FastCos(), FastRad()
' https://github.com/EkBass/BazzBasic
' ==========================================

[inits]
    LET angle$  = 30
    LET radius$ = 100

[main]
    PRINT "FastTrig Comprehensive Test Suite"
    PRINT REPEAT("=", 44)
    PRINT ""

    ' --- Test 1: Enable / Disable ---
    PRINT "Test 1: Enable / Disable"
    PRINT REPEAT("-", 44)
    FastTrig(TRUE)
    PRINT "  FastSin(90)  = "; FastSin(90);  "  (expected: 1)"
    PRINT "  FastCos(0)   = "; FastCos(0);   "  (expected: 1)"
    FastTrig(FALSE)
    PRINT "  FastTrig disabled OK"
    PRINT ""

    ' --- Test 2: Cardinal angles ---
    PRINT "Test 2: Cardinal Angles"
    PRINT REPEAT("-", 44)
    FastTrig(TRUE)
    PRINT "  FastSin(0)   = "; FastSin(0);   "    (expected:  0)"
    PRINT "  FastSin(90)  = "; FastSin(90);  "    (expected:  1)"
    PRINT "  FastSin(180) = "; FastSin(180); "    (expected:  0)"
    PRINT "  FastSin(270) = "; FastSin(270); "   (expected: -1)"
    PRINT "  FastSin(360) = "; FastSin(360); "    (expected:  0)"
    PRINT ""
    PRINT "  FastCos(0)   = "; FastCos(0);   "    (expected:  1)"
    PRINT "  FastCos(90)  = "; FastCos(90);  "    (expected:  0)"
    PRINT "  FastCos(180) = "; FastCos(180); "   (expected: -1)"
    PRINT "  FastCos(270) = "; FastCos(270); "    (expected:  0)"
    PRINT "  FastCos(360) = "; FastCos(360); "    (expected:  1)"
    PRINT ""
    ' --- Test 3: Angle wrapping ---
    PRINT "Test 3: Angle Wrapping"
    PRINT REPEAT("-", 44)
    PRINT "  FastSin(-90) = "; FastSin(-90); "   (= 270, expected: -1)"
    PRINT "  FastSin(450) = "; FastSin(450); "    (=  90, expected:  1)"
    PRINT "  FastSin(720) = "; FastSin(720); "    (=   0, expected:  0)"
    PRINT "  FastCos(-90) = "; FastCos(-90); "    (= 270, expected:  0)"
    PRINT "  FastCos(450) = "; FastCos(450); "    (=  90, expected:  0)"
    PRINT ""

    ' --- Test 4: 45-degree angles ---
    PRINT "Test 4: 45-Degree Angles"
    PRINT REPEAT("-", 44)
    PRINT "  FastSin(45)            = "; FastSin(45); "  (expected: ~0.707)"
    PRINT "  FastCos(45)            = "; FastCos(45); "  (expected: ~0.707)"
    PRINT "  sin45^2 + cos45^2      = "; (FastSin(45) * FastSin(45)) + (FastCos(45) * FastCos(45)); "  (expected: ~1)"
    PRINT ""

    ' --- Test 5: FastRad conversion ---
    PRINT "Test 5: FastRad Conversion"
    PRINT REPEAT("-", 44)
    PRINT "  FastRad(0)   = "; FastRad(0);   "       (expected: 0)"
    PRINT "  FastRad(90)  = "; FastRad(90);  "  (expected: ~1.5708 = HPI)"
    PRINT "  FastRad(180) = "; FastRad(180); "  (expected: ~3.1416 = PI)"
    PRINT "  FastRad(360) = "; FastRad(360); "  (expected: ~6.2832 = TAU)"
    PRINT ""

    ' --- Test 6: Accuracy vs regular SIN/COS ---
    PRINT "Test 6: Accuracy vs SIN / COS"
    PRINT REPEAT("-", 44)
    PRINT "  Angle: "; angle$; " degrees"
    PRINT "  FastSin(30)    = "; FastSin(angle$)
    PRINT "  SIN(RAD(30))   = "; SIN(RAD(angle$))
    PRINT "  Difference     = "; FastSin(angle$) - SIN(RAD(angle$))
    PRINT ""
    PRINT "  FastCos(30)    = "; FastCos(angle$)
    PRINT "  COS(RAD(30))   = "; COS(RAD(angle$))
    PRINT "  Difference     = "; FastCos(angle$) - COS(RAD(angle$))
    PRINT ""
    ' --- Test 7: Performance ---
    PRINT "Test 7: Performance (10 000 lookups)"
    PRINT REPEAT("-", 44)
    LET start$, dummy$
    start$ = TICKS
    FOR i$ = 1 TO 10000
        dummy$ = FastSin(MOD(i$, 360))
    NEXT
    LET elapsed$ = TICKS - start$
    PRINT "  Total : "; elapsed$; " ms"
    PRINT "  Per lookup: "; elapsed$ / 10000; " ms"
    PRINT ""

    ' --- Test 8: Circle points ---
    PRINT "Test 8: Circle Points (radius = "; radius$; ")"
    PRINT REPEAT("-", 44)
    FOR angle$ = 0 TO 315 STEP 45
        PRINT "  "; angle$; "°  (";
        PRINT ROUND(radius$ * FastCos(angle$)); ", ";
        PRINT ROUND(radius$ * FastSin(angle$)); ")"
    NEXT
    PRINT ""

    ' --- Done ---
    FastTrig(FALSE)
    PRINT REPEAT("=", 44)
    PRINT "All tests done. FastTrig disabled."
END

' Output:
' FastTrig Comprehensive Test Suite
' ============================================

' Test 1: Enable / Disable
' --------------------------------------------
'   FastSin(90)  = 1  (expected: 1)
'   FastCos(0)   = 1  (expected: 1)
'   FastTrig disabled OK

' Test 2: Cardinal Angles
' --------------------------------------------
'   FastSin(0)   = 0    (expected:  0)
'   FastSin(90)  = 1    (expected:  1)
'   FastSin(180) = 1.2246467991473532E-16    (expected:  0)
'   FastSin(270) = -1   (expected: -1)
'   FastSin(360) = 0    (expected:  0)

'   FastCos(0)   = 1    (expected:  1)
'   FastCos(90)  = 6.123233995736766E-17    (expected:  0)
'   FastCos(180) = -1   (expected: -1)
'   FastCos(270) = -1.8369701987210297E-16    (expected:  0)
'   FastCos(360) = 1    (expected:  1)

' Test 3: Angle Wrapping
' --------------------------------------------
'   FastSin(-90) = -1   (= 270, expected: -1)
'   FastSin(450) = 1    (=  90, expected:  1)
'   FastSin(720) = 0    (=   0, expected:  0)
'   FastCos(-90) = -1.8369701987210297E-16    (= 270, expected:  0)
'   FastCos(450) = 6.123233995736766E-17    (=  90, expected:  0)

' Test 4: 45-Degree Angles
' --------------------------------------------
'   FastSin(45)            = 0.7071067811865476  (expected: ~0.707)
'   FastCos(45)            = 0.7071067811865476  (expected: ~0.707)
'   sin45^2 + cos45^2      = 1.0000000000000002  (expected: ~1)

' Test 5: FastRad Conversion
' --------------------------------------------
'   FastRad(0)   = 0       (expected: 0)
'   FastRad(90)  = 1.5707963267948966  (expected: ~1.5708 = HPI)
'   FastRad(180) = 3.141592653589793  (expected: ~3.1416 = PI)
'   FastRad(360) = 0  (expected: ~6.2832 = TAU)

' Test 6: Accuracy vs SIN / COS
' --------------------------------------------
'   Angle: 30 degrees
'   FastSin(30)    = 0.49999999999999994
'   SIN(RAD(30))   = 0.49999999999999994
'   Difference     = 0

'   FastCos(30)    = 0.8660254037844387
'   COS(RAD(30))   = 0.8660254037844387
'   Difference     = 0

' Test 7: Performance (10 000 lookups)
' --------------------------------------------
'   Total : 20 ms
'   Per lookup: 0.002 ms

' Test 8: Circle Points (radius = 100)
' --------------------------------------------
'   0°  (100, 0)
'   45°  (71, 71)
'   90°  (0, 100)
'   135°  (-71, 71)
'   180°  (-100, 0)
'   225°  (-71, -71)
'   270°  (-0, -100)
'   315°  (71, -71)

' ============================================
' All tests done. FastTrig disabled.
