' ============================================
' https://rosettacode.org/wiki/A%2BB
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    LET a$ = 0
    LET b$ = 0

[main]
    INPUT "Enter two integers (-1000 to 1000) separated by a space: ", a$, b$
    LET a$ = VAL(a$)
    LET b$ = VAL(b$)
    IF a$ < -1000 OR a$ > 1000 OR b$ < -1000 OR b$ > 1000 THEN
        PRINT "Values must be between -1000 and 1000."
        GOTO [main]
    END IF
    PRINT "Their sum is "; a$ + b$
END
' Output:
' Enter two integers (-1000 to 1000) separated by a space: 500 -123
' Their sum is 377
