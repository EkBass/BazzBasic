' ============================================
' ROSETTA: https://rosettacode.org/wiki/Keyboard_input/Obtain_a_Y_or_N_response
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Waits for the user to press Y or N (either case) with WAITKEY and prints the key that was pressed.
' CATEGORY: input
' TAGS: waitkey, keyboard input, yes or no
' MINVERSION: 1.5
' ============================================

PRINT "Press Y or N to continue."

' Works with "N", "n", "Y" & "y"
LET key$ = WAITKEY(KEY_Y#, KEY_N#)
PRINT "You pressed: "; CHR(key$)

' While WAITKEY() is handy way to expect certain key(s), it halts the program execution.
' INKEY does not stop, it just returns key value if pressed.

' INKEY in action, see:
' - Examples/Keypress_check.bas
' - https://rosettacode.org/wiki/Keyboard_input/Keypress_check
