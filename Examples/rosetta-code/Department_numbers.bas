' ============================================
' https://rosettacode.org/wiki/Department_numbers
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Police, sanitation and fire departments get unique numbers 1..7
' that add up to 12. Police number must be even.

[inits]
    LET TOTAL#   = 12
    LET MIN_NUM# = 1
    LET MAX_NUM# = 7

    LET fire$  = 0
    LET count$ = 0

[main]
    PRINT " --police--  --sanitation--  --fire-- "

    FOR police$ = 2 TO MAX_NUM# STEP 2
        FOR sanitation$ = MIN_NUM# TO MAX_NUM#
            fire$ = TOTAL# - police$ - sanitation$
            IF BETWEEN(fire$, MIN_NUM#, MAX_NUM#) AND
               sanitation$ <> police$ AND
               fire$ <> police$ AND
               fire$ <> sanitation$ THEN
                PRINT FSTRING("     {{-police$-}}             {{-sanitation$-}}            {{-fire$-}}")
                count$ += 1
            END IF
        NEXT
    NEXT

    PRINT
    PRINT count$; " valid combinations"
END

' Output:
'  --police--  --sanitation--  --fire--
'      2             3            7
'      2             4            6
'      2             6            4
'      2             7            3
'      4             1            7
'      4             2            6
'      4             3            5
'      4             5            3
'      4             6            2
'      4             7            1
'      6             1            5
'      6             2            4
'      6             4            2
'      6             5            1
'
' 14 valid combinations