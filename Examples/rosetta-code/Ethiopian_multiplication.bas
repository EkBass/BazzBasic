' ============================================
' ROSETTA: https://rosettacode.org/wiki/Ethiopian_multiplication
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Multiplies 17 by 34 using only halving, doubling and an even test, printing the working table with kept and struck rows and the product.
' CATEGORY: math
' TAGS: ethiopian multiplication, halving, doubling, def fn
' MINVERSION: 1.5
' ============================================

DEF FN Halve$(n$)
    RETURN INT(n$ / 2)
END DEF

DEF FN Double$(n$)
    RETURN n$ * 2
END DEF

DEF FN IsEven$(n$)
    IF MOD(n$, 2) = 0 THEN RETURN TRUE
    RETURN FALSE
END DEF

DEF FN PadLeft$(v$, width$)
    RETURN RIGHT(REPEAT(" ", width$) + STR(v$), width$)
END DEF

' Prints the working table and returns the product
DEF FN EthiopianMultiply$(a$, b$)
    LET left$  = a$
    LET right$ = b$
    LET sum$   = 0
    WHILE left$ >= 1
        IF FN IsEven$(left$) THEN
            PRINT FN PadLeft$(left$, 6); FN PadLeft$(right$, 8); "   struck"
        ELSE
            PRINT FN PadLeft$(left$, 6); FN PadLeft$(right$, 8); "   kept"
            sum$ += right$
        END IF
        left$  = FN Halve$(left$)
        right$ = FN Double$(right$)
    WEND
    RETURN sum$
END DEF

[inits]
    LET a$ = 17
    LET b$ = 34
    LET product$ = 0

[main]
    PRINT FSTRING("Ethiopian multiplication of {{-a$-}} and {{-b$-}}")
    PRINT
    product$ = FN EthiopianMultiply$(a$, b$)
    PRINT REPEAT(" ", 6); "  ======"
    PRINT REPEAT(" ", 6); FN PadLeft$(product$, 8)
END

' Output:
' Ethiopian multiplication of 17 and 34
'
'     17      34   kept
'      8      68   struck
'      4     136   struck
'      2     272   struck
'      1     544   kept
'         ======
'            578