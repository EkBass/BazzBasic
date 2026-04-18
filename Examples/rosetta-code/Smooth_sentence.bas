' ============================================
' Smooth Sentence - Edabit challenge in BazzBasic
' https://edabit.com/challenge/SkY5Nw3rS7WvkQmFc
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' A sentence is "smooth" when the last letter of
' every word matches the first letter of the next
' word, case-insensitively.
'
' Strategy:
'   - Split the sentence on spaces.
'   - For each adjacent pair, compare the last
'     char of the left word with the first char of
'     the right word (both lower-cased).
'   - Bail out with FALSE the moment a seam fails;
'     otherwise return TRUE. A 0- or 1-word
'     sentence is vacuously smooth.
' ============================================

DEF FN IsSmooth$(sentence$)
    DIM words$
    LET n$         = SPLIT(words$, sentence$, " ")
    LET endChar$   = ""
    LET startChar$ = ""

    FOR i$ = 0 TO n$ - 2
        endChar$   = LCASE(RIGHT(words$(i$), 1))
        startChar$ = LCASE(LEFT(words$(i$ + 1), 1))
        IF endChar$ <> startChar$ THEN RETURN FALSE
    NEXT
    RETURN TRUE
END DEF

DEF FN Bool$(v$)
    IF v$ = TRUE THEN RETURN "true"
    RETURN "false"
END DEF

[inits]
    DIM tests$
    tests$(0) = "Marta appreciated deep perpendicular right trapezoids"
    tests$(1) = "Someone is outside the doorway"
    tests$(2) = "She eats super righteously"
    tests$(3) = "Carlos swam masterfully"

[main]
    FOR i$ = 0 TO ROWCOUNT(tests$()) - 1
        PRINT "IsSmooth(\""; tests$(i$); "\") -> "; FN Bool$(FN IsSmooth$(tests$(i$)))
    NEXT
END

' Output:
' IsSmooth("Marta appreciated deep perpendicular right trapezoids") -> true
' IsSmooth("Someone is outside the doorway") -> false
' IsSmooth("She eats super righteously") -> true
' IsSmooth("Carlos swam masterfully") -> true
