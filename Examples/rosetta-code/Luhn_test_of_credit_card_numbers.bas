' ============================================
' https://rosettacode.org/wiki/Luhn_test_of_credit_card_numbers
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' Returns TRUE (1) if the digit string passes the Luhn check, FALSE (0) otherwise
DEF FN IsLuhnValid$(number$)
    LET sum$   = 0
    LET odd$   = TRUE          ' rightmost digit is position 1 (odd)
    LET digit$ = 0

    FOR n$ = LEN(number$) TO 1 STEP -1
        digit$ = ASC(number$, n$) - 48     ' "0" = ASCII 48
        IF odd$ THEN
            sum$ += digit$
        ELSE
            digit$ *= 2
            IF digit$ > 9 THEN digit$ -= 9
            sum$ += digit$
        END IF
        odd$ = NOT odd$
    NEXT

    RETURN sum$ % 10 = 0
END DEF

[inits]
    DIM cards$
    cards$(0) = "49927398716"
    cards$(1) = "49927398717"
    cards$(2) = "1234567812345678"
    cards$(3) = "1234567812345670"

    LET result$ = ""

[main]
    FOR i$ = 0 TO LEN(cards$()) - 1
        IF FN IsLuhnValid$(cards$(i$)) THEN
            result$ = "True"
        ELSE
            result$ = "False"
        END IF
        PRINT cards$(i$), result$
    NEXT
END

' Output:
' 49927398716       True
' 49927398717       False
' 1234567812345678  False
' 1234567812345670  True