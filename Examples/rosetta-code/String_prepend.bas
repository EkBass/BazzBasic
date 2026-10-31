' ============================================
' ROSETTA: https://rosettacode.org/wiki/String_prepend
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prepends a string to another string variable and a number to a string with concatenation, and prints the results.
' CATEGORY: strings
' TAGS: string prepend, concatenation
' MINVERSION: 1.5
' ============================================

[inits]
    LET string1$
    LET string2$

    LET foo$ = "456"    ' string
    LET bar$ = 123      ' number

[main]
    ' fill variables
    string1$    = "Bazz"
    string2$    = "Basic"

    ' prepend string2$
    string2$ = string1$ + string2$

    ' prepend foo$ with numerical variable
    foo$ = bar$ + foo$

[output]
    PRINT "string2$:\t"; string2$
    PRINT "foo$:\t\t"; foo$
END

' Output:
' string2$:       BazzBasic
' foo$:           123456
