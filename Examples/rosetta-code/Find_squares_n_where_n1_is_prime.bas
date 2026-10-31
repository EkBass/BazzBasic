' ============================================
' ROSETTA: https://rosettacode.org/wiki/Find_squares_n_where_n%2B1_is_prime
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the squares below 1000 whose successor n + 1 is prime.
' CATEGORY: math
' TAGS: squares, primes, trial division
' MINVERSION: 1.5
' ============================================

DEF FN IsPrime$(n$)
    IF n$ < 2 THEN RETURN FALSE
    IF n$ < 4 THEN RETURN TRUE
    IF MOD(n$, 2) = 0 THEN RETURN FALSE
    LET d$ = 3
    WHILE d$ * d$ <= n$
        IF MOD(n$, d$) = 0 THEN RETURN FALSE
        d$ += 2
    WEND
    RETURN TRUE
END DEF

[inits]
    LET LIMIT# = 1000
    LET k$     = 1
    LET sq$    = 1

[main]
    WHILE sq$ < LIMIT#
        IF FN IsPrime$(sq$ + 1) THEN PRINT sq$; " ";
        k$ += 1
        sq$ = k$ * k$
    WEND
    PRINT
END

' Output:
' 1 4 16 36 100 196 256 400 576 676