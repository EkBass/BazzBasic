REM === v1.3 features test ===

REM ROWCOUNT
DIM planets$
planets$(0, "name") = "Sun"      : planets$(0, "gravity") = 27.07
planets$(1, "name") = "Mercury"  : planets$(1, "gravity") = 0.38
planets$(2, "name") = "Earth"    : planets$(2, "gravity") = 1.00
LET rc$ = ROWCOUNT(planets$())
PRINT "ROWCOUNT: "; rc$

REM PI# constant
PRINT "PI# = "; PI#
PRINT "TAU# = "; TAU#

REM ARGCOUNT / ARGS
PRINT "ARGCOUNT = "; ARGCOUNT
IF ARGCOUNT > 0 THEN PRINT "ARGS(0) = "; ARGS(0)

REM FOR loop bug fix - early RETURN from FOR inside DEF FN
DEF FN CountTo$(target$)
    LET sum$ = 0
    FOR i$ = 1 TO 10
        IF i$ = target$ THEN RETURN sum$
        sum$ = sum$ + i$
    NEXT
    RETURN sum$
END DEF

LET r1$ = FN CountTo$(5)
LET r2$ = FN CountTo$(3)
PRINT "CountTo 5: "; r1$
PRINT "CountTo 3: "; r2$

PRINT "Done!"
END
