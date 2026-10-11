' ============================================
' https://rosettacode.org/wiki/Damm_algorithm
' BazzBasic: https://github.com/EkBass/BazzBasic
' Verify a number whose last digit is a Damm checksum
' ============================================

' Returns 0 when the checksum is valid
DEF FN Damm$(num$)
    LET interim$ = 0
    LET digit$ = 0
    FOR i$ = 1 TO LEN(num$)
        digit$ = VAL(MID(num$, i$, 1))
        interim$ = VAL(MID(TABLE#, interim$ * 10 + digit$ + 1, 1))
    NEXT
    RETURN interim$
END DEF

[inits]
    ' 10x10 quasigroup table, one row per line, row = interim digit
    LET TABLE# = "0317598642" +
                 "7092154863" +
                 "4206871359" +
                 "1750983426" +
                 "6123045978" +
                 "3674209581" +
                 "5869720134" +
                 "8945362017" +
                 "9438617205" +
                 "2581436790"

    DIM tests$
    LET count$ = SPLIT(tests$, "5724,5727,112946,112949", ",")

[main]
    FOR i$ = 0 TO count$ - 1
        IF FN Damm$(tests$(i$)) = 0 THEN
            PRINT tests$(i$); " PASS"
        ELSE
            PRINT tests$(i$); " FAIL"
        END IF
    NEXT
END

' Output:
' 5724 PASS
' 5727 FAIL
' 112946 PASS
' 112949 FAIL