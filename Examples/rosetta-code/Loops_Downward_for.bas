' ============================================
' ROSETTA: https://rosettacode.org/wiki/Loops/Downward_for
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the numbers from 10 down to 0 with a FOR loop and a negative STEP.
' CATEGORY: basics
' TAGS: for loop, step, countdown
' MINVERSION: 1.5
' ============================================

[main]
    FOR i$ = 10 TO 0 STEP -1
        PRINT i$
    NEXT
END

' Output:
' 10
' 9
' 8
' 7
' 6
' 5
' 4
' 3
' 2
' 1
' 0
