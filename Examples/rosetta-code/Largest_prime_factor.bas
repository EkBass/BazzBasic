' ============================================
' Largest prime factor (port of the CBASIC Rosetta Code solution)
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' Returns the largest prime factor of n$, or n$ itself if it is prime.
' Trial division: every factor found is divided out completely, so the
' remaining divisors that can still divide n$ are always prime.
DEF FN LargestPrimeFactor$(n$)
    LET i$ = 2
    LET largest$ = 0

    WHILE i$ * i$ <= n$
        WHILE MOD(n$, i$) = 0
            largest$ = i$
            n$ = n$ / i$
        WEND
        i$ += 1
    WEND

    ' Whatever is left above 1 is itself a prime, bigger than any found so far
    IF n$ > 1 THEN largest$ = n$
    RETURN largest$
END DEF

[inits]
    DIM candidates$
    candidates$(0) = 600851475143   ' Project Euler Problem 3
    candidates$(1) = 6857           ' prime number
    candidates$(2) = 64             ' repeated prime factors and perfect square

    LET candidate$ = 0
    LET result$ = 0

[main]
    FOR i$ = 0 TO LEN(candidates$()) - 1
        candidate$ = candidates$(i$)
        result$ = FN LargestPrimeFactor$(candidate$)
        PRINT FSTRING("The largest prime factor of {{-candidate$-}} = {{-result$-}}")
    NEXT
END

' Output:
' The largest prime factor of 600851475143 = 6857
' The largest prime factor of 6857 = 6857
' The largest prime factor of 64 = 2