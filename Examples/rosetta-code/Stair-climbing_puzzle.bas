' ============================================
' https://rosettacode.org/wiki/Stair-climbing_puzzle
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' One step attempt: TRUE = climbed up, FALSE = fell down
DEF FN Step$()
    IF RND(2) = 1 THEN
        PRINT "Robot climbs"
        RETURN TRUE
    END IF
    PRINT "Robot falls"
    RETURN FALSE
END DEF

' Climb exactly one step. No variables, no numbers.
' A failed step puts us one lower: climb back up, then climb once more.
DEF FN StepUp$()
    IF FN Step$() THEN RETURN TRUE
    RETURN FN StepUp$() AND FN StepUp$()
END DEF

[main]
    IF FN StepUp$() THEN PRINT "Robot is one step higher."
END

' Output (random, one possible run):
' Robot falls
' Robot falls
' Robot climbs
' Robot climbs
' Robot climbs
' Robot is one step higher.

' ===========================================
' Iterative way
' ===========================================
DEF FN StepUpIter$()
    LET i$ = 0
    WHILE i$ < 1
        IF FN Step$() THEN
            i$ += 1
        ELSE
            i$ -= 1
        END IF
    WEND
    RETURN TRUE
END DEF