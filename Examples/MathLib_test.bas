' ============================================
' MathLib_test.bas - BazzBasic
' Tests .bb library loading and function calls
' ============================================

' INSTRUCTIONS:
' Compile "MathLib.bas" first as bb-library
' CLI: BazzBasic.exe -lib MathLib.bas

INCLUDE "MathLib.bb"

]inits}
    LET a$ = 5
    LET b$ = 3


[main]
    PRINT "Testing library functions:"
    PRINT ""

    PRINT "MATHLIB_add$(5, 3) = "; FN MATHLIB_add$(a$, b$)
    PRINT "MATHLIB_multiply$(5, 3) = "; FN MATHLIB_multiply$(a$, b$)
    PRINT "MATHLIB_square$(5) = "; FN MATHLIB_square$(a$)

    PRINT ""
    PRINT "All tests passed!"
END
