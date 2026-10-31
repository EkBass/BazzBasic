' ============================================
' ROSETTA: https://rosettacode.org/wiki/Cullen_and_Woodall_numbers
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the first 20 Cullen numbers (n * 2^n + 1) and the first 20 Woodall numbers (n * 2^n - 1).
' CATEGORY: math
' TAGS: cullen numbers, woodall numbers, powers of two, number sequences
' MINVERSION: 1.5
' ============================================
' Cullen number:  C(n) = n * 2^n + 1
' Woodall number: W(n) = n * 2^n - 1

[inits]
    LET COUNT# = 20
    LET base$  = 0

[main]
    PRINT "First "; COUNT#; " Cullen numbers:"
    FOR n$ = 1 TO COUNT#
        base$ = n$ * POW(2, n$)
        PRINT base$ + 1; " ";
    NEXT n$
    PRINT
    PRINT

    PRINT "First "; COUNT#; " Woodall numbers:"
    FOR n$ = 1 TO COUNT#
        base$ = n$ * POW(2, n$)
        PRINT base$ - 1; " ";
    NEXT n$
    PRINT
END

' Output:
' First 20 Cullen numbers:
' 3 9 25 65 161 385 897 2049 4609 10241 22529 49153 106497 229377 491521 1048577 2228225 4718593 9961473 20971521
' 
' First 20 Woodall numbers:
' 1 7 23 63 159 383 895 2047 4607 10239 22527 49151 106495 229375 491519 1048575 2228223 4718591 9961471 20971519