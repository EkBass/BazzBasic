' ============================================
' ROSETTA: https://rosettacode.org/wiki/Increment_a_numerical_string
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Increments the numeric string "123" by one by converting it with VAL, adding 1 and converting it back with STR, then prints 124.
' CATEGORY: strings
' TAGS: numeric string, val, str, increment
' MINVERSION: 1.5
' ============================================

[inits]
    LET num$ = "123"

[main]
    num$ = STR(VAL(num$) + 1)

[output]
    PRINT num$

' Output:
' 124