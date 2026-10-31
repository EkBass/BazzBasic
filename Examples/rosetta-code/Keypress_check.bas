' ============================================
' ROSETTA: https://rosettacode.org/wiki/Keyboard_input/Keypress_check
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Waits in a polling loop for any key press without pausing the program, using INKEY, and prints the key code.
' CATEGORY: input
' TAGS: inkey, keypress, non-blocking input
' MINVERSION: 1.5
' ============================================

[inits]
    LET key$ = 0

[main]
    ' loop until any key pressed
    WHILE key$ = 0
        key$ = INKEY
        SLEEP 5 ' small delay
    WEND

    ' Could use WAITKEY() but task description requires a way which wont pause program
    PRINT key$
END
