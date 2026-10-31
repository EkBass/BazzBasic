' ============================================
' ROSETTA: https://rosettacode.org/wiki/Integer_comparison
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Reads two integers from the user and prints whether the first is less than, equal to or greater than the second.
' CATEGORY: math
' TAGS: integer comparison, comparison operators, input
' MINVERSION: 1.5
' ============================================

[main]
    ' Works also if separated with whitespace instead of comma
    INPUT "Enter two integers separated by a comma: ", a$, b$
    a$ = INT(VAL(a$))
    b$ = INT(VAL(b$))

[compare]
    IF a$ < b$ THEN PRINT a$; " is less than ";    b$
    IF a$ = b$ THEN PRINT a$; " is equal to ";     b$
    IF a$ > b$ THEN PRINT a$; " is greater than "; b$
END