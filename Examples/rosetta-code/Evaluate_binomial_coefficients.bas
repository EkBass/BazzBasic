' ============================================
' ROSETTA: https://rosettacode.org/wiki/Evaluate_binomial_coefficients
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Calculates the binomial coefficient C(5, 3) with the multiplicative formula and prints Pascal's triangle for rows 0 to 14.
' CATEGORY: math
' TAGS: binomial coefficient, pascal's triangle, combinations, multiplicative formula
' MINVERSION: 1.5
' ============================================

' Binomial coefficient C(n, k) via the multiplicative formula.
' Each intermediate result is itself a binomial coefficient,
' so the division is always exact.
DEF FN Binomial$(n$, k$)
    IF k$ < 0 OR k$ > n$ THEN RETURN 0
    IF k$ > n$ - k$ THEN k$ = n$ - k$      ' symmetry: C(n, k) = C(n, n-k)
    LET result$ = 1
    FOR i$ = 1 TO k$
        result$ = result$ * (n$ - k$ + i$) / i$
    NEXT
    RETURN result$
END DEF

[inits]
    LET WIDTH# = 5
    LET row$ = ""

[main]
    PRINT "C(5, 3) = "; FN Binomial$(5, 3)
    PRINT

    ' Pascal's triangle, rows 0..14
    FOR n$ = 0 TO 14
        row$ = ""
        FOR k$ = 0 TO n$
            row$ += RIGHT(REPEAT(" ", WIDTH#) + FN Binomial$(n$, k$), WIDTH#)
        NEXT
        PRINT row$
    NEXT

END

' Output:
' C(5, 3) = 10
'
'     1
'     1    1
'     1    2    1
'     1    3    3    1
'     1    4    6    4    1
'     1    5   10   10    5    1
'     1    6   15   20   15    6    1
'     1    7   21   35   35   21    7    1
'     1    8   28   56   70   56   28    8    1
'     1    9   36   84  126  126   84   36    9    1
'     1   10   45  120  210  252  210  120   45   10    1
'     1   11   55  165  330  462  462  330  165   55   11    1
'     1   12   66  220  495  792  924  792  495  220   66   12    1
'     1   13   78  286  715 1287 1716 1716 1287  715  286   78   13    1
'     1   14   91  364 1001 2002 3003 3432 3003 2002 1001  364   91   14    1
