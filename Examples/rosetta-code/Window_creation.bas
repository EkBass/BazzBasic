' ============================================
' ROSETTA: https://rosettacode.org/wiki/Window_creation
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Creates a 640x480 graphics window titled Hello, Window! and keeps it open until ESC is pressed.
' CATEGORY: screen
' TAGS: window, screen, graphics window, waitkey
' MINVERSION: 1.5
' ============================================
[inits]
	LET TITLE# = "Hello, Window!"
	LET running$

[init:gfx]
	SCREEN 0, 640, 480, TITLE#

[main]
    ' KEY_ESC# returned from "x" since ver. 1.1e
	running$ = WAITKEY(KEY_ESC#)
END