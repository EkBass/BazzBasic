' ============================================
' ROSETTA: https://rosettacode.org/wiki/Terminal_control/Clear_the_screen
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Clears the console screen, once with the built-in CLS command and once by running the Windows cls command through SHELL.
' CATEGORY: system
' TAGS: clear screen, cls, terminal control, shell
' MINVERSION: 1.5
' ============================================

' Built-in way
CLS

' SHELL (windows)
LET foo$ = SHELL("cls")
