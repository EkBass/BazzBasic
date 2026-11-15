' ============================================
' Least common multiple - recursive GCD solution
' https://rosettacode.org/wiki/Least_common_multiple
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' Euclid's algorithm, recursive. Expects non-negative arguments.
DEF FN GcdP$(a$, b$)
    IF b$ = 0 THEN RETURN a$
    RETURN FN GcdP$(b$, MOD(a$, b$))
END DEF

' GCD that accepts negative arguments
DEF FN Gcd$(a$, b$)
    RETURN FN GcdP$(ABS(a$), ABS(b$))
END DEF

' lcm(a, b) = |a * b| / gcd(a, b)
DEF FN Lcm$(a$, b$)
    IF a$ = 0 OR b$ = 0 THEN RETURN 0     ' also avoids 0 / 0
    RETURN ABS(a$) / FN Gcd$(a$, b$) * ABS(b$)
END DEF

[main]
    PRINT "lcm( 12, -18) = "; FN Lcm$(12, -18)
    PRINT "lcm( 15,  12) = "; FN Lcm$(15, 12)
    PRINT "lcm(-10, -14) = "; FN Lcm$(-10, -14)
    PRINT "lcm(  0,   1) = "; FN Lcm$(0, 1)
END

' Output:
' lcm( 12, -18) = 36
' lcm( 15,  12) = 60
' lcm(-10, -14) = 70
' lcm(  0,   1) = 0