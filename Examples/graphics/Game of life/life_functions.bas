' ============================================
' life_functions.bas
' Helper functions for Conway's Game of Life
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' This file contains ONLY DEF FN definitions, no loose code.
' It is meant to be INCLUDEd at the top of the main program,
' before any of these functions are called.
'
' Every function is self-contained: all inputs come in as
' parameters, so the file does not depend on any constants
' defined by the program that includes it.

' --------------------------------------------
' WrapIndex$ - toroidal (wrap-around) coordinate
'   i$    : index, may be -1 or size$ (one step off the edge)
'   size$ : number of cells along that axis
' Returns an index in the range 0 .. size$-1.
' Adding size$ before MOD keeps the left operand non-negative,
' so -1 wraps cleanly to size$-1.



' --------------------------------------------
DEF FN WrapIndex$(i$, size$)
    RETURN MOD(i$ + size$, size$)
END DEF

' --------------------------------------------
' NextCellState$ - Conway's rules (B3/S23)
'   alive$      : 1 if the cell is alive now, 0 if dead
'   neighbours$ : number of live neighbours (0..8)
' Returns 1 (alive) or 0 (dead) for the next generation.
'   - Any cell with exactly 3 neighbours is alive next turn
'     (birth if dead, survival if alive).
'   - A live cell with exactly 2 neighbours survives.
'   - Everything else dies or stays dead.
' --------------------------------------------
DEF FN NextCellState$(alive$, neighbours$)
    IF neighbours$ = 3 THEN RETURN 1
    IF alive$ = 1 AND neighbours$ = 2 THEN RETURN 1
    RETURN 0
END DEF

' --------------------------------------------
' RandomCell$ - random seeding
'   density$ : chance (0..100) that the cell starts alive
' Returns 1 or 0.
' --------------------------------------------
DEF FN RandomCell$(density$)
    IF RND(100) < density$ THEN RETURN 1
    RETURN 0
END DEF

' --------------------------------------------
' StepLevel$ - move a speed level up or down, clamped
'   level$    : current level (0-based)
'   delta$    : +1 (faster) or -1 (slower)
'   maxLevel$ : highest allowed level
' Returns the new level, never below 0 or above maxLevel$.
' --------------------------------------------
DEF FN StepLevel$(level$, delta$, maxLevel$)
    RETURN CLAMP(level$ + delta$, 0, maxLevel$)
END DEF