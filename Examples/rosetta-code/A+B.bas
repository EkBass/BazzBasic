' ============================================
' ROSETTA: https://rosettacode.org/wiki/A%2BB
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Reads two integers between -1000 and 1000 and prints their sum, asking again if a value is out of range.
' CATEGORY: math
' TAGS: input, input validation, integer arithmetic
' MINVERSION: 1.5
' ============================================

[inits]
    LET a$ = 0
    LET b$ = 0

[main]
    INPUT "Enter two integers (-1000 to 1000) separated by a space: ", a$, b$
    a$ = VAL(a$)
    b$ = VAL(b$)
    IF NOT BETWEEN(a$, -1000, 1000) OR NOT BETWEEN(b$, -1000, 1000) THEN
        PRINT "Values must be between -1000 and 1000."
        GOTO [main]
    END IF
    PRINT "Their sum is "; a$ + b$
END

' Output:
' Enter two integers (-1000 to 1000) separated by a space: 500 -123
' Their sum is 377
