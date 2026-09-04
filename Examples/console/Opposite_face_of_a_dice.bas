' ============================================================
' Opposite face of a dice
' EkBazz 2026, public domain
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================================
DEF FN DiceOppositeSide$(n$)
    LET opposites$ = "654321"
    IF BETWEEN(n$, 1, 6) THEN
        RETURN MID(opposites$, n$, 1)
    ELSE
        RETURN 0
    END IF
END DEF

[inits]
    LET face$
    LET result$

[main]
    FOR face$ = 1 TO 6
        result$ = FN DiceOppositeSide$(face$)
        PRINT "Face " + STR(face$) + " → opposite: " + STR(result$)
    NEXT
END

' Output:
' Face 1 → opposite: 6
' Face 2 → opposite: 5
' Face 3 → opposite: 4
' Face 4 → opposite: 3
' Face 5 → opposite: 2
' Face 6 → opposite: 1