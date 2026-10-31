' ============================================
' ROSETTA: https://rosettacode.org/wiki/Copy_a_string
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Copies a string to a second variable and a second constant and shows that changing the copy leaves the original unchanged.
' CATEGORY: strings
' TAGS: string copy, variables, constants, copy by value
' MINVERSION: 1.5
' ============================================

[inits]
    ' variable
    LET a$ = "This is string variable."
    LET b$ = a$

    ' constant
    LET A# = "This is string constant."
    LET B# = A#

[output]
    PRINT a$
    PRINT b$

    PRINT A#
    PRINT B#

[independence]
    ' Strings are copied by value, not by reference:
    ' changing the copy leaves the original intact.
    b$ = "Copy has been changed."
    PRINT a$
    PRINT b$
END

' Output:
' This is string variable.
' This is string variable.
' This is string constant.
' This is string constant.
' This is string variable.
' Copy has been changed.