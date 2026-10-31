' ============================================
' ROSETTA: https://rosettacode.org/wiki/Dutch_national_flag_problem
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Sorts a random line of red, white and blue balls into Dutch flag order with Dijkstra's three-way partition and verifies the result.
' CATEGORY: algorithms
' TAGS: dutch national flag, three-way partition, sorting, random
' MINVERSION: 1.5
' ============================================

[inits]
    LET N#      = 20
    LET NAMES#  = "BWR"     ' 0 = blue, 1 = white, 2 = red

    DIM balls$
    LET b$      = 0
    LET w$      = 0
    LET r$      = 0
    LET tmp$    = 0
    LET sorted$ = TRUE
    LET out$    = ""

[main]
    ' Generate a random sequence that is not already in flag order
    WHILE sorted$
        GOSUB [sub:fill]
        GOSUB [sub:check]
    WEND

    PRINT "Unsorted: ";
    GOSUB [sub:show]

    GOSUB [sub:flagSort]

    PRINT "Sorted:   ";
    GOSUB [sub:show]

    GOSUB [sub:check]
    IF sorted$ THEN
        PRINT "Order verified: correct"
    ELSE
        PRINT "Order verified: WRONG"
    END IF
END

[sub:fill]
    FOR i$ = 0 TO N# - 1
        balls$(i$) = RND(3)
    NEXT
RETURN

[sub:check]
    sorted$ = TRUE
    FOR i$ = 1 TO N# - 1
        IF balls$(i$) < balls$(i$ - 1) THEN sorted$ = FALSE
    NEXT
RETURN

[sub:show]
    out$ = ""
    FOR i$ = 0 TO N# - 1
        out$ += MID(NAMES#, balls$(i$) + 1, 1)
    NEXT
    PRINT out$
RETURN

[sub:flagSort]
    b$ = 0
    w$ = 0
    r$ = N# - 1
    WHILE w$ <= r$
        IF balls$(w$) = 0 THEN
            ' blue: swap to the front
            tmp$ = balls$(b$)
            balls$(b$) = balls$(w$)
            balls$(w$) = tmp$
            b$ += 1
            w$ += 1
        ELSEIF balls$(w$) = 1 THEN
            ' white: already in the middle
            w$ += 1
        ELSE
            ' red: swap to the back
            tmp$ = balls$(w$)
            balls$(w$) = balls$(r$)
            balls$(r$) = tmp$
            r$ -= 1
        END IF
    WEND
RETURN

' Output:
' Unsorted: WRWRRWWBBRBBWBBBWRBW
' Sorted:   BBBBBBBBWWWWWWWRRRRR
' Order verified: correct