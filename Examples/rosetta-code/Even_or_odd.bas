' ============================================
' ROSETTA: https://rosettacode.org/wiki/Even_or_odd
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Picks a random number from 0 to 99 and prints whether it is even or odd.
' CATEGORY: math
' TAGS: even or odd, parity, modulo, random
' MINVERSION: 1.5
' ============================================

DEF FN IsEven$(num$)
    IF MOD(num$, 2) = 0 THEN
        RETURN TRUE
    END IF

    RETURN FALSE
END DEF

[inits]
    LET ranNum$ = RND(100)

[main]
    PRINT ranNum$; " is ";

    IF FN IsEven$(ranNum$) = TRUE THEN
        PRINT "even"
    ELSE
        PRINT "odd"
    ENDIF
END

' Output: 
' 90 is even
' 
' or:
' 3 is odd