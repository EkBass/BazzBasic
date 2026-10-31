' ============================================
' ROSETTA: https://rosettacode.org/wiki/10001th_prime
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Finds and prints the 10001st prime number using trial division by odd numbers.
' CATEGORY: math
' TAGS: prime numbers, trial division, nth prime
' MINVERSION: 1.5
' ============================================
' Task: find and show the 10001st prime number.

' Trial division by odd numbers up to the square root of n$
DEF FN IsPrime$(n$)
    IF n$ < 2 THEN RETURN FALSE
    IF n$ = 2 THEN RETURN TRUE
    IF MOD(n$, 2) = 0 THEN RETURN FALSE
    LET d$ = 3
    LET prime$ = TRUE
    WHILE prime$ AND d$ * d$ <= n$
        IF MOD(n$, d$) = 0 THEN prime$ = FALSE
        d$ += 2
    WEND
    RETURN prime$
END DEF

[inits]
    LET TARGET# = 10001
    LET count$ = 1          ' 2 is already counted as the first prime
    LET candidate$ = 1

[main]
    ' After 2, only odd numbers can be prime
    WHILE count$ < TARGET#
        candidate$ += 2
        IF FN IsPrime$(candidate$) THEN count$ += 1
    WEND
    PRINT FSTRING("Prime number {{-TARGET#-}} is {{-candidate$-}}")
END

' Output:
' Prime number 10001 is 104743