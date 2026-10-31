' ============================================
' ROSETTA: https://rosettacode.org/wiki/Mouse_position
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Shows the current mouse pointer position (MOUSEX and MOUSEY) on a graphics screen, updating continuously until ESC is pressed.
' CATEGORY: input
' TAGS: mouse, mousex, mousey, graphics screen
' MINVERSION: 1.5
' ============================================

' BazzBasic requires graphics screen to work with mouse
[inits]
    SCREEN 0, 800, 600, "Mouse_position.bas"

[main]
    WHILE INKEY <> KEY_ESC#
        LOCATE 1, 1
        PRINT "X:"; MOUSEX; " Y:"; MOUSEY; "   "
		SLEEP 5
    WEND
END
