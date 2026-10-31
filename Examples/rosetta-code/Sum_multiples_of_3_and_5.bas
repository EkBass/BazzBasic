' ============================================
' ROSETTA: https://rosettacode.org/wiki/Sum_multiples_of_3_and_5
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Sums all positive integers below 1000 that are multiples of 3 or 5 and prints the result (233168).
' CATEGORY: math
' TAGS: multiples, sum, modulo, def fn
' MINVERSION: 1.5
' ============================================

DEF FN IsMultiple$(n$)
    IF MOD(n$, 3) = 0 THEN RETURN TRUE
    IF MOD(n$, 5) = 0 THEN RETURN TRUE
    RETURN FALSE
END DEF

[inits]
    LET sum$ = 0, i$

[main]
    FOR i$ = 0 TO 1000 - 1
        IF FN IsMultiple$(i$) = TRUE THEN
            sum$+= i$
        END IF
    NEXT

[output]
    PRINT "Sum of positive integers below 1000 divisible by 3 or 5 is : "; sum$
END

' Output:
' Sum of positive integers below 1000 divisible by 3 or 5 is : 233168