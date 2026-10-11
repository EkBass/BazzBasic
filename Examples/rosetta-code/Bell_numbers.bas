' ============================================
' https://rosettacode.org/wiki/Bell_numbers
' BazzBasic: https://github.com/EkBass/BazzBasic
' Task: generate the Bell numbers with a Bell triangle, show the
'       first 15 of them and the first ten rows of the triangle.
' ============================================

[inits]
    LET ROWS# = 15              ' triangle rows built = Bell numbers shown
    LET SHOW_ROWS# = 10         ' triangle rows printed
    DIM tri$                    ' tri$(row, col)
    LET line$ = ""

[main]
    GOSUB [sub:BuildTriangle]

    PRINT "First "; SHOW_ROWS#; " rows of the Bell triangle:"
    FOR i$ = 0 TO SHOW_ROWS# - 1
        line$ = ""
        FOR j$ = 0 TO i$
            line$ += tri$(i$, j$) + " "
        NEXT
        PRINT TRIM(line$)
    NEXT

    PRINT
    PRINT "First "; ROWS#; " Bell numbers:"
    FOR i$ = 0 TO ROWS# - 1
        PRINT "B("; RIGHT(" " + i$, 2); ") = "; tri$(i$, 0)
    NEXT
END

' Each row starts with the last value of the row above; every next
' value is its left neighbour plus the value above that neighbour.
' The first column holds the Bell numbers.
[sub:BuildTriangle]
    tri$(0, 0) = 1
    FOR i$ = 1 TO ROWS# - 1
        tri$(i$, 0) = tri$(i$ - 1, i$ - 1)
        FOR j$ = 1 TO i$
            tri$(i$, j$) = tri$(i$, j$ - 1) + tri$(i$ - 1, j$ - 1)
        NEXT
    NEXT
RETURN

' Output:
' First 10 rows of the Bell triangle:
' 1
' 1 2
' 2 3 5
' 5 7 10 15
' 15 20 27 37 52
' 52 67 87 114 151 203
' 203 255 322 409 523 674 877
' 877 1080 1335 1657 2066 2589 3263 4140
' 4140 5017 6097 7432 9089 11155 13744 17007 21147
' 21147 25287 30304 36401 43833 52922 64077 77821 94828 115975
'
' First 15 Bell numbers:
' B( 0) = 1
' B( 1) = 1
' B( 2) = 2
' B( 3) = 5
' B( 4) = 15
' B( 5) = 52
' B( 6) = 203
' B( 7) = 877
' B( 8) = 4140
' B( 9) = 21147
' B(10) = 115975
' B(11) = 678570
' B(12) = 4213597
' B(13) = 27644437
' B(14) = 190899322