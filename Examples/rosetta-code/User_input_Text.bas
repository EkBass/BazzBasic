' ============================================
' ROSETTA: https://rosettacode.org/wiki/User_input/Text
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Asks the user for a string and for the integer 75000 with INPUT and prints both back.
' CATEGORY: input
' TAGS: input statement, text input, val
' MINVERSION: 1.5
' ============================================
[inits]
    LET text$
    LET number$

[main]
    INPUT "Enter a string: ", text$

    ' Since task do not require checkig the integer, we go easy here.
    INPUT "Enter the integer 75000: ", number$
    PRINT "String : " + text$
    PRINT "Integer: " + STR(VAL(number$))
END

' Output:
' Enter a string: Hello
' Enter the integer 75000: 75000
' String : Hello
' Integer: 75000