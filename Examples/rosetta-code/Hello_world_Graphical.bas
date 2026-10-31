' ============================================
' ROSETTA: https://rosettacode.org/wiki/Hello_world/Graphical
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Opens a 600x480 graphics window titled Goodbye, World! and draws the same text in it until a key is pressed.
' CATEGORY: drawing
' TAGS: hello world, graphics window, drawstring, waitkey
' MINVERSION: 1.5
' ============================================

[inits]
    LET MSG# = "Goodbye, World!"
    LET WHITE# = RGB(255, 255, 255)
    LET wkv$ = 0

    SCREEN 0, 600, 480, MSG#

[main]
    ' DRAWSTRING preferred over LOCATE/PRINT in graphics mode —
    ' PRINT causes flicker on the SDL2 surface.
    DRAWSTRING MSG#, 100, 200, WHITE#
    wkv$ = WAITKEY()
END