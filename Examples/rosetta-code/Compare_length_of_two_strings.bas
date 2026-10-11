' ============================================
' https://rosettacode.org/wiki/Compare_length_of_two_strings
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' LEN returns the length of a string in characters.

[inits]
    LET a$ = "BazzBasic"
    LET b$ = "QBasic"

[output]
    IF LEN(a$) > LEN(b$) THEN
        PRINT LEN(a$); " "; a$
        PRINT LEN(b$); " "; b$
    ELSE
        PRINT LEN(b$); " "; b$
        PRINT LEN(a$); " "; a$
    END IF
END

' Output:
' 9 BazzBasic
' 6 QBasic