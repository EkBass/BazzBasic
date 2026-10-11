' ============================================
' https://rosettacode.org/wiki/Dinesman%27s_multiple-dwelling_problem
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' ---- Setup ----
LET BOTTOM# = 1
LET TOP#    = 5

' ---- Problem statement: one line per rule ----
DEF FN Rules$(baker$, cooper$, fletcher$, miller$, smith$)
    IF baker$ = TOP# THEN RETURN FALSE                              ' Baker not on top floor
    IF cooper$ = BOTTOM# THEN RETURN FALSE                          ' Cooper not on bottom floor
    IF fletcher$ = TOP# OR fletcher$ = BOTTOM# THEN RETURN FALSE    ' Fletcher neither top nor bottom
    IF miller$ <= cooper$ THEN RETURN FALSE                         ' Miller higher than Cooper
    IF ABS(smith$ - fletcher$) = 1 THEN RETURN FALSE                ' Smith not adjacent to Fletcher
    IF ABS(fletcher$ - cooper$) = 1 THEN RETURN FALSE               ' Fletcher not adjacent to Cooper
    RETURN TRUE
END DEF

' Everyone lives on a different floor
DEF FN AllDifferent$(a$, b$, c$, d$, e$)
    RETURN a$ <> b$ AND a$ <> c$ AND a$ <> d$ AND a$ <> e$ AND
           b$ <> c$ AND b$ <> d$ AND b$ <> e$ AND
           c$ <> d$ AND c$ <> e$ AND
           d$ <> e$
END DEF

[inits]
    LET found$ = 0

[main]
    FOR b$ = BOTTOM# TO TOP#
        FOR c$ = BOTTOM# TO TOP#
            FOR f$ = BOTTOM# TO TOP#
                FOR m$ = BOTTOM# TO TOP#
                    FOR s$ = BOTTOM# TO TOP#
                        IF FN AllDifferent$(b$, c$, f$, m$, s$) THEN
                            IF FN Rules$(b$, c$, f$, m$, s$) THEN
                                found$ += 1
                                GOSUB [sub:show]
                            END IF
                        END IF
                    NEXT s$
                NEXT m$
            NEXT f$
        NEXT c$
    NEXT b$

    IF found$ = 0 THEN PRINT "No solution."
END

[sub:show]
    PRINT FSTRING("Baker    lives on floor {{-b$-}}")
    PRINT FSTRING("Cooper   lives on floor {{-c$-}}")
    PRINT FSTRING("Fletcher lives on floor {{-f$-}}")
    PRINT FSTRING("Miller   lives on floor {{-m$-}}")
    PRINT FSTRING("Smith    lives on floor {{-s$-}}")
    PRINT
RETURN

' Output:
' Baker    lives on floor 3
' Cooper   lives on floor 2
' Fletcher lives on floor 4
' Miller   lives on floor 5
' Smith    lives on floor 1