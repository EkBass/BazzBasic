' ============================================
' ROSETTA: https://rosettacode.org/wiki/Loops/For
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints a triangle of asterisks, one more asterisk on each of five rows, with nested FOR loops.
' CATEGORY: basics
' TAGS: for loop, nested loops
' MINVERSION: 1.5
' ============================================

[main]
    FOR i$ = 1 TO 5
        FOR j$ = 1 TO i$
            PRINT "*";  ' keeps cursor at same line
        NEXT
        PRINT   ' new line
    NEXT
END

' Output:
' *
' **
' ***
' ****
' *****
