' ============================================
' https://rosettacode.org/wiki/Babbage_problem
' BazzBasic: https://github.com/EkBass/BazzBasic
' Task: find the smallest positive integer whose square ends
'       in the digits 269696, and check Babbage's guess of 99736.
' ============================================

[inits]
    LET ENDING# = 269696
    LET DIVISOR# = 1000000      ' keeps the last six digits of a number
    LET BABBAGE# = 99736
    LET n$ = 0

[main]
    ' Try each whole number in turn. The remainder after dividing its
    ' square by one million is that square's last six digits.
    n$ = 1
    WHILE MOD(n$ * n$, DIVISOR#) <> ENDING#
        n$ += 1
    WEND

    PRINT "The smallest number whose square ends in "; ENDING#; " is "; n$
    PRINT "Its square is "; n$ * n$

    IF n$ = BABBAGE# THEN
        PRINT "Babbage was right."
    ELSE
        PRINT "Babbage was wrong: "; BABBAGE#; " also works, but it is not the smallest."
    END IF
END

' Output:
' The smallest number whose square ends in 269696 is 25264
' Its square is 638269696
' Babbage was wrong: 99736 also works, but it is not the smallest.