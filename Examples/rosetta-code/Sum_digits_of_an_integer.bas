' ============================================
' ROSETTA: https://rosettacode.org/wiki/Sum_digits_of_an_integer
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Computes the sum of the digits of an integer given as a string in a chosen base (up to 36) and prints it for 1 and 1234 in base 10 and for FE and F0E in base 16.
' CATEGORY: math
' TAGS: digit sum, number bases, instr, def fn
' MINVERSION: 1.5
' ============================================
' For each digit character, find its position in the valid-digit alphabet
' for the given base. Position (1-based) minus 1 equals the digit value.

LET DIGITS# = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

DEF FN SumDigits$(numStr$, base$)
    LET vocab$ = LEFT(DIGITS#, base$)   ' valid digits for this base
    LET total$ = 0
    LET i$, ch$, pos$
    FOR i$ = 1 TO LEN(numStr$)
        ch$    = MID(numStr$, i$, 1)
        pos$   = INSTR(vocab$, ch$)     ' 1-based; subtract 1 for digit value
        total$ = total$ + pos$ - 1
    NEXT
    RETURN total$
END DEF

[inits]
    LET result$

[main]
    result$ = FN SumDigits$("1", 10)
    PRINT "1    base 10 : " ; result$

    result$ = FN SumDigits$("1234", 10)
    PRINT "1234 base 10 : " ; result$

    result$ = FN SumDigits$("FE", 16)
    PRINT "FE   base 16 : " ; result$

    result$ = FN SumDigits$("F0E", 16)
    PRINT "F0E  base 16 : " ; result$

END

' Expected output:
' 1    base 10 : 1
' 1234 base 10 : 10
' FE   base 16 : 29
' F0E  base 16 : 29
