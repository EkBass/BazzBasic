REM =============================================
REM Color memory game for BazzBasic
REM https://ekbass.github.io/BazzBasic/
REM Public Domain.
REM krisu.virtanen@gmail.com
REM =============================================

[inits]
	LET NUM_COLORS# = 8
	LET CX# = 320
	LET CY# = 200
	LET CR# = 100

	DIM cName$
	DIM cR$
	DIM cG$
	DIM cB$

	cName$(0) = "black"		: cR$(0) = 0   : cG$(0) = 0   : cB$(0) = 0
	cName$(1) = "yellow"  	: cR$(1) = 255 : cG$(1) = 255 : cB$(1) = 0
	cName$(2) = "white"  	: cR$(2) = 255 : cG$(2) = 255 : cB$(2) = 255
	cName$(3) = "blue"    	: cR$(3) = 40  : cG$(3) = 80  : cB$(3) = 255
	cName$(4) = "grey"     	: cR$(4) = 160 : cG$(4) = 160 : cB$(4) = 160
	cName$(5) = "red"   	: cR$(5) = 230 : cG$(5) = 30  : cB$(5) = 30
	cName$(6) = "brown"     : cR$(6) = 150 : cG$(6) = 80  : cB$(6) = 20
	cName$(7) = "green"     : cR$(7) = 30  : cG$(7) = 200 : cB$(7) = 30

	DIM seq$
	DIM words$
	LET round$ = 0
' [/inits]


[intro]
	SCREEN 0, 640, 480, "Color memory game"
	SCREENLOCK ON
	
		LINE (0,0)-(639,479), 0, BF
		LOCATE 8, 23
		COLOR 14, 0
		PRINT "COLOR MEMORY GAME"

		LOCATE 10, 15
		COLOR 15, 0
		PRINT "A colored circle appears on the screen."

		LOCATE 11, 15
		PRINT "You see it for a 5 seconds only."

		LOCATE 12, 15
		PRINT "Remember the order of the colors!"

		LOCATE 14, 15
		PRINT "A new color appears each round."

		LOCATE 15, 15
		PRINT "Write ALL the colors in order."

		LOCATE 18, 15
		COLOR 11, 0
		PRINT "Colors: black, yellow, white,"
		LOCATE 19, 15
		PRINT "blue, grey, red, brown, green"

		LOCATE 22, 18
		COLOR 10, 0
		PRINT "Press ENTER to start..."
	SCREENLOCK OFF

	INPUT "", foo$
' [/intro]


[main:startNewGame]
	round$ = 0

	[sub:newRound]
	
		' Ad random color to seq
		LET newColor$ = RND(NUM_COLORS#)
		seq$(round$) = newColor$
    
		round$ = round$ + 1

		' Show new color on screen as circle
		LET ci$ = newColor$
		LET fillColor$ = RGB(cR$(ci$), cG$(ci$), cB$(ci$))

		SCREENLOCK ON
    
			LINE (0,0)-(639,479), 0, BF
			CIRCLE (CX#, CY#), CR#, fillColor$, 1
			CIRCLE (CX#, CY#), CR# + 1, RGB(255, 255, 255)
			CIRCLE (CX#, CY#), CR# + 2, RGB(255, 255, 255)
			CIRCLE (CX#, CY#), CR# + 3, RGB(255, 255, 255)

			REM color name under the circle
			LET nameText$ = cName$(ci$)
			LET nameCol$ = INT(40 - LEN(nameText$) / 2)
			LOCATE 42, nameCol$
			COLOR 15, 0
			PRINT nameText$

		SCREENLOCK OFF

		' show it up to 5 secs
		SLEEP 5000

		' clear screen and ask colors so far
		SCREENLOCK ON
		
			LINE (0,0)-(639,479), 0, BF

			LOCATE 8, 20
			COLOR 14, 0
			PRINT "Round "; round$

			LOCATE 11, 10
			COLOR 15, 0
			PRINT "Write all "; round$; " colors so far in order."
			
			LOCATE 12, 10
			PRINT "Seperate them with whitespace:"

			' Reminder of used colors
			LOCATE 27, 5
			COLOR 7, 0
			PRINT "black yellow white blue grey red brown green"

		SCREENLOCK OFF

		LOCATE 15, 10
		COLOR 11, 0
		LINE INPUT "> ", answer$

		' --- check answer--
		LET trimmed$ = TRIM(answer$)
		LET wordCount$ = SPLIT(words$, trimmed$, " ")

		LET correct$ = TRUE
		LET checkIdx$ = 0

		FOR i$ = 0 TO wordCount$ - 1
			IF LEN(words$(i$)) > 0 THEN
				IF checkIdx$ >= round$ THEN
					correct$ = FALSE
				ELSE
					LET given$ = LCASE(words$(i$))
					LET expected$ = LCASE(cName$(seq$(checkIdx$)))
					IF given$ <> expected$ THEN
						correct$ = FALSE
					ENDIF
				ENDIF
				checkIdx$ = checkIdx$ + 1
			ENDIF
		NEXT

		IF checkIdx$ <> round$ THEN
			correct$ = FALSE
		ENDIF

		' correct
		IF correct$ = TRUE THEN
			SCREENLOCK ON
				
				LINE (0,0)-(639,479), 0, BF
				LOCATE 13, 27
				COLOR 10, 0
				PRINT "Correct!!!"
				LOCATE 15, 22
				COLOR 15, 0
				PRINT "There is now "; round$; " colors to remember!"
			SCREENLOCK OFF
        
			SLEEP 2000
			GOTO [sub:newRound]
		ENDIF

		' wrong, game over
		LET score$ = round$ - 1

		SCREENLOCK ON
    
			LINE (0,0)-(639,479), 0, BF

			LOCATE 7, 24
			COLOR 12, 0
			PRINT "Wrong :("

			LOCATE 9, 22
			COLOR 15, 0
			PRINT "Your points: "; score$

			LOCATE 12, 18
			COLOR 14, 0
			PRINT "Correct order was:"

			LOCATE 14, 10
			COLOR 11, 0
    
			FOR i$ = 0 TO round$ - 1
				PRINT cName$(seq$(i$));
				IF i$ < round$ - 1 THEN
					PRINT " ";
				ENDIF
			NEXT
    
			PRINT ""

			LOCATE 17, 10
			COLOR 7, 0
			PRINT "Your answer:"
			
			LOCATE 18, 10
			COLOR 12, 0
			PRINT trimmed$

			LOCATE 21, 15
			COLOR 15, 0
			PRINT "New game: ENTER  /  Quit: ESC"
		SCREENLOCK OFF

		[waitEnd]
			LET k$ = INKEY
			IF k$ = KEY_ENTER# THEN
				DELARRAY seq$
				DIM seq$
				DELARRAY words$
				DIM words$
				GOTO [main:startNewGame]
			ENDIF
    
			IF k$ = KEY_ESC# THEN GOTO [quit]
			
			SLEEP 16
			GOTO [waitEnd]
		' [/waitEnd]
	' [/sub:newRound]	
' [/main:startNewGame]
	
[quit]
END