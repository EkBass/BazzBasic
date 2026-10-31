' ============================================
' ROSETTA: https://rosettacode.org/wiki/Repeat_a_string
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the string "Hello" repeated five times with the REPEAT function.
' CATEGORY: strings
' TAGS: repeat, string repetition
' MINVERSION: 1.5
' ============================================

[inits]
    LET string$ = "Hello"
    LET times$  = 5

[main]
    PRINT REPEAT(string$, times$)
END

' Output:
' HelloHelloHelloHelloHello