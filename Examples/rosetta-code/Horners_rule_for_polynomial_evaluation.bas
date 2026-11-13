' ============================================
' https://rosettacode.org/wiki/Horner%27s_rule_for_polynomial_evaluation
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    LET X# = 3

    ' Coefficients in ascending order: c(0) + c(1)*x + c(2)*x^2 + c(3)*x^3
    DIM coef$
    coef$(0) = -19
    coef$(1) = 7
    coef$(2) = -4
    coef$(3) = 6

    LET acc$ = 0

[main]
    FOR i$ = ROWCOUNT(coef$()) - 1 TO 0 STEP -1
        acc$ = acc$ * X# + coef$(i$)
    NEXT

    PRINT "Horner's algorithm for the polynomial"
    PRINT "6*x^3 - 4*x^2 + 7*x - 19 when x = "; X#; " : "; acc$
END

' Output:
' Horner's algorithm for the polynomial
' 6*x^3 - 4*x^2 + 7*x - 19 when x = 3 : 128