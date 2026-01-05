DEF FN factorial$(n$)
    IF n$ <= 1 THEN
        RETURN 1
    END IF
    RETURN n$ * FN factorial$(n$ - 1)
END DEF

FOR i$ = 1 TO 10
    PRINT i$; "! = "; FN factorial$(i$)
NEXT
