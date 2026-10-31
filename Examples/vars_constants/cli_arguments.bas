' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Demonstrates reading command-line arguments with ARGCOUNT and ARGS().
' CATEGORY: system
' TAGS: command line arguments, argcount, args
' MINVERSION: 1.5
' ============================================

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