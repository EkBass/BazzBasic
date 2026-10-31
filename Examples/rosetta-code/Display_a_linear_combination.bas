' ============================================
' ROSETTA: https://rosettacode.org/wiki/Display_a_linear_combination
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Displays vectors of integer coefficients as linear combinations of basis vectors e(i) in natural notation, for example e(1) + 2*e(2) + 3*e(3).
' CATEGORY: strings
' TAGS: linear combination, string formatting, split, vectors
' MINVERSION: 1.5
' ============================================

[inits]
    DIM vectors$
    vectors$(0) = "1,2,3"
    vectors$(1) = "0,1,2,3"
    vectors$(2) = "1,0,3,4"
    vectors$(3) = "1,2,0"
    vectors$(4) = "0,0,0"
    vectors$(5) = "0"
    vectors$(6) = "1,1,1"
    vectors$(7) = "-1,-1,-1"
    vectors$(8) = "-1,-2,0,-3"
    vectors$(9) = "-1"

    DIM coef$
    LET count$ = 0
    LET c$     = 0
    LET idx$   = 0
    LET term$  = ""
    LET out$   = ""

[main]
    FOR n$ = 0 TO ROWCOUNT(vectors$()) - 1
        count$ = SPLIT(coef$, vectors$(n$), ",")
        out$ = ""

        FOR m$ = 0 TO count$ - 1
            c$ = VAL(coef$(m$))
            IF c$ <> 0 THEN
                idx$  = m$ + 1
                term$ = "e(" + idx$ + ")"
                ' Coefficients of 1 and -1 are implied
                IF ABS(c$) <> 1 THEN term$ = ABS(c$) + "*" + term$

                IF out$ = "" THEN
                    ' First term: sign is attached directly
                    IF c$ < 0 THEN
                        out$ = "-" + term$
                    ELSE
                        out$ = term$
                    END IF
                ELSE
                    ' Later terms: sign becomes a spaced operator
                    IF c$ < 0 THEN
                        out$ += " - " + term$
                    ELSE
                        out$ += " + " + term$
                    END IF
                END IF
            END IF
        NEXT

        IF out$ = "" THEN out$ = "0"
        PRINT out$
    NEXT
END

' Output:
' e(1) + 2*e(2) + 3*e(3)
' e(2) + 2*e(3) + 3*e(4)
' e(1) + 3*e(3) + 4*e(4)
' e(1) + 2*e(2)
' 0
' 0
' e(1) + e(2) + e(3)
' -e(1) - e(2) - e(3)
' -e(1) - 2*e(2) - 3*e(4)
' -e(1)