DEF FN fib(n$)
    IF n$ <= 1 THEN
        RETURN n$
    END IF
    RETURN FN fib(n$ - 1) + FN fib(n$ - 2)
END DEF

PRINT "Fibonacci sequence:"
FOR i$ = 0 TO 15
    PRINT FN fib(i$); " ";
NEXT
