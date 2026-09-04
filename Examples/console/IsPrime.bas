' ============================================
' Is Prime — BazzBasic
' https://github.com/EkBass/BazzBasic
' ============================================

' The recursive version needs the helper since BazzBasic functions can't hold state between calls — the helper carries the current divisor `d$` as a parameter down the call chain.
DEF FN IsPrimeHelper$(n$, d$)
    IF d$ * d$ > n$ THEN RETURN 1
    IF MOD(n$, d$) = 0 THEN RETURN 0
    RETURN FN IsPrimeHelper$(n$, d$ + 2)
END DEF

DEF FN IsPrimeRecursive$(n$)
    IF n$ < 2 THEN RETURN 0
    IF n$ = 2 THEN RETURN 1
    IF MOD(n$, 2) = 0 THEN RETURN 0
    RETURN FN IsPrimeHelper$(n$, 3)
END DEF

DEF FN IsPrimeIterative$(n$)
    IF n$ < 2 THEN RETURN 0
    IF n$ = 2 THEN RETURN 1
    IF MOD(n$, 2) = 0 THEN RETURN 0
    LET i$ = 3
    WHILE i$ * i$ <= n$
        IF MOD(n$, i$) = 0 THEN RETURN 0
        i$+= 2
    WEND
    RETURN 1
END DEF

[main]
    PRINT "Prime numbers up to 50:"
    PRINT " Recursive: ";
    FOR n$ = 2 TO 50
        IF FN IsPrimeRecursive$(n$) THEN PRINT n$; " ";
    NEXT
    PRINT ""

    PRINT " Iterative: ";
    FOR n$ = 2 TO 50
        IF FN IsPrimeIterative$(n$) THEN PRINT n$; " ";
    NEXT
    PRINT ""
END
