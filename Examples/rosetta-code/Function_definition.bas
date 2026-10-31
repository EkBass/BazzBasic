' ============================================
' ROSETTA: https://rosettacode.org/wiki/Function_definition
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Defines a function that multiplies two numbers and prints the result of calling it with 2 and 3.
' CATEGORY: basics
' TAGS: function definition, def fn, return
' MINVERSION: 1.5
' ============================================

DEF FN Multiply$(a$, b$)
    RETURN a$ * b$
END DEF

[main]
    PRINT FN Multiply$(2, 3)

' Output:
' 6