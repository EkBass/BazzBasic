' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Conway's Game of Life on a 64x48 wrap-around grid with adjustable speed, pause/resume and random restart; uses the helper functions in life_functions.bas.
' CATEGORY: simulation
' TAGS: game of life, cellular automaton, wrap-around grid, double buffering, speed control
' REQUIRES: life_functions.bas
' MINVERSION: 1.5
' ============================================
' Controls:
'   A      faster
'   S      slower
'   SPACE  pause / resume
'   R      new random world
'   ESC    quit
'
' Letter keys are used for speed on purpose: "+" and "-" sit in
' different places on different keyboard layouts, and the numpad
' versions send different key codes. A and S exist on every layout.

INCLUDE "life_functions.bas"

[inits]
    ' --- Grid geometry ---
    LET CELL#   = 10                    ' cell size in pixels
    LET COLS#   = 64                    ' 64 * 10 = 640 px
    LET ROWS#   = 48                    ' 48 * 10 = 480 px
    LET GRID_W# = COLS# * CELL#
    LET GRID_H# = ROWS# * CELL#
    LET HUD_H#  = 40                    ' info strip under the grid
    LET SCREEN_W# = GRID_W#
    LET SCREEN_H# = GRID_H# + HUD_H#

    ' --- Simulation settings ---
    LET DENSITY# = 25                   ' % of cells alive in a random world

    ' --- Colors (RGB computed once, never inside hot loops) ---
    LET COLOR_BG#   = RGB(12, 14, 20)
    LET COLOR_CELL# = RGB(90, 220, 130)
    LET COLOR_HUD#  = RGB(30, 34, 46)
    LET COLOR_TEXT# = RGB(230, 230, 230)
    LET COLOR_HELP# = RGB(150, 150, 165)

    LET HELP# = "A faster   S slower   SPACE pause   R new world   ESC quit"

    ' --- Speed table: delay in ms between generations ---
    ' Level 0 is the slowest, the last level is "as fast as possible".
    ' SPLIT returns the element count, so the table length is never
    ' hard-coded anywhere else in the program.
    DIM speedDelay$
    LET levelCount$ = SPLIT(speedDelay$, "1000,700,500,350,250,160,100,60,30,15,0", ",")
    LET maxLevel$   = levelCount$ - 1
    LET speedLevel$ = INT(levelCount$ / 2)
    LET delay$      = VAL(speedDelay$(speedLevel$))
    LET speedShown$ = speedLevel$ + 1

    ' --- Precomputed wrap-around neighbour indices ---
    ' Built once with WrapIndex$, so the hot loop does plain array reads
    ' instead of thousands of MOD calls per generation.
    DIM colLeft$, colRight$, rowUp$, rowDown$

    ' --- World: two buffers in one array, cells$(buffer, x, y) ---
    ' The simulation reads from buffer cur$ and writes into nxt$, then the
    ' roles swap. No copying of the whole grid is ever needed.
    DIM cells$
    LET cur$ = 0
    LET nxt$ = 1

    ' --- Program state ---
    LET running$    = TRUE
    LET paused$     = FALSE
    LET redraw$     = TRUE
    LET key$        = 0
    LET generation$ = 0
    LET population$ = 0
    LET lastStep$   = 0
    LET stateText$  = "RUNNING"
    LET hud$        = ""

    ' --- Work variables used by the subroutines ---
    LET n$     = 0
    LET state$ = 0
    LET colL$  = 0
    LET colR$  = 0
    LET rowU$  = 0
    LET rowD$  = 0
    LET px$    = 0
    LET py$    = 0

[init:screen]
    SCREEN 0, SCREEN_W#, SCREEN_H#, "Conway's Game of Life"
    GOSUB [sub:buildNeighbours]
    GOSUB [sub:randomWorld]
    LET lastStep$ = TICKS

[main]
    WHILE running$
        key$ = INKEY

        IF key$ = KEY_ESC# THEN running$ = FALSE

        IF key$ = KEY_A# THEN
            speedLevel$ = FN StepLevel$(speedLevel$, 1, maxLevel$)
            GOSUB [sub:applySpeed]
        END IF

        IF key$ = KEY_S# THEN
            speedLevel$ = FN StepLevel$(speedLevel$, -1, maxLevel$)
            GOSUB [sub:applySpeed]
        END IF

        IF key$ = KEY_SPACE# THEN
            IF paused$ THEN
                paused$ = FALSE
                stateText$ = "RUNNING"
                lastStep$ = TICKS
            ELSE
                paused$ = TRUE
                stateText$ = "PAUSED"
            END IF
            redraw$ = TRUE
        END IF

        IF key$ = KEY_R# THEN
            GOSUB [sub:randomWorld]
            lastStep$ = TICKS
        END IF

        ' Advance one generation when enough time has passed.
        ' Input is read every frame, so keys stay responsive even
        ' at the slowest speed (1000 ms between generations).
        IF paused$ = FALSE AND TICKS - lastStep$ >= delay$ THEN
            GOSUB [sub:step]
            lastStep$ = TICKS
            redraw$ = TRUE
        END IF

        ' Only repaint when something actually changed.
        IF redraw$ THEN
            GOSUB [sub:draw]
            redraw$ = FALSE
        END IF

        SLEEP 5
    WEND
