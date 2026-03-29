' ============================================
' https://rosettacode.org/wiki/Keyboard_input/Obtain_a_Y_or_N_response
' BazzBasic: https://github.com/EkBass/BazzBasic
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
