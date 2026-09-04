' BazzBasic version 1.3
' https://ekbass.github.io/BazzBasic/
' ============================================
' LOADSHEET demo: countdown 9 -> 0
' sheet_numbers.png: 640x256, 128x128 sprites
' ============================================

[inits]
	' Center position for a 128x128 sprite on 640x480 screen
	LET x# = 256
	LET y# = 176
	DIM sprites$
	SCREEN 0, 640, 480, "Countdown!"
	LOADSHEET sprites$, 128, 128, "images/sheet_numbers.png"
	
[main]
	' Count down from 9 to 0
	FOR i$ = ROWCOUNT(sprites$()) - 1 TO 0 STEP -1
		SCREENLOCK ON
			LINE (0, 0)-(640, 480), 0, BF
			MOVESHAPE sprites$(i$), x#, y#
			DRAWSHAPE sprites$(i$)
		SCREENLOCK OFF
		SLEEP 500
	NEXT
END
