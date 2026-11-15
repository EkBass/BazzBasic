' ============================================
' Largest difference between adjacent primes
' https://rosettacode.org/wiki/Largest_difference_between_adjacent_primes
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' Primality test by trial division using the 6k +/- 1 pattern
DEF FN IsPrime$(n$)
    IF n$ < 2 THEN RETURN FALSE
    IF n$ < 4 THEN RETURN TRUE
    IF n$ % 2 = 0 OR n$ % 3 = 0 THEN RETURN FALSE
    LET d$ = 5
    WHILE d$ * d$ <= n$
        IF n$ % d$ = 0 OR n$ % (d$ + 2) = 0 THEN RETURN FALSE
        d$ += 6
    WEND
    RETURN TRUE
END DEF

' Finds the next prime after n$ (n$ is expected to be odd when >= 3)
DEF FN NextPrime$(n$)
    IF n$ = 0 THEN RETURN 2
    IF n$ < 3 THEN RETURN n$ + 1
    LET q$ = n$ + 2
    WHILE NOT FN IsPrime$(q$)
        q$ += 2
    WEND
    RETURN q$
END DEF

[inits]
    LET LIMIT# = 1000000
    LET i$      = 5         ' current prime
    LET j$      = 0         ' next prime after i$
    LET champ$  = 3         ' lower prime of the record gap
    LET champJ$ = 5         ' upper prime of the record gap
    LET record$ = 2         ' largest gap found so far

[main]
    WHILE i$ < LIMIT#
        j$ = FN NextPrime$(i$)
        IF j$ - i$ > record$ THEN
            champ$  = i$
            champJ$ = j$
            record$ = j$ - i$
        END IF
        i$ = j$
    WEND

    PRINT FSTRING("The largest difference was {{-record$-}}, between {{-champ$-}} and {{-champJ$-}}")
END

' Output:
' The largest difference was 114, between 492113 and 492227