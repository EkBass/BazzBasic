' ==========================================
' Color Memory Game — BazzBasic: Color_memory_game.bas
' https://ekbass.github.io/BazzBasic/
' Public Domain
' ==========================================

[inits]
    LET NUM_COLORS# = 8
    LET CX#  = 320          ' circle center X
    LET CY#  = 200          ' circle center Y
    LET CR#  = 100          ' circle radius

    ' Console color palette indices
    LET BLACK#   = 0
    LET RED#     = 4
    LET LGRAY#   = 7
    LET LGREEN#  = 10
    LET CYAN#    = 11
    LET LRED#    = 12
    LET YELLOW#  = 14
    LET WHITE#   = 15

    ' Color table: name + RGB components (parallel arrays)
    DIM cName$
    DIM cR$
    DIM cG$
    DIM cB$

    cName$(0) = "black"  : cR$(0) = 0   : cG$(0) = 0   : cB$(0) = 0
    cName$(1) = "yellow" : cR$(1) = 255 : cG$(1) = 255 : cB$(1) = 0
    cName$(2) = "white"  : cR$(2) = 255 : cG$(2) = 255 : cB$(2) = 255
    cName$(3) = "blue"   : cR$(3) = 40  : cG$(3) = 80  : cB$(3) = 255
    cName$(4) = "grey"   : cR$(4) = 160 : cG$(4) = 160 : cB$(4) = 160
    cName$(5) = "red"    : cR$(5) = 230 : cG$(5) = 30  : cB$(5) = 30
    cName$(6) = "brown"  : cR$(6) = 150 : cG$(6) = 80  : cB$(6) = 20
    cName$(7) = "green"  : cR$(7) = 30  : cG$(7) = 200 : cB$(7) = 30

    DIM seq$
    DIM words$
	
	' [main:startNewGame]
    LET round$ = 0
	
	' [sub:newRound]
	LET newColor$, ci$, fillColor$, trimmed$
	LET wordCount$, correct$, checkIdx$, score$
	LET nameText$, nameCol$
	LET given$, expected$
	
	' [waitEnd]
	LET k$


[intro]
    SCREEN 0, 640, 480, "Color Memory Game"
    SCREENLOCK ON
        LINE (0,0)-(639,479), 0, BF

        LOCATE 8, 23
        COLOR YELLOW#, BLACK#
        PRINT "COLOR MEMORY GAME"

        LOCATE 10, 15
        COLOR WHITE#, BLACK#
        PRINT "A colored circle appears on the screen."
        LOCATE 11, 15
        PRINT "You see it for 5 seconds only."
        LOCATE 12, 15
        PRINT "Remember the order of the colors!"
        LOCATE 14, 15
        PRINT "A new color is added each round."
        LOCATE 15, 15
        PRINT "Type ALL colors seen so far, in order."

        LOCATE 18, 15
        COLOR CYAN#, BLACK#
        PRINT "Colors: black, yellow, white,"
        LOCATE 19, 15
        PRINT "blue, grey, red, brown, green"

        LOCATE 22, 18
        COLOR LGREEN#, BLACK#
        PRINT "Press ENTER to start..."
    SCREENLOCK OFF

    k$ = WAITKEY(KEY_ENTER#)


[main:startNewGame]
    round$ = 0

[sub:newRound]
    ' Add a random color to the sequence
    newColor$ = RND(NUM_COLORS#)
    seq$(round$) = newColor$
    round$ = round$ + 1

    ' Show the new color as a filled circle
    ci$        = newColor$
    fillColor$ = RGB(cR$(ci$), cG$(ci$), cB$(ci$))

    SCREENLOCK ON
        LINE (0,0)-(639,479), 0, BF
        CIRCLE (CX#, CY#), CR#,     fillColor$, 1
        CIRCLE (CX#, CY#), CR# + 1, RGB(255,255,255)
        CIRCLE (CX#, CY#), CR# + 2, RGB(255,255,255)
        CIRCLE (CX#, CY#), CR# + 3, RGB(255,255,255)

        nameText$ = cName$(ci$)
        nameCol$  = INT(40 - LEN(nameText$) / 2)
        LOCATE 42, nameCol$
        COLOR WHITE#, BLACK#
        PRINT nameText$
    SCREENLOCK OFF

    SLEEP 5000

    ' Clear and prompt for all colors seen so far
    SCREENLOCK ON
        LINE (0,0)-(639,479), 0, BF

        LOCATE 8, 20
        COLOR YELLOW#, BLACK#
        PRINT "Round "; round$

        LOCATE 11, 10
        COLOR WHITE#, BLACK#
        PRINT "Type all "; round$; " colors in order, separated by spaces:"

        LOCATE 27, 5
        COLOR LGRAY#, BLACK#
        PRINT "black  yellow  white  blue  grey  red  brown  green"
    SCREENLOCK OFF

    LOCATE 15, 10
    COLOR CYAN#, BLACK#
    LINE INPUT "> ", answer$

	
    ' --- Check answer ---
    trimmed$  = TRIM(answer$)
    wordCount$ = SPLIT(words$, trimmed$, " ")

    correct$  = TRUE
    checkIdx$ = 0

    FOR i$ = 0 TO wordCount$ - 1
        IF LEN(words$(i$)) > 0 THEN
            IF checkIdx$ >= round$ THEN
                correct$ = FALSE
            ELSE
                given$    = LCASE(words$(i$))
                expected$ = LCASE(cName$(seq$(checkIdx$)))
                IF given$ <> expected$ THEN correct$ = FALSE
            END IF
            checkIdx$ = checkIdx$ + 1
        END IF
    NEXT

    IF checkIdx$ <> round$ THEN correct$ = FALSE

    ' Correct — next round
    IF correct$ = TRUE THEN
        SCREENLOCK ON
            LINE (0,0)-(639,479), 0, BF
            LOCATE 13, 27
            COLOR LGREEN#, BLACK#
            PRINT "Correct!"
            LOCATE 15, 22
            COLOR WHITE#, BLACK#
            PRINT round$; " colors in memory — adding one more!"
        SCREENLOCK OFF
        SLEEP 2000
        GOTO [sub:newRound]
    END IF

    ' Wrong — game over screen
    score$ = round$ - 1

    SCREENLOCK ON
        LINE (0,0)-(639,479), 0, BF

        LOCATE 7, 24
        COLOR LRED#, BLACK#
        PRINT "Wrong :("

        LOCATE 9, 22
        COLOR WHITE#, BLACK#
        PRINT "Your score: "; score$

        LOCATE 12, 18
        COLOR YELLOW#, BLACK#
        PRINT "Correct order was:"

        LOCATE 14, 10
        COLOR CYAN#, BLACK#
        FOR i$ = 0 TO round$ - 1
            PRINT cName$(seq$(i$));
            IF i$ < round$ - 1 THEN PRINT " ";
        NEXT
        PRINT ""

        LOCATE 17, 10
        COLOR LGRAY#, BLACK#
        PRINT "Your answer:"
        LOCATE 18, 10
        COLOR LRED#, BLACK#
        PRINT trimmed$

        LOCATE 21, 15
        COLOR WHITE#, BLACK#
        PRINT "New game: ENTER     Quit: ESC"
    SCREENLOCK OFF

[waitEnd]
    k$ = INKEY
    IF k$ = KEY_ENTER# THEN
        DELARRAY seq$   : DIM seq$
        DELARRAY words$ : DIM words$
        GOTO [main:startNewGame]
    END IF
    IF k$ = KEY_ESC# THEN GOTO [quit]
    SLEEP 16
    GOTO [waitEnd]

[quit]
END