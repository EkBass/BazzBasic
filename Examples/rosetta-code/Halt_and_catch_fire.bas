' ============================================
' ROSETTA: https://rosettacode.org/wiki/Halt_and_catch_fire
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Halts the program on purpose by declaring the constant FOO# twice, which makes the interpreter stop with a 'Cannot redefine constant' error.
' CATEGORY: basics
' TAGS: halt, runtime error, constants
' MINVERSION: 1.5
' ============================================

' double declaration for same constant
LET FOO# = 1
LET FOO# = 2

' Output:
' Error at line 8: Cannot redefine constant 'FOO#'