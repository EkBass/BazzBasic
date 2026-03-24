' ============================================
' MathLib — BazzBasic library example
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Compile: BazzBasic.exe -lib MathLib.bas  →  MathLib.bb
' Usage:   INCLUDE "MathLib.bb"
'          Functions are prefixed: MATHLIB_Add$(), etc.
' ============================================

DEF FN Add$(x$, y$)
    RETURN x$ + y$
END DEF

DEF FN Multiply$(x$, y$)
    RETURN x$ * y$
END DEF

DEF FN Square$(x$)
    RETURN x$ * x$
END DEF

' ============================================
' USAGE EXAMPLE:
' INCLUDE "MathLib.bb"
' LET a$ = 5
' LET b$ = 3
' PRINT "5 + 3 = ";   FN MATHLIB_Add$(a$, b$)
' PRINT "5 * 3 = ";   FN MATHLIB_Multiply$(a$, b$)
' PRINT "5^2  = ";    FN MATHLIB_Square$(a$)
' ============================================