END

' ============================================
' Subroutines
' ============================================
' Each subroutine uses its OWN loop variable names (bx$/by$, rx$/ry$,
' sx$/sy$, dx$/dy$). GOSUB shares the caller's scope, so reusing names
' like x$/y$ everywhere is a classic source of hard-to-find bugs.

' --------------------------------------------
' Build wrap-around lookup tables for both axes
' --------------------------------------------
[sub:buildNeighbours]
    FOR bx$ = 0 TO COLS# - 1
        colLeft$(bx$)  = FN WrapIndex$(bx$ - 1, COLS#)
        colRight$(bx$) = FN WrapIndex$(bx$ + 1, COLS#)
    NEXT bx$
    FOR by$ = 0 TO ROWS# - 1
        rowUp$(by$)   = FN WrapIndex$(by$ - 1, ROWS#)
        rowDown$(by$) = FN WrapIndex$(by$ + 1, ROWS#)
    NEXT by$
RETURN

' --------------------------------------------
' Fill the current buffer randomly, clear the other one
' --------------------------------------------
[sub:randomWorld]
    population$ = 0
    FOR ry$ = 0 TO ROWS# - 1
        FOR rx$ = 0 TO COLS# - 1
            state$ = FN RandomCell$(DENSITY#)
            cells$(cur$, rx$, ry$) = state$
            cells$(nxt$, rx$, ry$) = 0
            population$ += state$
        NEXT rx$
    NEXT ry$
    generation$ = 0
    redraw$ = TRUE
RETURN

' --------------------------------------------
' Compute one generation: read cur$, write nxt$, swap
' --------------------------------------------
[sub:step]
    population$ = 0
    FOR sy$ = 0 TO ROWS# - 1
        rowU$ = rowUp$(sy$)
        rowD$ = rowDown$(sy$)
        FOR sx$ = 0 TO COLS# - 1
            colL$ = colLeft$(sx$)
            colR$ = colRight$(sx$)

            ' Sum of the 8 surrounding cells (cells hold 0 or 1).
            ' A line ending in "+" continues on the next line.
            n$ = cells$(cur$, colL$, rowU$) + cells$(cur$, sx$, rowU$) + cells$(cur$, colR$, rowU$) +
                 cells$(cur$, colL$, sy$)                              + cells$(cur$, colR$, sy$) +
                 cells$(cur$, colL$, rowD$) + cells$(cur$, sx$, rowD$) + cells$(cur$, colR$, rowD$)

            state$ = FN NextCellState$(cells$(cur$, sx$, sy$), n$)
            cells$(nxt$, sx$, sy$) = state$
            population$ += state$
        NEXT sx$
    NEXT sy$

    ' Swap buffer roles: the freshly written one becomes current.
    cur$ = 1 - cur$
    nxt$ = 1 - nxt$
    generation$ += 1
RETURN

' --------------------------------------------
' Recalculate delay after a speed change
' --------------------------------------------
[sub:applySpeed]
    delay$ = VAL(speedDelay$(speedLevel$))
    speedShown$ = speedLevel$ + 1
    redraw$ = TRUE
RETURN

' --------------------------------------------
' Draw the grid and the HUD in one buffered frame
' --------------------------------------------
[sub:draw]
    SCREENLOCK ON
    LINE (0, 0)-(GRID_W# - 1, GRID_H# - 1), COLOR_BG#, BF

    ' Only live cells are drawn; the 1 px gap gives a grid look.
    FOR dy$ = 0 TO ROWS# - 1
        FOR dx$ = 0 TO COLS# - 1
            IF cells$(cur$, dx$, dy$) = 1 THEN
                px$ = dx$ * CELL#
                py$ = dy$ * CELL#
                LINE (px$, py$)-(px$ + CELL# - 2, py$ + CELL# - 2), COLOR_CELL#, BF
            END IF
        NEXT dx$
    NEXT dy$

    ' HUD strip
    LINE (0, GRID_H#)-(SCREEN_W# - 1, SCREEN_H# - 1), COLOR_HUD#, BF
    hud$ = FSTRING("Gen {{-generation$-}}    Pop {{-population$-}}    Speed {{-speedShown$-}}/{{-levelCount$-}} ({{-delay$-}} ms)    {{-stateText$-}}")
    DRAWSTRING hud$, 8, GRID_H# + 2, COLOR_TEXT#
    DRAWSTRING HELP#, 8, GRID_H# + 20, COLOR_HELP#
    SCREENLOCK OFF
RETURN

' Output:
' A 640x520 window. Green cells evolve on a dark 64x48 grid whose
' edges wrap around (a glider leaving on the right re-enters on the
' left). The bottom strip shows, for example:
'   Gen 214    Pop 387    Speed 6/11 (160 ms)    RUNNING
'   A faster   S slower   SPACE pause   R new world   ESC quit