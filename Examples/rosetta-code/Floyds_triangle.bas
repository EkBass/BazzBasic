' ============================================
' ROSETTA: https://rosettacode.org/wiki/Floyd%27s_triangle
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints Floyd's triangle of consecutive numbers, with right-aligned columns, for 5 rows and for 14 rows.
' CATEGORY: math
' TAGS: floyd's triangle, number triangle, right alignment, repeat
' MINVERSION: 1.5
' ============================================
' Each column is as wide as the number below it in the last row.
' The last row starts at n*(n-1)/2 + 1, so column c is as wide as
' that start value + c - 1. Numbers are right-aligned to that width
' and separated by one space.

DEF FN Floyd$(n$)
    LET lastStart$ = INT(n$ * (n$ - 1) / 2) + 1
    LET num$  = 1
    LET w$    = 0
    LET s$    = ""
    LET out$  = ""
    FOR row$ = 1 TO n$
        FOR col$ = 1 TO row$
            w$ = LEN(STR(lastStart$ + col$ - 1))
            s$ = STR(num$)
            out$ += REPEAT(" ", w$ - LEN(s$)) + s$
            IF col$ < row$ THEN out$ += " "
            num$ += 1
        NEXT
        IF row$ < n$ THEN out$ += "\n"
    NEXT
    RETURN out$
END DEF

[inits]
    DIM sizes$
        sizes$(0) = 5
        sizes$(1) = 14
    LET n$ = 0

[main]
    FOR i$ = 0 TO ROWCOUNT(sizes$()) - 1
        n$ = sizes$(i$)
        PRINT FSTRING("Floyd {{-n$-}}:")
        PRINT FN Floyd$(n$)
    NEXT
END

' Output:
' Floyd 5:
'  1
'  2  3
'  4  5  6
'  7  8  9 10
' 11 12 13 14 15
' Floyd 14:
'  1
'  2  3
'  4  5  6
'  7  8  9 10
' 11 12 13 14 15
' 16 17 18 19 20 21
' 22 23 24 25 26 27 28
' 29 30 31 32 33 34 35 36
' 37 38 39 40 41 42 43 44  45
' 46 47 48 49 50 51 52 53  54  55
' 56 57 58 59 60 61 62 63  64  65  66
' 67 68 69 70 71 72 73 74  75  76  77  78
' 79 80 81 82 83 84 85 86  87  88  89  90  91
' 92 93 94 95 96 97 98 99 100 101 102 103 104 105