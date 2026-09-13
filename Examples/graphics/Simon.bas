' ============================================
' Simon Says
' Ported from Python (turtle-based) to BazzBasic
' Original concept: freegames "simonsays" example
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Click any tile to begin. Watch the flashing
' pattern, then click the tiles back in the same
' order. Each correct round adds one more tile.
' ESC quits at any time.
' ============================================

[inits]
    ' --- Window ---
    LET TILE#     = 200                 ' size of one square tile, in pixels
    LET GRID_W#   = 400                 ' TILE# * 2  (2x2 grid)
    LET SCREEN_W# = 400
    LET SCREEN_H# = 480                 ' GRID_W# + room for the status bar
    SCREEN 0, SCREEN_W#, SCREEN_H#, "Simon Says - BazzBasic"

    ' --- Game states ---
    LET STATE_START#    = 0
    LET STATE_INPUT#    = 1
    LET STATE_GAMEOVER# = 2

    ' --- Colors ---
    LET COL_BG#     = RGB(18, 18, 30)
    LET COL_TEXT#   = RGB(230, 230, 230)
    LET COL_HINT#   = RGB(140, 140, 160)
    LET COL_BORDER# = RGB(70, 70, 95)

    ' --- Tile layout: 0=top-left 1=top-right 2=bottom-left 3=bottom-right ---
    DIM tileX$
    DIM tileY$
    DIM tileDark$
    DIM tileLight$

    tileX$(0) = 0      : tileY$(0) = 0
    tileX$(1) = TILE#  : tileY$(1) = 0
    tileX$(2) = 0      : tileY$(2) = TILE#
    tileX$(3) = TILE#  : tileY$(3) = TILE#

    tileDark$(0)  = RGB(0, 90, 0)      : tileLight$(0) = RGB(40, 205, 40)    ' green
    tileDark$(1)  = RGB(130, 0, 0)     : tileLight$(1) = RGB(235, 30, 30)    ' red
    tileDark$(2)  = RGB(150, 140, 20)  : tileLight$(2) = RGB(255, 230, 30)   ' yellow
    tileDark$(3)  = RGB(0, 0, 130)     : tileLight$(3) = RGB(40, 110, 255)   ' blue

    ' --- Game data ---
    DIM pattern$                       ' grows by one tile index every round
    LET round$     = 0                 ' current pattern length
    LET guessIdx$  = 0                 ' player's position within the pattern
    LET state$     = STATE_START#

    ' --- Mouse polling state ---
    LET mx$          = 0
    LET my$          = 0
    LET ml$          = 0
    LET prevL$       = 0
    LET newClick$    = 0
    LET clickedTile$ = -1
    LET col$         = 0
    LET row$         = 0

    ' --- Used by the flash/draw subs ---
    LET flashIdx$    = 0
    LET flashBright$ = 0
    LET statusText$  = "SIMON SAYS"
    LET statusText2$ = "Click any tile to start"

    LET running$ = TRUE

    GOSUB [sub:drawGrid]

[main]
    WHILE running$
        IF INKEY = KEY_ESC# THEN running$ = FALSE

        mx$ = MOUSEX
        my$ = MOUSEY
        ml$ = MOUSELEFT
        newClick$ = (ml$ = 1 AND prevL$ = 0)   ' edge-detect: fire only on 0->1
        prevL$ = ml$

        IF newClick$ THEN
            GOSUB [sub:getTileAtMouse]

            IF state$ = STATE_START# THEN
                GOSUB [sub:growPattern]
                state$ = STATE_INPUT#

            ELSEIF state$ = STATE_INPUT# THEN
                IF clickedTile$ >= 0 THEN
                    IF clickedTile$ = pattern$(guessIdx$) THEN
                        ' correct tap - brief feedback flash
                        flashIdx$    = clickedTile$
                        flashBright$ = 1
                        GOSUB [sub:drawTile]
                        SLEEP 250
                        flashBright$ = 0
                        GOSUB [sub:drawTile]

                        guessIdx$ = guessIdx$ + 1
                        IF guessIdx$ = round$ THEN
                            GOSUB [sub:growPattern]
                        END IF
                    ELSE
                        state$        = STATE_GAMEOVER#
                        statusText$   = "Wrong! Game over."
                        statusText2$  = "Score: " + STR(round$ - 1) + " - click to retry"
                        GOSUB [sub:drawStatus]
                    END IF
                END IF

            ELSEIF state$ = STATE_GAMEOVER# THEN
                DELARRAY pattern$ : DIM pattern$
                round$        = 0
                guessIdx$     = 0
                state$        = STATE_START#
                statusText$   = "SIMON SAYS"
                statusText2$  = "Click any tile to start"
                GOSUB [sub:drawGrid]
            END IF
        END IF

        SLEEP 16
    WEND
