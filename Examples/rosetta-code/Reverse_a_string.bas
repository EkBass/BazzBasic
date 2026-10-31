' ============================================
' ROSETTA: https://rosettacode.org/wiki/Reverse_a_string
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the characters of a string and the digits of a number in reverse order with INVERT.
' CATEGORY: strings
' TAGS: invert, reverse string
' MINVERSION: 1.5
' ============================================
' INVERT reverses both strings and numbers.

[inits]
    LET alpha$ = "abcdefg..."     ' variable
    LET NUM#   = 12345            ' constant

[main]
    PRINT INVERT(alpha$)
    PRINT INVERT(NUM#)
END

' Output:
' ...gfedcba
' 54321
