' ============================================
' https://rosettacode.org/wiki/Anti-primes
' BazzBasic: https://github.com/EkBass/BazzBasic
' Task: generate and show the first twenty anti-primes
'       (numbers with more divisors than any smaller number).
' ============================================

' Count divisors by pairing d$ with n$ / d$ up to the square root
DEF FN CountDivisors$(n$)
    LET count$ = 0
    LET d$ = 1
    WHILE d$ * d$ <= n$
        IF MOD(n$, d$) = 0 THEN
            count$ += 2
            IF d$ * d$ = n$ THEN count$ -= 1   ' a square root counts once
        END IF
        d$ += 1
    WEND
    RETURN count$
END DEF

[inits]
    LET WANTED# = 20
    LET found$ = 0
    LET record$ = 0         ' highest divisor count seen so far
    LET n$ = 0
    LET divs$ = 0
    LET output$ = ""

[main]
    WHILE found$ < WANTED#
        n$ += 1
        divs$ = FN CountDivisors$(n$)
        IF divs$ > record$ THEN
            record$ = divs$
            found$ += 1
            output$ += n$ + " "
        END IF
    WEND
    PRINT TRIM(output$)
END

' Output:
' 1 2 4 6 12 24 36 48 60 120 180 240 360 720 840 1260 1680 2520 5040 7560