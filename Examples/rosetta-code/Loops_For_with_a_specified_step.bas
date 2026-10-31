' ============================================
' ROSETTA: https://rosettacode.org/wiki/Loops/For_with_a_specified_step
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the numbers 1 to 9 with a FOR loop using STEP 2, then the numbers 10 down to 2 using STEP -2.
' CATEGORY: basics
' TAGS: for loop, step, negative step
' MINVERSION: 1.5
' ============================================
[pos-step]
    PRINT "# Step 2:"
    FOR i$ = 1 TO 10 STEP 2
        PRINT REPEAT(" ", 4); i$
    NEXT
    PRINT
[neg-step]
    PRINT "# Step -2:"
    FOR i$ = 10 TO 1 STEP -2
        PRINT REPEAT(" ", 4); i$
    NEXT
    PRINT
END
' Output:
' # Step 2:
'     1
'     3
'     5
'     7
'     9
' 
' # Step -2:
'     10
'     8
'     6
'     4
'     2
