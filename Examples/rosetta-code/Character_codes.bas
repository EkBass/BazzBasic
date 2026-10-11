' ============================================
' https://rosettacode.org/wiki/Character_codes
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' Task
' Given a character value in your language, print its code   (could be ASCII code, Unicode code, or whatever your language uses).

' Example
' The character 'a' (lowercase letter A) has a code of 97 in ASCII (as well as Unicode, as ASCII forms the beginning of Unicode).
' Conversely, given a code, print out the corresponding character.


[inits]
    LET charCode$   = 97
    LET char$       = "a"

[output]
    PRINT CHR(charCode$)
    PRINT ASC(char$)
END

' Output:
' a
' 97