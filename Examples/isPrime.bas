DEF FN isPrime$(n$)
    IF n$ < 2 THEN
        RETURN 0
    END IF
    IF n$ = 2 THEN
        RETURN 1
    END IF
    IF n$ % 2 = 0 THEN
        RETURN 0
    END IF
    
    LET i$ = 3
    WHILE i$ * i$ <= n$
        IF n$ % i$ = 0 THEN
            RETURN 0
        END IF
        i$ = i$ + 2
    WEND
    RETURN 1
END DEF

PRINT "Prime numbers up to 50:"
FOR n$ = 2 TO 50
    IF FN isPrime$(n$) THEN
        PRINT n$; " ";
    END IF
NEXT
