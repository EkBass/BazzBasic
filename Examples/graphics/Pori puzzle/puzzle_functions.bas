' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Helper functions for the Pori Swap Puzzle (pori_puzzle.bas): slot to pixel position, slot under a pixel, in-place check and m:ss time formatting. INCLUDEd by the main program, not run on its own.
' CATEGORY: games
' TAGS: puzzle, helper functions, grid coordinates, include
' MINVERSION: 1.5
' ============================================
' Every function here is "pure": it only uses its parameters.
' DEF FN scope is fully isolated (only # constants are visible), so
' passing the grid geometry in as arguments keeps these functions
' self-contained. They do not depend on the order in which the main
' program declares its constants.

' Pixel X of the top-left corner of a board slot (row-major order)
DEF FN SlotX$(slot$, cols$, pieceW$)
    RETURN MOD(slot$, cols$) * pieceW$
END DEF

' Pixel Y of the top-left corner of a board slot (row-major order)
DEF FN SlotY$(slot$, cols$, pieceH$)
    RETURN INT(slot$ / cols$) * pieceH$
END DEF

' Which slot is under pixel (px, py)? Returns -1 if outside the board.
DEF FN SlotAt$(px$, py$, cols$, rows$, pieceW$, pieceH$)
    IF px$ < 0 OR py$ < 0 THEN RETURN -1
    LET col$ = INT(px$ / pieceW$)
    LET row$ = INT(py$ / pieceH$)
    IF col$ >= cols$ OR row$ >= rows$ THEN RETURN -1
    RETURN row$ * cols$ + col$
END DEF

' 1 if the piece sitting in a slot is the one that belongs there
DEF FN InPlace$(slot$, piece$)
    IF slot$ = piece$ THEN RETURN TRUE
    RETURN FALSE
END DEF

' Seconds -> "m:ss"
DEF FN FormatTime$(secs$)
    LET m$ = INT(secs$ / 60)
    LET s$ = MOD(secs$, 60)
    RETURN m$ + ":" + RIGHT("0" + s$, 2)
END DEF