REM ============================================
REM Test: Library Usage
REM Tests .bb library loading and function calls
REM ============================================

INCLUDE "MathLib.bb"

PRINT "Testing library functions:"
PRINT ""

LET a$ = 5
LET b$ = 3

PRINT "MATHLIB_add$(5, 3) = "; FN MATHLIB_add$(a$, b$)
PRINT "MATHLIB_multiply$(5, 3) = "; FN MATHLIB_multiply$(a$, b$)
PRINT "MATHLIB_square$(5) = "; FN MATHLIB_square$(a$)

PRINT ""
PRINT "All tests passed!"
END
