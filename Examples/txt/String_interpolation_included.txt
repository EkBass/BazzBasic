' ============================================
' https://rosettacode.org/wiki/String_interpolation
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' BazzBasic does not have built-in string interpolation syntax.
' The idiomatic approach is REPLACE() or string concatenation.

[inits]
    LET template$ = "Mary had a %s lamb."
    LET word$     = "little"
    LET result$

[main]
    ' REPLACE: substitute placeholder with value
    result$ = REPLACE(template$, "%s", word$)
    PRINT result$

    ' Concatenation: build string directly
    PRINT "Mary had a " + word$ + " lamb."
END

' Output:
' Mary had a little lamb.
' Mary had a little lamb.
