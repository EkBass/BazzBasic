' ============================================
' GENERAL FIZZBUZZ - BazzBasic Edition
' https://rosettacode.org/wiki/General_FizzBuzz
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    DIM factors$
    DIM words$
' [/inits]

[preps]
    INPUT "Max number: ", max$
    FOR i$ = 1 TO 3
        INPUT "Factor and word: ", value$, word$
        factors$(i$) = value$
        words$(i$) = word$
    NEXT
' [/preps]

[fizzfuzz-loop]
    FOR n$ = 1 TO max$
        LET line$ = ""
        FOR i$ = 1 TO 3
            IF MOD(n$, factors$(i$)) = 0 THEN
                line$ = line$ + words$(i$)
            END IF
        NEXT
        IF line$ = "" THEN
            PRINT n$
        ELSE
            PRINT line$
        END IF
    NEXT
END ' [/fizzfuzz-loop]
