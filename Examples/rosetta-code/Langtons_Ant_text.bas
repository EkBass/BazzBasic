' ============================================
' Langton's Ant - text version
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Same rules as the graphical version. The whole walk is simulated
' first, then only the part of the grid the ant has blackened is
' printed: "#" = black cell, " " = white cell.

[inits]
    LET GRID# = 100

    ' Directions: 0 = north, 1 = east, 2 = south, 3 = west
    DIM dx$
    DIM dy$
    dx$(0) =  0 : dy$(0) = -1
    dx$(1) =  1 : dy$(1) =  0
    dx$(2) =  0 : dy$(2) =  1
    dx$(3) = -1 : dy$(3) =  0

    DIM plane$                          ' 0 = white, 1 = black
    FOR x$ = 0 TO GRID# - 1
        FOR y$ = 0 TO GRID# - 1
            plane$(x$, y$) = 0
        NEXT
    NEXT

    LET antX$  = GRID# / 2
    LET antY$  = GRID# / 2
    LET dir$   = 0
    LET steps$ = 0

    ' Bounding box of the cells the ant has visited
    LET minX$ = antX$, maxX$ = antX$
    LET minY$ = antY$, maxY$ = antY$
    LET row$  = ""

[main]
    WHILE BETWEEN(antX$, 0, GRID# - 1) AND BETWEEN(antY$, 0, GRID# - 1)
        IF plane$(antX$, antY$) = 0 THEN
            dir$ = (dir$ + 1) % 4       ' white: turn right
        ELSE
            dir$ = (dir$ + 3) % 4       ' black: turn left
        END IF
        plane$(antX$, antY$) = 1 - plane$(antX$, antY$)

        minX$ = MIN(minX$, antX$) : maxX$ = MAX(maxX$, antX$)
        minY$ = MIN(minY$, antY$) : maxY$ = MAX(maxY$, antY$)

        antX$ += dx$(dir$)
        antY$ += dy$(dir$)
        steps$ += 1
    WEND

    FOR y$ = minY$ TO maxY$
        row$ = ""
        FOR x$ = minX$ TO maxX$
            IF plane$(x$, y$) = 1 THEN
                row$ += "#"
            ELSE
                row$ += " "
            END IF
        NEXT
        PRINT RTRIM(row$)
    NEXT
    PRINT
    PRINT "The ant left the grid after "; steps$; " steps."
END