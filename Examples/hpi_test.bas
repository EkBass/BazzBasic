REM ============================================
REM Test: HPI (Half PI) function
REM ============================================

PRINT "Testing HPI (Half PI) function"
PRINT

PRINT "PI  = "; PI
PRINT "HPI = "; HPI
PRINT "HPI should equal PI/2 = "; PI/2
PRINT

PRINT "Converting HPI to degrees:"
PRINT "DEG(HPI) = "; DEG(HPI); " degrees (should be 90)"
PRINT

PRINT "Common graphics angles:"
PRINT "  0 degrees   = "; RAD(0); " radians = 0"
PRINT " 90 degrees   = "; RAD(90); " radians = HPI = "; HPI
PRINT "180 degrees   = "; RAD(180); " radians = PI = "; PI
PRINT "270 degrees   = "; RAD(270); " radians = 3*HPI = "; 3*HPI
PRINT "360 degrees   = "; RAD(360); " radians = 2*PI = "; 2*PI
PRINT

PRINT "Trig with HPI:"
PRINT "SIN(HPI) = "; SIN(HPI); " (should be 1)"
PRINT "COS(HPI) = "; COS(HPI); " (should be 0)"
PRINT

PRINT "All tests completed!"
END
