' BazzBasic version 1.4c
' https://ekbass.github.io/BazzBasic/

' === ARGCOUNT
' Return the amount of arguments passed to program.

' BazzBasic.exe test.bas arg1 arg2
PRINT ARGCOUNT
' Output:
' 2



' === ARGS()
' Returns certain argument, if passed.

' BazzBasic.exe test.bas arg1 arg2
PRINT ARGS(0)
PRINT ARGS(1)
' Output:
' arg1
' arg2