END

' ------------------------------------------------
' Convert the current mouse position into a tile
' index (0-3), or -1 if the click was outside the
' 2x2 grid (e.g. in the status bar).
' ------------------------------------------------
[sub:getTileAtMouse]
    IF mx$ >= 0 AND mx$ < GRID_W# AND my$ >= 0 AND my$ < GRID_W# THEN
        col$ = FLOOR(mx$ / TILE#)
        row$ = FLOOR(my$ / TILE#)
        clickedTile$ = row$ * 2 + col$
    ELSE
        clickedTile$ = -1
    END IF
RETURN

' ------------------------------------------------
' Add one random tile to the pattern, then flash
' the whole pattern from the start so the player
' can watch and memorize it.
' ------------------------------------------------
[sub:growPattern]
    round$ = round$ + 1
    pattern$(round$ - 1) = RND(4)

    statusText$  = "Watch..."
    statusText2$ = "Round " + STR(round$)
    GOSUB [sub:drawStatus]
    SLEEP 400

    FOR i$ = 0 TO round$ - 1
        flashIdx$    = pattern$(i$)
        flashBright$ = 1
        GOSUB [sub:drawTile]
        SLEEP 500
        flashBright$ = 0
        GOSUB [sub:drawTile]
        SLEEP 250
    NEXT i$

    guessIdx$    = 0
    statusText$  = "Your turn!"
    statusText2$ = "Repeat the " + STR(round$) + "-tile pattern"
    GOSUB [sub:drawStatus]
RETURN

' ------------------------------------------------
' Draw the whole board: background, all 4 tiles
' in their resting (dark) color, plus the status
' bar text.
' ------------------------------------------------
[sub:drawGrid]
    SCREENLOCK ON
        LINE (0, 0)-(SCREEN_W#, SCREEN_H#), COL_BG#, BF
        LINE (0, 0)-(GRID_W# - 1, GRID_W# - 1), COL_BORDER#, B
    SCREENLOCK OFF

    FOR i$ = 0 TO 3
        flashIdx$    = i$
        flashBright$ = 0
        GOSUB [sub:drawTile]
    NEXT i$

    GOSUB [sub:drawStatus]
RETURN

' ------------------------------------------------
' Redraw a single tile, either lit (flashBright$=1)
' or resting (flashBright$=0). Reused both for the
' pattern playback and for the player's own taps.
' ------------------------------------------------
[sub:drawTile]
    SCREENLOCK ON
        IF flashBright$ = 1 THEN
            LINE (tileX$(flashIdx$) + 4, tileY$(flashIdx$) + 4)-(tileX$(flashIdx$) + TILE# - 4, tileY$(flashIdx$) + TILE# - 4), tileLight$(flashIdx$), BF
        ELSE
            LINE (tileX$(flashIdx$) + 4, tileY$(flashIdx$) + 4)-(tileX$(flashIdx$) + TILE# - 4, tileY$(flashIdx$) + TILE# - 4), tileDark$(flashIdx$), BF
        END IF
    SCREENLOCK OFF
RETURN

' ------------------------------------------------
' Redraw just the status bar (below the grid) with
' the two current message lines plus a fixed hint.
' ------------------------------------------------
[sub:drawStatus]
    SCREENLOCK ON
        LINE (0, GRID_W#)-(SCREEN_W#, SCREEN_H#), COL_BG#, BF
        DRAWSTRING statusText$,  10, GRID_W# + 10, COL_TEXT#
        DRAWSTRING statusText2$, 10, GRID_W# + 34, COL_TEXT#
        DRAWSTRING "ESC to quit", 10, GRID_W# + 58, COL_HINT#
    SCREENLOCK OFF
RETURN

' Output: a 400x480 window opens. A 2x2 grid of
' green/red/yellow/blue tiles fills the top 400px;
' a status bar below shows round number and score.
' Click any tile to start; the pattern flashes,
' then you tap it back; each success grows the
' pattern by one tile until you miss.