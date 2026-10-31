' ============================================
' ROSETTA: https://rosettacode.org/wiki/Loops/N_plus_one_half
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the numbers 1 to 10 separated by commas, leaving the loop with EXIT FOR after 10 so that no comma follows the last number.
' CATEGORY: basics
' TAGS: loops, n plus one half, exit for
' MINVERSION: 1.5
' ============================================

' The number and the comma are printed by separate statements.
' After the last number the loop is left with EXIT FOR,
' so no comma is printed after 10.

[main]
    FOR i$ = 1 TO 10
        PRINT i$;
        IF i$ = 10 THEN EXIT FOR
        PRINT ", ";
    NEXT
    PRINT ""
END

' Output:
' 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
