' ============================================
' ROSETTA: https://rosettacode.org/wiki/Egyptian_division
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Divides 580 by 34 using Egyptian division (a table of doublings and powers of two) and prints the quotient and remainder.
' CATEGORY: math
' TAGS: egyptian division, doubling, powers of two, integer division
' MINVERSION: 1.5
' ============================================

[inits]
    LET DIVIDEND# = 580
    LET DIVISOR#  = 34

    DIM powers$                     ' 1, 2, 4, 8, ...
    DIM doublings$                  ' divisor, 2*divisor, 4*divisor, ...
    LET last$      = 0              ' index of the last table row
    LET answer$    = 0
    LET acc$       = 0
    LET remainder$ = 0

[build_table]
    ' Keep doubling while the next row still fits into the dividend
    powers$(0)    = 1
    doublings$(0) = DIVISOR#
    WHILE doublings$(last$) * 2 <= DIVIDEND#
        last$ += 1
        powers$(last$)    = powers$(last$ - 1) * 2
        doublings$(last$) = doublings$(last$ - 1) * 2
    WEND

[divide]
    ' Walk the table from the bottom up, taking every row that still fits
    FOR k$ = last$ TO 0 STEP -1
        IF acc$ + doublings$(k$) <= DIVIDEND# THEN
            acc$    += doublings$(k$)
            answer$ += powers$(k$)
        END IF
    NEXT
    remainder$ = DIVIDEND# - acc$

[output]
    PRINT FSTRING("{{-DIVIDEND#-}} divided by {{-DIVISOR#-}} using Egyptian division returns {{-answer$-}} remainder {{-remainder$-}}")
END

' Output:
' 580 divided by 34 using Egyptian division returns 17 remainder 2
