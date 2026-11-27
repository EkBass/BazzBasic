' https://ekbass.github.io/BazzBasic/
' https://rosettacode.org/wiki/Magic_squares_of_odd_order

[inits]
    DIM sq$

    LET ans$, n$, r$, c$, pr$, pc$
    LET k$, v$, w$, line$, sum$
    LET magic$, ok$, i$

[main]
    INPUT "The square order: ", ans$
    PRINT ""
    n$ = VAL(ans$)
    IF n$ <> INT(n$) THEN
        PRINT "error: size is not odd or size is smaller then 3"
        END
    END IF
    IF n$ < 3 THEN
        PRINT "error: size is not odd or size is smaller then 3"
        END
    END IF
    IF MOD(n$, 2) = 0 THEN
        PRINT "error: size is not odd or size is smaller then 3"
        END
    END IF
    ' clear the grid (two-index array, 1-based row/col)
    FOR r$ = 1 TO n$
        FOR c$ = 1 TO n$
            sq$(r$, c$) = 0
        NEXT
    NEXT
    ' Siamese method: 1 at top middle, then up-and-right with wrap-around
    r$ = 1
    c$ = INT((n$ + 1) / 2)
    sq$(r$, c$) = 1
    FOR k$ = 2 TO n$ * n$
        pr$ = r$
        pc$ = c$
        r$ = r$ - 1
        IF r$ < 1 THEN r$ = n$
        c$ = c$ + 1
        IF c$ > n$ THEN c$ = 1
        IF sq$(r$, c$) <> 0 THEN
            r$ = pr$ + 1
            IF r$ > n$ THEN r$ = 1
            c$ = pc$
        END IF
        sq$(r$, c$) = k$
    NEXT
    ' print the grid, columns padded to the width of n*n
    w$ = LEN(STR(n$ * n$))
    FOR r$ = 1 TO n$
        line$ = ""
        FOR c$ = 1 TO n$
            v$ = sq$(r$, c$)
            line$ = line$ + LEFT(REPEAT(" ", w$), w$ - LEN(STR(v$))) + v$ + " "
        NEXT
        PRINT RTRIM(line$)
    NEXT
    PRINT ""
    magic$ = n$ * (n$ * n$ + 1) / 2
    PRINT "Magic number: "; magic$
    ' verification: row, column and both main diagonal sums
    ok$ = TRUE
    line$ = "Row sums: "
    FOR r$ = 1 TO n$
        sum$ = 0
        FOR c$ = 1 TO n$
            sum$ = sum$ + sq$(r$, c$)
        NEXT
        IF sum$ <> magic$ THEN ok$ = FALSE
        line$ = line$ + sum$ + " "
    NEXT
    PRINT RTRIM(line$)
    line$ = "Column sums: "
    FOR c$ = 1 TO n$
        sum$ = 0
        FOR r$ = 1 TO n$
            sum$ = sum$ + sq$(r$, c$)
        NEXT
        IF sum$ <> magic$ THEN ok$ = FALSE
        line$ = line$ + sum$ + " "
    NEXT
    PRINT RTRIM(line$)
    sum$ = 0
    FOR i$ = 1 TO n$
        sum$ = sum$ + sq$(i$, i$)
    NEXT
    IF sum$ <> magic$ THEN ok$ = FALSE
    line$ = "Diagonal sums: " + sum$ + " "
    sum$ = 0
    FOR i$ = 1 TO n$
        sum$ = sum$ + sq$(i$, n$ + 1 - i$)
    NEXT
    IF sum$ <> magic$ THEN ok$ = FALSE
    line$ = line$ + sum$
    PRINT line$
    IF ok$ THEN
        PRINT "All sums equal the magic number: yes"
    ELSE
        PRINT "All sums equal the magic number: no"
    END IF
END

' Output:
' The square order: 5
' 
' 17 24  1  8 15
' 23  5  7 14 16
'  4  6 13 20 22
' 10 12 19 21  3
' 11 18 25  2  9
' 
' Magic number: 65
' Row sums: 65 65 65 65 65
' Column sums: 65 65 65 65 65
' Diagonal sums: 65 65
' All sums equal the magic number: yes