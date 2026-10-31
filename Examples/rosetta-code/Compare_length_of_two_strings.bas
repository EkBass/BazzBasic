' ============================================
' ROSETTA: https://rosettacode.org/wiki/Compare_length_of_two_strings
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Compares the lengths of two strings and prints them from longest to shortest, each with its length.
' CATEGORY: strings
' TAGS: string length, len, comparison
' MINVERSION: 1.5
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