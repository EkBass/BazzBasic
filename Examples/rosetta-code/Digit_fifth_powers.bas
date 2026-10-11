' ============================================
' https://rosettacode.org/wiki/Digit_fifth_powers
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    ' A 7-digit number has a digit-power sum of at most 7 * 9^5 = 413343,
    ' which has only 6 digits. So no number above 6 * 9^5 can qualify.
    LET LIMIT# = 6 * POW(9, 5)

    ' Lookup table: fifth power of each digit
    DIM fifth$
    FOR d$ = 0 TO 9
        fifth$(d$) = POW(d$, 5)
    NEXT d$

    LET n$        = 0
    LET digitSum$ = 0
    LET total$    = 0

[main]
    ' Start at 10: a single digit is not a sum of two or more numbers
    FOR i$ = 10 TO LIMIT#
        n$ = i$
        digitSum$ = 0
        WHILE n$ > 0
            digitSum$ += fifth$(n$ % 10)
            n$ = INT(n$ / 10)
        WEND
        IF digitSum$ = i$ THEN
            PRINT i$
            total$ += i$
        END IF
    NEXT i$

    PRINT "The sum is "; total$
END

' Output:
' 4150
' 4151
' 54748
' 92727
' 93084
' 194979
' The sum is 443839