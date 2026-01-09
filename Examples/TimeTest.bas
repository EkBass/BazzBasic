REM ============================================
REM Test: TIME and TICKS functions
REM ============================================

PRINT "Testing TIME and TICKS functions"
PRINT "================================"
PRINT ""

REM Test TIME with different formats
PRINT "TIME tests:"
PRINT "  Default TIME():     " + TIME()
PRINT "  TIME(HH:mm:ss):     " + TIME("HH:mm:ss")
PRINT "  TIME(dd.MM.yyyy):   " + TIME("dd.MM.yyyy")
PRINT "  TIME(yyyy-MM-dd):   " + TIME("yyyy-MM-dd")
PRINT "  TIME(dddd):         " + TIME("dddd")
PRINT "  TIME(MMMM):         " + TIME("MMMM")
PRINT "  TIME(dd MMMM yyyy): " + TIME("dd MMMM yyyy")
PRINT "  TIME(HH:mm):        " + TIME("HH:mm")
PRINT ""

REM Test TICKS
PRINT "TICKS tests:"
LET start$ = TICKS
PRINT "  Start ticks: " + STR(start$)

REM Do some work to pass time
LET x$ = 0
FOR i$ = 1 TO 10000
    x$ = x$ + 1
NEXT

LET end$ = TICKS
PRINT "  End ticks:   " + STR(end$)
PRINT "  Elapsed:     " + STR(end$ - start$) + " ms"
PRINT ""

REM Practical example: timing a loop
PRINT "Timing example:"
LET t1$ = TICKS
LET sum$ = 0
FOR i$ = 1 TO 50000
    sum$ = sum$ + i$
NEXT
LET t2$ = TICKS
PRINT "  Sum of 1-50000: " + STR(sum$)
PRINT "  Time taken:     " + STR(t2$ - t1$) + " ms"
PRINT ""

PRINT "All tests completed!"
END
