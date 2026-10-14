' ============================================
' https://rosettacode.org/wiki/Generate_Chess960_starting_position
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Bishops go on one even and one odd square (opposite colours),
' queen and knights on random free squares, and the three squares
' left over get R, K, R from left to right - so the king always
' stands between the rooks. All 960 positions are equally likely.

[inits]
    LET POSITIONS# = 5
    DIM board$
    LET piece$ = ""
    LET line$ = ""
    LET empties$ = 0
    LET target$ = 0
    LET n$ = 0

[main]
    FOR p$ = 1 TO POSITIONS#
        GOSUB [sub:generate]
        PRINT line$
    NEXT
END

[sub:generate]
    FOR i$ = 0 TO 7
        board$(i$) = "."
    NEXT
    board$(RND(4) * 2) = "B"        ' even square
    board$(RND(4) * 2 + 1) = "B"    ' odd square
    piece$ = "Q" : GOSUB [sub:placeRandom]
    piece$ = "N" : GOSUB [sub:placeRandom]
    piece$ = "N" : GOSUB [sub:placeRandom]
    ' Remaining three squares, left to right: R K R
    n$ = 1
    FOR i$ = 0 TO 7
        IF board$(i$) = "." THEN
            board$(i$) = MID("RKR", n$, 1)
            n$ += 1
        END IF
    NEXT
    line$ = ""
    FOR i$ = 0 TO 7
        line$ += board$(i$)
    NEXT
RETURN

' Put piece$ on a randomly chosen empty square
[sub:placeRandom]
    empties$ = 0
    FOR i$ = 0 TO 7
        IF board$(i$) = "." THEN empties$ += 1
    NEXT
    target$ = RND(empties$)
    n$ = 0
    FOR i$ = 0 TO 7
        IF board$(i$) = "." THEN
            IF n$ = target$ THEN board$(i$) = piece$
            n$ += 1
        END IF
    NEXT
RETURN

' Output (random, example run):
' NRKQRNBB
' RBNQKNBR
' RNNKQRBB
' RNNKBRQB
' NQRKBBNR
