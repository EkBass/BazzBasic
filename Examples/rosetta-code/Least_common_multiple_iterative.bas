' ============================================
' Least common multiple - iterative solution
' https://rosettacode.org/wiki/Least_common_multiple
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' Count multiples of the larger number until one is
' also divisible by the smaller number.
DEF FN Lcm$(m$, n$)
    LET tmp$
    LET count$ = 1
    IF m$ = 0 OR n$ = 0 THEN RETURN 0
    ' Make m$ the larger one to minimise iterations
    IF m$ < n$ THEN
        tmp$ = m$
        m$ = n$
        n$ = tmp$
    END IF
    WHILE MOD(m$ * count$, n$) <> 0
        count$ += 1
    WEND
    RETURN m$ * count$
END DEF

[main]
    PRINT "lcm(12, 18) = "; FN Lcm$(12, 18)
    PRINT "lcm(15, 12) = "; FN Lcm$(15, 12)
    PRINT "lcm(10, 14) = "; FN Lcm$(10, 14)
END

' Output:
' lcm(12, 18) = 36
' lcm(15, 12) = 60
' lcm(10, 14) = 70