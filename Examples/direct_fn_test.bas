REM Direct function test (no library)

DEF FN testadd$(x$, y$)
    RETURN x$ + y$
END DEF

LET a$ = 5
LET b$ = 3

PRINT "Result: "; FN testadd$(a$, b$)
END
