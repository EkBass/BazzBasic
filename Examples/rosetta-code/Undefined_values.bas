' ============================================
' ROSETTA: https://rosettacode.org/wiki/Undefined_values
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Shows how undefined values behave: ISSET returns 1 for declared variables and constants (even without a value) and 0 for undeclared ones, and reading an undefined variable stops the program with an error.
' CATEGORY: basics
' TAGS: isset, undefined values, declaration, variables
' MINVERSION: 1.5
' ============================================

[inits]
    LET a$ = "hello"
    LET b$                  ' declared with no value
    LET MAX# = 100

[output]
    PRINT ISSET(a$)         ' 1
    PRINT ISSET(b$)         ' 1  (LET declares it even without a value)
    PRINT ISSET(MAX#)       ' 1
    PRINT ISSET(undef$)     ' 0
    PRINT ISSET(UNDEF#)     ' 0

    PRINT a$                ' hello
    PRINT foo$              ' error