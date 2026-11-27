' ============================================
' https://rosettacode.org/wiki/Magic_constant
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' Magic constant of the n-th magic square, counting from order 3.
' n = 1 -> order 3 -> 15
DEF FN MagicConstant$(n$)
    LET order$ = n$ + 2
    RETURN order$ * (POW(order$, 2) + 1) / 2
END DEF

' Smallest order k for which k*(k^2+1)/2 + 2 >= x
' (same condition as the Yabasic original).
' A cube-root estimate jumps close to the answer, then a short
' WHILE walks forward to the exact value.
DEF FN InverseMagic$(x$)
    LET k$ = MAX(0, FLOOR(POW(2 * x$, 1 / 3)) - 2)
    WHILE k$ * (POW(k$, 2) + 1) / 2 + 2 < x$
        k$ += 1
    WEND
    RETURN k$
END DEF

' Right-align a value into a field of given width (replaces USING "###")
DEF FN PadLeft$(value$, width$)
    LET s$ = STR(value$)
    IF LEN(s$) >= width$ THEN RETURN s$
    RETURN REPEAT(" ", width$ - LEN(s$)) + s$
END DEF

[inits]
    LET FIRST_COUNT# = 20
    LET MAX_EXP#     = 20

[main]
    PRINT "The first 20 magic constants are: "
    FOR n$ = 1 TO FIRST_COUNT#
        PRINT FN MagicConstant$(n$); " ";
    NEXT
    PRINT ""
    PRINT "The 1,000th magic constant is "; FN MagicConstant$(1000)
    PRINT ""

    FOR e$ = 1 TO MAX_EXP#
        PRINT "10^"; FN PadLeft$(e$, 2); ": "; FN PadLeft$(FN InverseMagic$(POW(10, e$)), 9)
    NEXT
END

' Output:
' The first 20 magic constants are:
' 15 34 65 111 175 260 369 505 671 870 1105 1379 1695 2056 2465 2925 3439 4010 4641 5335
' The 1,000th magic constant is 503006505
'
' 10^ 1:         3
' 10^ 2:         6
' 10^ 3:        13
' 10^ 4:        28
' 10^ 5:        59
' 10^ 6:       126
' 10^ 7:       272
' 10^ 8:       585
' 10^ 9:      1260
' 10^10:      2715
' 10^11:      5849
' 10^12:     12600
' 10^13:     27145
' 10^14:     58481
' 10^15:    125993
' 10^16:    271442
' 10^17:    584804
' 10^18:   1259922
' 10^19:   2714418
' 10^20:   5848036