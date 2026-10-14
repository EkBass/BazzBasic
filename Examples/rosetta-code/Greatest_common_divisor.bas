' ============================================
' https://rosettacode.org/wiki/Greatest_common_divisor
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Euclid's algorithm, iterative and recursive.

DEF FN GcdIter$(a$, b$)
    LET t$ = 0
    WHILE b$ <> 0
        t$ = b$
        b$ = MOD(a$, b$)
        a$ = t$
    WEND
    RETURN ABS(a$)
END DEF

DEF FN GcdRec$(a$, b$)
    IF b$ = 0 THEN RETURN ABS(a$)
    RETURN FN GcdRec$(b$, MOD(a$, b$))
END DEF

[inits]
    DIM pairs$
        pairs$(0, 0) = 18   : pairs$(0, 1) = 30
        pairs$(1, 0) = 1071 : pairs$(1, 1) = 462
        pairs$(2, 0) = -48  : pairs$(2, 1) = 18
        pairs$(3, 0) = 17   : pairs$(3, 1) = 0
    LET a$ = 0
    LET b$ = 0
    LET iter$ = 0
    LET rec$ = 0

[main]
    FOR i$ = 0 TO ROWCOUNT(pairs$()) - 1
        a$ = pairs$(i$, 0)
        b$ = pairs$(i$, 1)
        iter$ = FN GcdIter$(a$, b$)
        rec$ = FN GcdRec$(a$, b$)
        PRINT FSTRING("gcd({{-a$-}}, {{-b$-}}) = {{-iter$-}} (iterative), {{-rec$-}} (recursive)")
    NEXT
END

' Output:
' gcd(18, 30) = 6 (iterative), 6 (recursive)
' gcd(1071, 462) = 21 (iterative), 21 (recursive)
' gcd(-48, 18) = 6 (iterative), 6 (recursive)
' gcd(17, 0) = 17 (iterative), 17 (recursive)
