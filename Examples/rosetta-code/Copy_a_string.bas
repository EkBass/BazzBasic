' ============================================
' https://rosettacode.org/wiki/Copy_a_string
' BazzBasic: https://github.com/EkBass/BazzBasic
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