' https://ekbass.github.io/BazzBasic/
' https://rosettacode.org/wiki/Map_range

DEF FN MapRange$(v$, a1$, a2$, b1$, b2$)
    RETURN b1$ + (v$ - a1$) * (b2$ - b1$) / (a2$ - a1$)
END DEF

DEF FN Fixed1$(x$)
    LET r$ = ROUND(x$ * 10) / 10
    LET s$ = STR(r$)
    IF INSTR(s$, ".") = 0 THEN
        s$ = s$ + ".0"
    END IF
    RETURN s$
END DEF

[inits]
    LET i$ = 0
    LET degenerate$ = FALSE
    IF ARGCOUNT >= 1 THEN
        IF SAME(ARGS(0), "degenerate") THEN degenerate$ = TRUE
    END IF

[main]
    IF degenerate$ THEN
        PRINT "MapRange(5, 3, 3, 100, 200) = "; FN Fixed1$(FN MapRange$(5, 3, 3, 100, 200))
    ELSE
        FOR i$ = 0 TO 10
            PRINT i$; " maps to "; FN Fixed1$(FN MapRange$(i$, 0, 10, -1, 0))
        NEXT
    END IF

    LET kw$ = WAITKEY()
END

' Output:
' 0 maps to -1.0
' 1 maps to -0.9
' 2 maps to -0.8
' 3 maps to -0.7
' 4 maps to -0.6
' 5 maps to -0.5
' 6 maps to -0.4
' 7 maps to -0.3
' 8 maps to -0.2
' 9 maps to -0.1
' 10 maps to 0.0