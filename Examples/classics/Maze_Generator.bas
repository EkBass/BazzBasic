' BazzBasic version 1.3b
' https://ekbass.github.io/BazzBasic/
' ============================================
' Maze Generator
' Original BASIC by Joe Wingbermuehle
' Translated to BazzBasic
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Builds a random rectangular maze using a
' randomized growing-tree-style algorithm.
' Width and height MUST be odd numbers (>= 5).
'
' Cell legend in m$():
'   0 = uncarved wall      (rendered as "[]")
'   1 = carved corridor    (rendered as "  ")
'   2 = outer ring border  (rendered as "  ")
' ============================================

[inits]
    LET w$ = 0          ' Maze width  (odd, >= 5)
    LET h$ = 0          ' Maze height (odd, >= 5)
    LET f$ = 0          ' Cells still uncarved (algorithm sentinel)
    LET x$ = 0          ' Carver cursor X
    LET y$ = 0          ' Carver cursor Y
    LET d$ = 0          ' Carving direction: 1=right 2=left 3=down 4=up
    LET i$ = 0          ' Failed-attempt counter inside one carve session

    DIM m$              ' Maze grid m$(x, y)

[input]
    INPUT "Width  (odd, >= 5): ", w$
    INPUT "Height (odd, >= 5): ", h$
    w$ = VAL(w$)
    h$ = VAL(h$)
    IF w$ < 5 OR h$ < 5 OR MOD(w$, 2) = 0 OR MOD(h$, 2) = 0 THEN
        PRINT "Both width and height must be odd numbers, 5 or larger."
        PRINT ""
        GOTO [input]
    END IF

[setup]
    ' Fill grid with 0 (uncarved walls), then mark the
    ' outermost ring as 2 (border / do not carve through).
    FOR yy$ = 1 TO h$
        FOR xx$ = 1 TO w$
            m$(xx$, yy$) = 0
        NEXT
        m$(1,  yy$) = 2
        m$(w$, yy$) = 2
    NEXT
    FOR xx$ = 1 TO w$
        m$(xx$, 1)  = 2
        m$(xx$, h$) = 2
    NEXT

    ' Drop the carving seed at (3,3) and count the cells
    ' that still have to become corridor before we are done.
    m$(3, 3) = 1
    f$ = ((w$ - 3) / 2) * ((h$ - 3) / 2) - 1

[carving]
    ' Sweep every odd cell as a potential seed for the carver.
    ' Re-sweep until every carvable cell has been reached.
    FOR sy$ = 3 TO h$ - 2 STEP 2
        FOR sx$ = 3 TO w$ - 2 STEP 2
            GOSUB [sub:carve]
        NEXT
    NEXT
    IF f$ > 0 THEN GOTO [carving]

    ' Punch the entry on the left wall and the exit on the right wall
    m$(2,      3)      = 1
    m$(w$ - 1, h$ - 2) = 1

[render]
    FOR yy$ = 1 TO h$
        FOR xx$ = 1 TO w$
            IF m$(xx$, yy$) = 0 THEN
                PRINT "[]";
            ELSE
                PRINT "  ";
            END IF
        NEXT
        PRINT ""
    NEXT

END

' ============================================
' Subroutine: [sub:carve]
'   Inputs : sx$, sy$  - seed cell to grow from
'   Effect : extends the maze from the seed for as long as
'            possible by stepping two cells at a time and
'            opening the wall in between.
' Notes:
'   - Shares scope with the main program, so it reads/writes
'     m$, f$, x$, y$, d$, i$.
'   - The seed loop variables sx$/sy$ MUST stay distinct from
'     the cursor variables x$/y$ because GOSUB does not get a
'     fresh scope.
' ============================================
[sub:carve]
    x$ = sx$
    y$ = sy$
    ' We only extend from cells that are already part of the maze.
    IF m$(x$, y$) <> 1 THEN RETURN

[carve:pickDir]
    ' Pick a fresh random direction and reset the attempt counter
    d$ = RND(4) + 1
    i$ = 0

    ' Mark current cell as corridor.
    ' First time we touch a fresh cell, count it down from f$.
    IF m$(x$, y$) = 0 THEN f$ -= 1
    m$(x$, y$) = 1

[carve:try]
    ' Attempt to carve in direction d$. The neighbour cell at +/-1
    ' is the wall; the cell at +/-2 is the next corridor square.
    ' Both must currently be 0 for the move to be legal.
    IF d$ = 1 THEN
        ' RIGHT
        IF m$(x$ + 1, y$) + m$(x$ + 2, y$) = 0 THEN
            m$(x$ + 1, y$) = 1
            x$ += 2
            GOTO [carve:pickDir]
        END IF
    ELSEIF d$ = 2 THEN
        ' LEFT
        IF m$(x$ - 1, y$) + m$(x$ - 2, y$) = 0 THEN
            m$(x$ - 1, y$) = 1
            x$ -= 2
            GOTO [carve:pickDir]
        END IF
    ELSEIF d$ = 3 THEN
        ' DOWN
        IF m$(x$, y$ + 1) + m$(x$, y$ + 2) = 0 THEN
            m$(x$, y$ + 1) = 1
            y$ += 2
            GOTO [carve:pickDir]
        END IF
    ELSEIF d$ = 4 THEN
        ' UP
        IF m$(x$, y$ - 1) + m$(x$, y$ - 2) = 0 THEN
            m$(x$, y$ - 1) = 1
            y$ -= 2
            GOTO [carve:pickDir]
        END IF
    END IF

    ' Direction was blocked. Bail out after the original's 4 retries
    ' (i$ counts 0..4), otherwise rotate the direction and try again.
    ' MOD(d$ + 1, 4) + 1 mirrors the original's "((D+1) AND 3) + 1",
    ' which yields a 2-cycle pair {1<->3, 2<->4} rather than a full
    ' 4-cycle. Faithful to the original; the outer re-sweep loop
    ' compensates for any cells left unreached on a given pass.
    IF i$ = 4 THEN RETURN
    d$ = MOD(d$ + 1, 4) + 1
    i$ += 1
    GOTO [carve:try]
RETURN

' Output (sample, 7 x 7 — actual maze varies each run):
' Width  (odd, >= 5): 7
' Height (odd, >= 5): 7
'               
'   [][][][][]  
'           []  
'   [][][]  []  
'   []          
'   [][][][][]  
'