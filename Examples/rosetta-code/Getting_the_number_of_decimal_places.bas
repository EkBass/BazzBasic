' ============================================
' https://rosettacode.org/wiki/Getting_the_number_of_decimal_places
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Works on numbers and numeric strings alike. A numeric literal
' drops trailing zeros (12.3450 -> 12.345), so to keep them the
' value must be given as a string, as in the task's second example.

DEF FN CountDecimals$(num$)
    LET mark$ = INSTR(num$, ".")
    IF mark$ = 0 THEN RETURN 0
    RETURN LEN(num$) - mark$
END DEF

[inits]
    DIM values$
        values$(0) = 7
        values$(1) = 12.345
        values$(2) = "12.3450"
        values$(3) = 4.4321
        values$(4) = 0.123456789

[main]
    FOR i$ = 0 TO LEN(values$()) - 1
        PRINT values$(i$); " has "; FN CountDecimals$(values$(i$)); " decimals."
    NEXT
END

' Output:
' 7 has 0 decimals.
' 12.345 has 3 decimals.
' 12.3450 has 4 decimals.
' 4.4321 has 4 decimals.
' 0.123456789 has 9 decimals.