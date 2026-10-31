' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Demonstrates ISSET, which returns 1 for a declared variable or constant (even without a value) and 0 for an undeclared one.
' CATEGORY: basics
' TAGS: isset, variables, constants, declaration
' MINVERSION: 1.5
' ============================================

LET a$ = "hello"
LET b$                  ' declared with no value
LET MAX# = 100

PRINT ISSET(a$)         ' 1
PRINT ISSET(b$)         ' 1  (LET declares it even without a value)
PRINT ISSET(MAX#)       ' 1
PRINT ISSET(undef$)     ' 0
PRINT ISSET(UNDEF#)     ' 0