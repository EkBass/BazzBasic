REM ============================================
REM Test: RAD and DEG functions
REM ============================================

PRINT "Testing RAD() and DEG() conversion functions"
PRINT

REM Test degrees to radians
PRINT "Degrees to Radians:"
PRINT "  90 degrees = "; RAD(90); " radians"
PRINT " 180 degrees = "; RAD(180); " radians"
PRINT " 360 degrees = "; RAD(360); " radians"
PRINT

REM Test radians to degrees
PRINT "Radians to Degrees:"
PRINT "  PI radians = "; DEG(PI); " degrees"
PRINT "  PI/2 radians = "; DEG(PI/2); " degrees"
PRINT "  2*PI radians = "; DEG(2*PI); " degrees"
PRINT

REM Test with trigonometry functions
PRINT "Using with trig functions:"
PRINT "  SIN(RAD(90)) = "; SIN(RAD(90)); " (should be 1)"
PRINT "  COS(RAD(180)) = "; COS(RAD(180)); " (should be -1)"
PRINT "  TAN(RAD(45)) = "; TAN(RAD(45)); " (should be ~1)"
PRINT

REM Test round-trip conversion
LET degrees$ = 123.456
LET back_to_degrees$ = DEG(RAD(degrees$))
PRINT "Round-trip test:"
PRINT "  Original: "; degrees$; " degrees"
PRINT "  After RAD->DEG: "; back_to_degrees$; " degrees"
PRINT

PRINT "All tests completed!"
END
