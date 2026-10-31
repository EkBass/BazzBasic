' ============================================
' ROSETTA: https://rosettacode.org/wiki/Terminal_control/Inverse_video
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the word inverse in inverse video (black on white) followed by normal text, by swapping the foreground and background arguments of COLOR.
' CATEGORY: screen
' TAGS: inverse video, color, terminal control
' MINVERSION: 1.5
' ============================================

' BazzBasic achieves inverse video by swapping the foreground and
' background values of the COLOR command.
' Normal: COLOR 15, 0  (white text on black)
' Inverse: COLOR  0, 15  (black text on white)

[main]
    COLOR  0, 15 : PRINT "inverse"; : COLOR 15, 0 : PRINT " normal"
    COLOR  7,  0
END

' Output:
' [black-on-white]inverse[/] [white-on-black]normal[/]
