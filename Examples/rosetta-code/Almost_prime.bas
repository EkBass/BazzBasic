' ============================================
' ROSETTA: https://rosettacode.org/wiki/Almost_prime
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the first ten k-almost primes (numbers with exactly k prime factors, counted with repeats) for k = 1 to 5.
' CATEGORY: math
' TAGS: almost primes, prime factors, factorization
' MINVERSION: 1.5
' ============================================
' Task: show the first ten k-almost primes for 1 <= k <= 5
'       (numbers with exactly k prime factors, counting repeats).

' TRUE if n$ has exactly k$ prime factors (counted with multiplicity)
DEF FN IsKPrime$(n$, k$)
    LET m$ = n$
    LET factors$ = 0
    LET d$ = 2
    WHILE d$ * d$ <= m$ AND factors$ <= k$
        WHILE MOD(m$, d$) = 0
            m$ = INT(m$ / d$)
            factors$ += 1
        WEND
        d$ += 1
    WEND
    IF m$ > 1 THEN factors$ += 1       ' whatever remains is a prime factor
    IF factors$ = k$ THEN RETURN TRUE
    RETURN FALSE
END DEF

[inits]
    LET MAX_K# = 5
    LET PER_ROW# = 10
    LET found$ = 0
    LET n$ = 0
    LET row$ = ""

[main]
    FOR k$ = 1 TO MAX_K#
        row$ = "k = " + k$ + ":"
        found$ = 0
        n$ = 2
        WHILE found$ < PER_ROW#
            IF FN IsKPrime$(n$, k$) THEN
                row$ += RIGHT("    " + n$, 4)     ' right-align to width 4
                found$ += 1
            END IF
            n$ += 1
        WEND
        PRINT row$
    NEXT
END

' Output:
' k = 1:   2   3   5   7  11  13  17  19  23  29
' k = 2:   4   6   9  10  14  15  21  22  25  26
' k = 3:   8  12  18  20  27  28  30  42  44  45
' k = 4:  16  24  36  40  54  56  60  81  84  88
' k = 5:  32  48  72  80 108 112 120 162 168 176