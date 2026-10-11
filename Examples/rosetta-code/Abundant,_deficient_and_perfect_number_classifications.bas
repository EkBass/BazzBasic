' ============================================
' https://rosettacode.org/wiki/Abundant,_deficient_and_perfect_number_classifications
' BazzBasic: https://github.com/EkBass/BazzBasic
' Task: classify the integers 1 to 20000 as deficient, perfect
'       or abundant, and show how many fall into each class.
' ============================================

[inits]
    LET LIMIT# = 20000
    LET deficient$ = 0
    LET perfect$ = 0
    LET abundant$ = 0
    DIM divSum$             ' divSum$(n) = sum of proper divisors of n

[main]
    FOR i$ = 1 TO LIMIT#
        divSum$(i$) = 0
    NEXT

    ' Sieve: add every i$ to the divisor sum of each of its multiples
    FOR i$ = 1 TO LIMIT# / 2
        FOR j$ = i$ * 2 TO LIMIT# STEP i$
            divSum$(j$) = divSum$(j$) + i$
        NEXT
    NEXT

    FOR i$ = 1 TO LIMIT#
        IF divSum$(i$) < i$ THEN
            deficient$ += 1
        ELSEIF divSum$(i$) = i$ THEN
            perfect$ += 1
        ELSE
            abundant$ += 1
        END IF
    NEXT

    PRINT "Deficient: "; deficient$
    PRINT "Perfect:   "; perfect$
    PRINT "Abundant:  "; abundant$
END

' Output:
' Deficient: 15043
' Perfect:   4
' Abundant:  4953