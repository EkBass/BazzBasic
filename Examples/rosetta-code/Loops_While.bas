' ============================================
' ROSETTA: https://rosettacode.org/wiki/Loops/While
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the value 1024 and halves it repeatedly with a WHILE loop until it reaches zero.
' CATEGORY: basics
' TAGS: while loop, integer division, int
' MINVERSION: 1.5
' ============================================

[inits]
    LET value$ = 1024

[main]
    WHILE value$ > 0
        PRINT value$
        value$ = INT(value$ / 2)
    WEND
END

' Output:
' 1024
' 512
' 256
' 128
' 64
' 32
' 16
' 8
' 4
' 2
' 1
