' ============================================
' ROSETTA: https://rosettacode.org/wiki/Terminal_control/Coloured_text
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints text in six foreground colours, then white or black text on six background colours with the COLOR command, and resets the colours at the end.
' CATEGORY: screen
' TAGS: color, coloured text, terminal control, palette
' MINVERSION: 1.5
' ============================================
' COLOR fg, bg  (0-15 palette)

[main]
    ' Foreground colors
    COLOR  4, 0 : PRINT "Red"
    COLOR  2, 0 : PRINT "Green"
    COLOR  1, 0 : PRINT "Blue"
    COLOR  5, 0 : PRINT "Magenta"
    COLOR  3, 0 : PRINT "Cyan"
    COLOR 14, 0 : PRINT "Yellow"

    ' Background colors
    PRINT ""
    COLOR 15,  4 : PRINT "White on Red"
    COLOR 15,  2 : PRINT "White on Green"
    COLOR 15,  1 : PRINT "White on Blue"
    COLOR  0,  3 : PRINT "Black on Cyan"
    COLOR  0, 14 : PRINT "Black on Yellow"
    COLOR  0,  5 : PRINT "Black on Magenta"

    ' Reset
    COLOR 7, 0
END
