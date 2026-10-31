' ============================================
' ROSETTA: https://rosettacode.org/wiki/String_concatenation
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Joins string variables and a constant, both by listing them in PRINT with semicolons and by concatenating them with +, and prints the results.
' CATEGORY: strings
' TAGS: string concatenation, print, constants
' MINVERSION: 1.5
' ============================================

[inits]
    LET space$              ' declares empty variable
    space$ = CHR(32)

    LET result$
    LET foo$ = "foo"    ' variables with content
    LET bar$ = "bar"
    
    LET MY_CONST# = "Constant"
    

[main]
    ' printing two variables at once
    PRINT "foo$; bar$: "; foo$; bar$
    ' using concetanative way
    PRINT "foo$ + bar$: ";foo$ + bar$

    ' printing variable and constant
    PRINT "foo$; MY_CONST#: "; foo$; MY_CONST#

    ' concatenating variables and const
    result$ = foo$ + space$ + MY_CONST#
    PRINT "result$ = foo$ + space$ + MY_CONST#: "; result$
END

' Output:
' foo$; bar$: foobar
' foo$ + bar$: foobar
' foo$; MY_CONST#: fooConstant
' result$ = foo$ + space$ + MY_CONST#: foo Constant
