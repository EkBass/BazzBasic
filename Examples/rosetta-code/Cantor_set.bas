' ============================================
' https://rosettacode.org/wiki/Cantor_set
' BazzBasic: https://github.com/EkBass/BazzBasic
' Draw a Cantor set.
' ============================================

[inits]
    LET LEVELS# = 4
    LET WIDTH#  = POW(3, LEVELS# - 1)

    LET row$   = REPEAT("#", WIDTH#)
    LET seg$   = WIDTH#
    LET start$ = 0

[main]
    PRINT row$
    WHILE seg$ > 1
        seg$ = INT(seg$ / 3)
        start$ = 1
        WHILE start$ < WIDTH# - seg$
            start$ += seg$
            ' Blank out the middle third of the current segment
            row$ = LEFT(row$, start$ - 1) + REPEAT(" ", seg$) + MID(row$, start$ + seg$)
            start$ += seg$
        WEND
        PRINT row$
    WEND
END

' Output:
' ###########################
' #########         #########
' ###   ###         ###   ###
' # #   # #         # #   # #