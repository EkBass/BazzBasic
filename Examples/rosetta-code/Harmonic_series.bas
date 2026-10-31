' ============================================
' ROSETTA: https://rosettacode.org/wiki/Harmonic_series
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the first 20 harmonic numbers and the first position where the harmonic series exceeds each whole number from 1 to 10.
' CATEGORY: math
' TAGS: harmonic series, harmonic numbers, running sum, def fn
' MINVERSION: 1.5
' ============================================
' H(n) = 1 + 1/2 + 1/3 + ... + 1/n
' Harmonic$ gives any single H(n). The threshold search keeps a
' running sum instead - recomputing H(n) from scratch at every
' position would take tens of millions of additions.

DEF FN Harmonic$(n$)
    LET h$ = 0
    FOR k$ = 1 TO n$
        h$ += 1 / k$
    NEXT
    RETURN h$
END DEF

[inits]
    LET SCALE# = 1000000000000          ' display precision: 12 decimals
    LET h$ = 0
    LET n$ = 0

[main]
    PRINT "The first 20 harmonic numbers:"
    FOR i$ = 1 TO 20
        h$ = FN Harmonic$(i$)
        h$ = ROUND(h$ * SCALE#) / SCALE#    ' hide float noise (2.4499999... -> 2.45)
        PRINT RIGHT(" " + i$, 2); ": "; h$
    NEXT
    PRINT ""

    h$ = 0
    n$ = 0
    FOR target$ = 1 TO 10
        WHILE h$ <= target$
            n$ += 1
            h$ += 1 / n$
        WEND
        PRINT FSTRING("First harmonic number > {{-target$-}} is at position {{-n$-}}")
    NEXT
END

' Output:
' The first 20 harmonic numbers:
'  1: 1
'  2: 1.5
'  3: 1.833333333333
'  4: 2.083333333333
'  5: 2.283333333333
'  6: 2.45
'  7: 2.592857142857
'  8: 2.717857142857
'  9: 2.828968253968
' 10: 2.928968253968
' 11: 3.019877344877
' 12: 3.103210678211
' 13: 3.180133755134
' 14: 3.251562326562
' 15: 3.318228993229
' 16: 3.380728993229
' 17: 3.439552522641
' 18: 3.495108078196
' 19: 3.547739657144
' 20: 3.597739657144
'
' First harmonic number > 1 is at position 2
' First harmonic number > 2 is at position 4
' First harmonic number > 3 is at position 11
' First harmonic number > 4 is at position 31
' First harmonic number > 5 is at position 83
' First harmonic number > 6 is at position 227
' First harmonic number > 7 is at position 616
' First harmonic number > 8 is at position 1674
' First harmonic number > 9 is at position 4550
' First harmonic number > 10 is at position 12367
