' ============================================
' https://rosettacode.org/wiki/Loops/Do-while
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' BazzBasic has no DO keyword, but a do-while loop is emulated
' with WHILE TRUE and a conditional EXIT WHILE at the end of the body.
' Because the condition is tested only after the body has run,
' the body always executes at least once - which is exactly
' what distinguishes do-while from a plain while loop.

[inits]
    LET value$ = 0

[main]
    WHILE TRUE
        value$ += 1
        PRINT value$
        IF MOD(value$, 6) = 0 THEN EXIT WHILE
    WEND
END

' Output:
' 1
' 2
' 3
' 4
' 5
' 6