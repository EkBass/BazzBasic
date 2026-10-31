' ============================================
' ROSETTA: https://rosettacode.org/wiki/Catalan_numbers/Pascal%27s_triangle
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the first 15 Catalan numbers, computed from the central binomial coefficients of Pascal's triangle.
' CATEGORY: math
' TAGS: catalan numbers, pascal's triangle, combinatorics, binomial coefficients
' MINVERSION: 1.5
' ============================================

' Right-align a value into a field of given width (replaces PRINT USING)
DEF FN PadLeft$(value$, width$)
    RETURN RIGHT(REPEAT(" ", width$) + STR(value$), width$)
END DEF

[inits]
    LET N# = 15
    DIM t$
    FOR i$ = 0 TO N# + 1
        t$(i$) = 0
    NEXT
    t$(1) = 1

[main]
    PRINT "The first "; N#; " Catalan numbers are:"
    PRINT ""
    FOR i$ = 1 TO N#
        ' Build the next row of Pascal's triangle
        FOR j$ = i$ TO 1 STEP -1
            t$(j$) = t$(j$) + t$(j$ - 1)
        NEXT
        ' Mirror the centre value, then build one row further
        t$(i$ + 1) = t$(i$)
        FOR j$ = i$ + 1 TO 1 STEP -1
            t$(j$) = t$(j$) + t$(j$ - 1)
        NEXT
        ' Catalan number = central binomial minus its neighbour
        PRINT FN PadLeft$(i$, 3); ": "; FN PadLeft$(t$(i$ + 1) - t$(i$), 9)
    NEXT
END

' Output:
' The first 15 Catalan numbers are:
'
'   1:         1
'   2:         2
'   3:         5
'   4:        14
'   5:        42
'   6:       132
'   7:       429
'   8:      1430
'   9:      4862
'  10:     16796
'  11:     58786
'  12:    208012
'  13:    742900
'  14:   2674440
'  15:   9694845