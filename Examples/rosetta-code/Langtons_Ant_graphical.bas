' ============================================
' Langton's Ant - graphical version
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Rules: on a white cell turn right, on a black cell turn left,
' flip the colour of the cell, then move forward one cell.
' The run ends when the ant walks off the 100 x 100 grid.

[inits]
    LET GRID#    = 100                  ' cells per side
    LET CELL#    = 5                    ' pixels per cell
    LET SCR_W#   = GRID# * CELL#
    LET SCR_H#   = GRID# * CELL#
    LET STEPS_PER_FRAME# = 40           ' simulation speed

    LET WHITE#   = RGB(255, 255, 255)
    LET BLACK#   = RGB(0, 0, 0)

    ' Directions: 0 = north, 1 = east, 2 = south, 3 = west
    DIM dx$
    DIM dy$
    dx$(0) =  0 : dy$(0) = -1
    dx$(1) =  1 : dy$(1) =  0
    dx$(2) =  0 : dy$(2) =  1
    dx$(3) = -1 : dy$(3) =  0

    ' Cell state: 0 = white, 1 = black
    DIM arena$
    FOR x$ = 0 TO GRID# - 1
        FOR y$ = 0 TO GRID# - 1
            arena$(x$, y$) = 0
        NEXT
    NEXT

    LET antX$    = GRID# / 2
    LET antY$    = GRID# / 2
    LET dir$     = 0                    ' ant starts facing north
    LET steps$   = 0
    LET running$ = TRUE
    LET key$     = 0
    LET px$      = 0
    LET py$      = 0
    LET info$    = ""

[init:screen]
    SCREEN 0, SCR_W#, SCR_H#, "Langton's Ant"
    SCREENLOCK ON
    LINE (0, 0)-(SCR_W#, SCR_H#), WHITE#, BF
    SCREENLOCK OFF

[main]
    WHILE running$
        key$ = INKEY
        IF key$ = KEY_ESC# THEN EXIT WHILE

        SCREENLOCK ON
        FOR n$ = 1 TO STEPS_PER_FRAME#
            GOSUB [sub:step]
            IF running$ = FALSE THEN EXIT FOR
        NEXT
        SCREENLOCK OFF
    WEND

    info$ = FSTRING("Steps: {{-steps$-}} - press any key")
    SCREENLOCK ON
    LINE (0, 0)-(230, 20), BLACK#, BF
    DRAWSTRING info$, 4, 2, WHITE#
    SCREENLOCK OFF
    key$ = WAITKEY()
END

' One move of the ant: turn, flip the cell, step forward
[sub:step]
    IF arena$(antX$, antY$) = 0 THEN
        dir$ = (dir$ + 1) % 4           ' white: turn right
    ELSE
        dir$ = (dir$ + 3) % 4           ' black: turn left
    END IF

    arena$(antX$, antY$) = 1 - arena$(antX$, antY$)

    px$ = antX$ * CELL#
    py$ = antY$ * CELL#
    IF arena$(antX$, antY$) = 1 THEN
        LINE (px$, py$)-(px$ + CELL# - 1, py$ + CELL# - 1), BLACK#, BF
    ELSE
        LINE (px$, py$)-(px$ + CELL# - 1, py$ + CELL# - 1), WHITE#, BF
    END IF

    antX$ += dx$(dir$)
    antY$ += dy$(dir$)
    steps$ += 1

    IF NOT BETWEEN(antX$, 0, GRID# - 1) OR NOT BETWEEN(antY$, 0, GRID# - 1) THEN
        running$ = FALSE
    END IF
RETURN