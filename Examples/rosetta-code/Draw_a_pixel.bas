' ============================================
' ROSETTA: https://rosettacode.org/wiki/Draw_a_pixel
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Opens a 320x240 window, draws a single red pixel at (100, 100) and waits for a key press.
' CATEGORY: drawing
' TAGS: pixel, pset, rgb, screen
' MINVERSION: 1.5
' ============================================

[inits]
	LET SCREEN_W#   = 320 ' constant
	LET SCREEN_H#   = 240 ' constant

	LET MY_COLOR#   = RGB(255, 0, 0) ' constant
	LET x$ = 100, y$ = 100 ' variables
	
	LET wkv$

    SCREEN 0, SCREEN_W#, SCREEN_H#, "Draw a Pixel"

[main]
	PSET(x$, y$), MY_COLOR#
	
	wkv$ = WAITKEY()
END