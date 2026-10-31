' ============================================
' ROSETTA: https://rosettacode.org/wiki/Sum_of_squares
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Computes the sum of the squares of a numeric vector given as a comma-separated string, and of an empty vector, which gives 0.
' CATEGORY: math
' TAGS: sum of squares, vector, split, pow
' MINVERSION: 1.5
' ============================================

[inits]
    LET SEP# = ","
    DIM array$
    DIM empty$
    LET count$  = SPLIT(array$,  "1.0,2.0,3.0,4.0,5.0,6.0", SEP#)
    LET ecount$ = SPLIT(empty$, "", SEP#)
    LET sum$    = 0
    LET esum$   = 0

[main]
    FOR i$ = 0 TO count$ - 1
        sum$ += POW(array$(i$), 2)
    NEXT

    FOR i$ = 0 TO ecount$ - 1
        esum$ += POW(empty$(i$), 2)
    NEXT

[output]
    PRINT "Sum of squares (full vector):  "; sum$
    PRINT "Sum of squares (empty vector): "; esum$
END

' Output:
' Sum of squares (full vector):  91
' Sum of squares (empty vector): 0