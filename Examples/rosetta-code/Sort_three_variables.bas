' ============================================
' ROSETTA: https://rosettacode.org/wiki/Sort_three_variables
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Sorts three random integers (0 to 99) into ascending order using only arithmetic with MIN and MAX and no temporary variable, printing the values before and after.
' CATEGORY: algorithms
' TAGS: sorting, min, max, no temporary variable
' MINVERSION: 1.5
' ============================================

[inits]
    LET a$ = RND(100)
    LET b$ = RND(100)
    LET c$ = RND(100)

[main]

    PRINT "Start:"
    PRINT "a$: "; a$
    PRINT "b$: "; b$
    PRINT "c$: "; c$
    
    ' preserve the sum with out temp var
    a$ = a$ + b$ + c$

    ' re-construct the original value of a$
    c$ = MAX(a$ - b$ - c$, MAX(b$, c$))

    ' Sum of all three - Max - Min = Middle
    b$ = (a$ - c$) - MIN(a$ - b$ - c$, MIN(b$, c$))

    ' Total Sum - Max - Mid = Min
    a$ = a$ - c$ - b$

[output]
    PRINT "Sorted Order:"
    PRINT "a$: "; a$
    PRINT "b$: "; b$
    PRINT "c$: "; c$
END

' Output
' Start:
' a$: 81
' b$: 12
' c$: 84
' Sorted Order:
' a$: 12
' b$: 81
' c$: 84