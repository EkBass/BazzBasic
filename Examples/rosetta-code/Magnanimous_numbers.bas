' https://ekbass.github.io/BazzBasic/
' https://rosettacode.org/wiki/Magnanimous_numbers

DEF FN IsPrime$(x$)
    IF x$ < 2 THEN RETURN FALSE
    IF x$ = 2 THEN RETURN TRUE
    IF MOD(x$, 2) = 0 THEN RETURN FALSE
    LET d$ = 3
    LET ok$ = TRUE
    WHILE d$ * d$ <= x$
        IF MOD(x$, d$) = 0 THEN
            ok$ = FALSE
            EXIT WHILE
        END IF
        d$ = d$ + 2
    WEND
    RETURN ok$
END DEF

DEF FN IsMag$(n$)
    LET s$ = STR(n$)
    IF LEN(s$) <= 1 THEN RETURN TRUE
    LET ok$ = TRUE
    FOR i$ = 1 TO LEN(s$) - 1
        IF NOT (FN IsPrime$(VAL(LEFT(s$, i$)) + VAL(MID(s$, i$ + 1)))) THEN
            ok$ = FALSE
            EXIT FOR
        END IF
    NEXT
    RETURN ok$
END DEF

[inits]
    LET arg$
    LET bound$
    LET n$
    LET count$
    LET shown$
    LET line$

[main]
    bound$ = 100000
    IF ARGCOUNT >= 1 THEN
        arg$ = ARGS(0)
        IF arg$ <> STR(VAL(arg$)) OR VAL(arg$) <> INT(VAL(arg$)) OR VAL(arg$) < 0 THEN
            PRINT "error: bound must be an integer >= 0"
            END
        END IF
        bound$ = VAL(arg$)
    END IF
    PRINT "First 50 magnanimous numbers:"
    count$ = 0
    shown$ = 0
    line$ = ""
    FOR n$ = 0 TO bound$
        IF FN IsMag$(n$) THEN
            count$ = count$ + 1
            IF shown$ < 50 THEN
                line$ = line$ + n$ + " "
                shown$ = shown$ + 1
                IF MOD(shown$, 10) = 0 THEN
                    PRINT RTRIM(line$)
                    line$ = ""
                END IF
            END IF
        END IF
    NEXT
    IF LEN(line$) > 0 THEN PRINT RTRIM(line$)
    PRINT "Total magnanimous numbers from 0 to "; bound$; ": "; count$
    LET kw$ = WAITKEY()
END

' Output:
' First 50 magnanimous numbers:
' 0 1 2 3 4 5 6 7 8 9
' 11 12 14 16 20 21 23 25 29 30
' 32 34 38 41 43 47 49 50 52 56
' 58 61 65 67 70 74 76 83 85 89
' 92 94 98 101 110 112 116 118 130 136
' Total magnanimous numbers from 0 to 100000: 338
