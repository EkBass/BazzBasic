' ============================================
' Largest proper divisor of n  (Rosetta Code)
' https://rosettacode.org/wiki/Largest_proper_divisor_of_n
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' The largest proper divisor of n is n / p, where p is the
' smallest prime factor of n. If no factor exists up to SQR(n),
' n is prime (or 1) and the answer is 1.
DEF FN LargestProperDivisor$(n$)
    LET p$ = 2
    WHILE p$ * p$ <= n$
        IF n$ % p$ = 0 THEN RETURN n$ / p$
        p$ += 1
    WEND
    RETURN 1
END DEF

[inits]
    LET LIMIT#    = 100
    LET PER_ROW#  = 10
    LET WIDTH#    = 3
    LET cell$     = ""

[main]
    FOR n$ = 1 TO LIMIT#
        cell$ = RIGHT(REPEAT(" ", WIDTH#) + FN LargestProperDivisor$(n$), WIDTH#)
        PRINT cell$;
        IF n$ % PER_ROW# = 0 THEN PRINT ""
    NEXT
END

' Output:
'   1  1  1  2  1  3  1  4  3  5
'   1  6  1  7  5  8  1  9  1 10
'   7 11  1 12  5 13  9 14  1 15
'   1 16 11 17  7 18  1 19 13 20
'   1 21  1 22 15 23  1 24  7 25
'  17 26  1 27 11 28 19 29  1 30
'   1 31 21 32 13 33  1 34 23 35
'   1 36  1 37 25 38 11 39  1 40
'  27 41  1 42 17 43 29 44  1 45
'  13 46 31 47 19 48  1 49 33 50