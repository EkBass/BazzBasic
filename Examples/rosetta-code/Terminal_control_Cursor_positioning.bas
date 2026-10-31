' ============================================
' ROSETTA: https://rosettacode.org/wiki/Terminal_control/Cursor_positioning
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Moves the cursor to row 6, column 3 with LOCATE and prints Hello there, then reads the character at that position back with GETCONSOLE and prints it.
' CATEGORY: screen
' TAGS: locate, cursor positioning, getconsole, terminal control
' MINVERSION: 1.5
' ============================================

[inits]
    LET ver$

[output]
    CLS
    LOCATE 6, 3 : PRINT "Hello"

[verify]
    ver$ = GETCONSOLE(6, 3, 0) ' Returns char at row 6, col 3 as ASCII code
    LOCATE 10, 1
    PRINT "Char at row 6, col 3 is: "; CHR(ver$)
END
