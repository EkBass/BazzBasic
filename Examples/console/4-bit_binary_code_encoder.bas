' ============================================================
' Digit-by-digit LSB-first 4-bit binary encoder
' EkBazz 2026, public domain
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================================

DEF FN ToBinary$(n$)
    LET digits$ = STR(n$)
    LET result$ = ""
    LET d$
    LET bits$
    LET i$

    FOR i$ = 1 TO LEN(digits$)
        d$ = VAL(MID(digits$, i$, 1))
        bits$ = STR(MOD(d$, 2))
        bits$ = bits$ + STR(MOD(INT(d$ / 2), 2))
        bits$ = bits$ + STR(MOD(INT(d$ / 4), 2))
        bits$ = bits$ + STR(MOD(INT(d$ / 8), 2))
        IF result$ = "" THEN
            result$ = bits$
        ELSE
            result$ = result$ + ", " + bits$
        END IF
    NEXT
    RETURN result$
END DEF

[inits]
    LET test$

[main]
    test$ = FN ToBinary$(12)
    PRINT "ToBinary(12)  : " + test$

    test$ = FN ToBinary$(9)
    PRINT "ToBinary(9)   : " + test$

    test$ = FN ToBinary$(123)
    PRINT "ToBinary(123) : " + test$

    test$ = FN ToBinary$(0)
    PRINT "ToBinary(0)   : " + test$
END

' Output:
' ToBinary(12)  : 1000, 0100
' ToBinary(9)   : 1001
' ToBinary(123) : 1000, 0100, 1100
' ToBinary(0)   : 0000