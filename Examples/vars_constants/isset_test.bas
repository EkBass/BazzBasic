' BazzBasic version 1.4c
' https://ekbass.github.io/BazzBasic/

' Returns 1 (TRUE) if variable/constant is initialized

LET a$ = "hello"
LET b$                  ' declared with no value
LET MAX# = 100

PRINT ISSET(a$)         ' 1
PRINT ISSET(b$)         ' 1  (LET declares it even without a value)
PRINT ISSET(MAX#)       ' 1
PRINT ISSET(undef$)     ' 0
PRINT ISSET(UNDEF#)     ' 0