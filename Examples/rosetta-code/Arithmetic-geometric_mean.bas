' ============================================
' https://rosettacode.org/wiki/Arithmetic-geometric_mean
' BazzBasic: https://github.com/EkBass/BazzBasic
' Task: write a function for the arithmetic-geometric mean
'       and demonstrate it with agm(1, 1/sqrt(2)).
' ============================================

' Iterate until the arithmetic mean stops shrinking. It decreases
' monotonically, so once it no longer does, we are at full precision.
DEF FN Agm$(a$, g$)
    LET an$ = MAX(a$, g$)       ' start with the larger value on the arithmetic side
    LET gn$ = MIN(a$, g$)
    LET prev$ = 0
    LET nextA$ = 0
    LET done$ = FALSE
    WHILE NOT done$
        prev$ = an$
        nextA$ = (an$ + gn$) / 2
        gn$ = SQR(an$ * gn$)
        an$ = nextA$
        IF an$ >= prev$ THEN done$ = TRUE
    WEND
    RETURN an$
END DEF

[main]
    PRINT "agm(1, 1/sqrt(2)) = "; FN Agm$(1, 1 / SQR(2))
END

' Output:
' agm(1, 1/sqrt(2)) = 0.8472130847939792