' ============================================
' https://rosettacode.org/wiki/Square_but_not_cube
' BazzBasic: https://github.com/EkBass/BazzBasic
' Show the first 30 positive integers which are squares but not cubes,
' and mark the squares that are also cubes along the way.
' ============================================

[inits]
    LET LIMIT# = 30     ' how many square-but-not-cube numbers to show
    LET n$     = 0      ' base being squared
    LET sq$    = 0      ' n$ squared
    LET cb$    = 0      ' nearest integer cube root of sq$
    LET found$ = 0      ' squares-but-not-cubes listed so far

[main]
    WHILE found$ < LIMIT#
        n$ += 1
        sq$ = n$ * n$
        cb$ = ROUND(POW(sq$, 1 / 3))

        IF cb$ * cb$ * cb$ = sq$ THEN
            ' Both a square and a cube - mark it, don't count it
            PRINT FSTRING("({{-n$-}}^2 = {{-sq$-}} = {{-cb$-}}^3)")
        ELSE
            found$ += 1
            PRINT RIGHT("  " + n$, 2); " ->"; RIGHT("     " + sq$, 5)
        END IF
    WEND
END

' Output:
' (1^2 = 1 = 1^3)
'  2 ->    4
'  3 ->    9
'  4 ->   16
'  5 ->   25
'  6 ->   36
'  7 ->   49
' (8^2 = 64 = 4^3)
'  9 ->   81
' 10 ->  100
' 11 ->  121
' 12 ->  144
' 13 ->  169
' 14 ->  196
' 15 ->  225
' 16 ->  256
' 17 ->  289
' 18 ->  324
' 19 ->  361
' 20 ->  400
' 21 ->  441
' 22 ->  484
' 23 ->  529
' 24 ->  576
' 25 ->  625
' 26 ->  676
' (27^2 = 729 = 9^3)
' 28 ->  784
' 29 ->  841
' 30 ->  900
' 31 ->  961
' 32 -> 1024
' 33 -> 1089