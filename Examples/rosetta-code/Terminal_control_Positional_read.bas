' ============================================
' ROSETTA: https://rosettacode.org/wiki/Terminal_control/Positional_read
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints Hello at row 6, column 3 and then reads the character at that screen position back into a variable with GETCONSOLE (the result is not printed).
' CATEGORY: screen
' TAGS: positional read, getconsole, locate, terminal control
' MINVERSION: 1.5
' ============================================

[inits]
    LET c$

[main]
    CLS
    LOCATE 6, 3
    PRINT "Hello"

    ' GETCONSOLE() returns ASCII value of char
    ' so we use CHR() to convert it as character
    c$ = CHR(GETCONSOLE(6, 3, 0))
END