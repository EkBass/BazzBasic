' ============================================
' Pori Swap Puzzle
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' An 800x500 image is cut into 100x100 pieces (8 x 5 = 40) and shuffled.
' Left-click one piece, then another, and the two swap places.
' Hold the right mouse button to peek at the solved image.
' The game ends when every piece is back in its correct slot.

INCLUDE "puzzle_functions.bas"

[inits]
    ' --- Geometry ---
    LET IMAGE_FILE# = "assets/pori.png"
    LET PIECE_W#    = 100
    LET PIECE_H#    = 100
    LET COLS#       = 8
    LET ROWS#       = 5
    LET PIECES#     = COLS# * ROWS#
    LET BOARD_W#    = COLS# * PIECE_W#
    LET BOARD_H#    = ROWS# * PIECE_H#
    LET STATUS_H#   = 40
    LET SCREEN_W#   = BOARD_W#
    LET SCREEN_H#   = BOARD_H# + STATUS_H#

    ' Sprite anchor correction. Verified in testing: LOADSHEET tiles are
    ' top-left anchored and numbered row by row, so 0 is correct.
    LET ANCHOR_X# = 0
    LET ANCHOR_Y# = 0

    ' --- Colors (computed once, not every frame) ---
    LET COL_BG#          = RGB(20, 20, 30)
    LET COL_GRID#        = RGB(40, 40, 50)
    LET COL_SELECT#      = RGB(255, 220, 0)
    LET COL_TEXT#        = RGB(230, 230, 230)
    LET COL_BANNER#      = RGB(15, 15, 25)

    ' --- Game state ---
    DIM board$                  ' board$(slot) = index of the piece in that slot
    DIM sprites$                ' filled by LOADSHEET, 0-based
    LET selected$    = -1       ' first clicked slot, -1 = nothing selected
    LET clicked$     = -1
    LET moves$       = 0
    LET correct$     = 0
    LET mouseNow$    = 0
    LET mouseWas$    = 0
    LET peeking$     = FALSE    ' TRUE while the right button is held
    LET leave$       = FALSE
    LET j$           = 0
    LET tmp$         = 0
    LET px$          = 0
    LET py$          = 0
    LET startTicks$  = 0
    LET elapsed$     = 0
    LET timeText$    = "0:00"
    LET statusText$  = ""
    LET bannerLine$  = ""

[init:assets]
    IF FILEEXISTS(IMAGE_FILE#) = 0 THEN
        PRINT "Image not found: " + IMAGE_FILE#
        END
    END IF

    SCREEN 0, SCREEN_W#, SCREEN_H#, "Pori Swap Puzzle"

    LOADSHEET sprites$, PIECE_W#, PIECE_H#, IMAGE_FILE#

    ' Sanity check: an 800x500 image must yield exactly 40 tiles
    IF LEN(sprites$()) <> PIECES# THEN
        PRINT FSTRING("Expected {{-PIECES#-}} pieces, got a different count.")
        PRINT "Is the image exactly 800x500 pixels?"
        END
    END IF

[init:board]
    FOR i$ = 0 TO PIECES# - 1
        board$(i$) = i$
    NEXT

    ' Shuffle until the board is not already solved
    correct$ = PIECES#
    WHILE correct$ = PIECES#
        GOSUB [sub:shuffle]
        GOSUB [sub:countCorrect]
    WEND

    startTicks$ = TICKS

[main]
    WHILE INKEY <> KEY_ESC# AND correct$ < PIECES#
        peeking$ = MOUSERIGHT
        GOSUB [sub:handleMouse]
        GOSUB [sub:updateStatus]
        GOSUB [sub:renderPlay]
        SLEEP 16
    WEND

    IF correct$ = PIECES# THEN GOSUB [sub:victory]

    GOSUB [sub:cleanup]
END

' ============================================
' Logic
' ============================================

' Fisher-Yates shuffle: every ordering is equally likely
[sub:shuffle]
    FOR i$ = PIECES# - 1 TO 1 STEP -1
        j$ = RND(i$ + 1)
        tmp$ = board$(i$)
        board$(i$) = board$(j$)
        board$(j$) = tmp$
    NEXT
RETURN

' Full recount, used only after shuffling
[sub:countCorrect]
    correct$ = 0
    FOR c$ = 0 TO PIECES# - 1
        correct$ += FN InPlace$(c$, board$(c$))
    NEXT
RETURN

' Reacts to the moment the button goes down (edge detection), not
' while it is held. Left clicks are ignored while peeking: the player
' cannot see where the pieces really are, so a swap would be blind.
' mouseWas$ is still updated every frame, so letting go of the right
' button while the left one is held does not fire a stray click.
[sub:handleMouse]
    mouseNow$ = MOUSELEFT
    IF mouseNow$ = 1 AND mouseWas$ = 0 AND peeking$ = FALSE THEN
        clicked$ = FN SlotAt$(MOUSEX, MOUSEY, COLS#, ROWS#, PIECE_W#, PIECE_H#)
        IF clicked$ < 0 THEN
            selected$ = -1                  ' clicked the status bar: cancel
        ELSEIF selected$ = -1 THEN
            selected$ = clicked$            ' first pick
        ELSEIF clicked$ = selected$ THEN
            selected$ = -1                  ' same piece again: deselect
        ELSE
            GOSUB [sub:swap]
            selected$ = -1
        END IF
    END IF
    mouseWas$ = mouseNow$
RETURN

' Swap the pieces in slots selected$ and clicked$.
' The in-place count is updated incrementally: remove the two slots'
' old contribution, swap, add the new contribution.
[sub:swap]
    correct$ -= FN InPlace$(selected$, board$(selected$))
    correct$ -= FN InPlace$(clicked$, board$(clicked$))

    tmp$ = board$(selected$)
    board$(selected$) = board$(clicked$)
    board$(clicked$) = tmp$

    correct$ += FN InPlace$(selected$, board$(selected$))
    correct$ += FN InPlace$(clicked$, board$(clicked$))

    moves$ += 1
RETURN

[sub:updateStatus]
    elapsed$ = INT((TICKS - startTicks$) / 1000)
    timeText$ = FN FormatTime$(elapsed$)
    IF peeking$ THEN
        statusText$ = FSTRING("Peeking at the solution...    Time: {{-timeText$-}}    Release right button to continue")
    ELSE
        statusText$ = FSTRING("Moves: {{-moves$-}}    In place: {{-correct$-}} / {{-PIECES#-}}    Time: {{-timeText$-}}    Right button = peek")
    END IF
RETURN

' ============================================
' Rendering
' ============================================

[sub:renderPlay]
    SCREENLOCK ON
        IF peeking$ THEN
            GOSUB [sub:drawSolved]
        ELSE
            GOSUB [sub:drawBoard]
            GOSUB [sub:drawGrid]
            GOSUB [sub:drawSelection]
        END IF
        GOSUB [sub:drawStatus]
    SCREENLOCK OFF
RETURN

[sub:renderWin]
    SCREENLOCK ON
        GOSUB [sub:drawBoard]           ' no grid: show the seamless picture
        GOSUB [sub:drawStatus]
        GOSUB [sub:drawBanner]
    SCREENLOCK OFF
RETURN

' Current (scrambled) state: slot s$ shows piece board$(s$)
[sub:drawBoard]
    FOR s$ = 0 TO PIECES# - 1
        px$ = FN SlotX$(s$, COLS#, PIECE_W#)
        py$ = FN SlotY$(s$, COLS#, PIECE_H#)
        MOVESHAPE sprites$(board$(s$)), px$ + ANCHOR_X#, py$ + ANCHOR_Y#
        DRAWSHAPE sprites$(board$(s$))
    NEXT
RETURN

' Solved state: slot s$ shows piece s$. board$ is not modified,
' so releasing the right button returns to the exact same game.
[sub:drawSolved]
    FOR s$ = 0 TO PIECES# - 1
        px$ = FN SlotX$(s$, COLS#, PIECE_W#)
        py$ = FN SlotY$(s$, COLS#, PIECE_H#)
        MOVESHAPE sprites$(s$), px$ + ANCHOR_X#, py$ + ANCHOR_Y#
        DRAWSHAPE sprites$(s$)
    NEXT
RETURN

[sub:drawGrid]
    FOR g$ = 1 TO COLS# - 1
        LINE (g$ * PIECE_W#, 0)-(g$ * PIECE_W#, BOARD_H# - 1), COL_GRID#
    NEXT
    FOR g$ = 1 TO ROWS# - 1
        LINE (0, g$ * PIECE_H#)-(BOARD_W# - 1, g$ * PIECE_H#), COL_GRID#
    NEXT
RETURN

' 3-pixel frame around the selected piece
[sub:drawSelection]
    IF selected$ >= 0 THEN
        px$ = FN SlotX$(selected$, COLS#, PIECE_W#)
        py$ = FN SlotY$(selected$, COLS#, PIECE_H#)
        FOR t$ = 0 TO 2
            LINE (px$ + t$, py$ + t$)-(px$ + PIECE_W# - 1 - t$, py$ + PIECE_H# - 1 - t$), COL_SELECT#, B
        NEXT
    END IF
RETURN

[sub:drawStatus]
    LINE (0, BOARD_H#)-(SCREEN_W# - 1, SCREEN_H# - 1), COL_BG#, BF
    DRAWSTRING statusText$, 12, BOARD_H# + 12, COL_TEXT#
RETURN

' Text positions are hand-tuned for the default 16px Arial;
' BazzBasic has no text-width function to center text exactly.
[sub:drawBanner]
    LINE (200, 170)-(600, 320), COL_BANNER#, BF
    LINE (200, 170)-(600, 320), COL_SELECT#, B
    DRAWSTRING "Puzzle solved!", 350, 200, COL_SELECT#
    DRAWSTRING bannerLine$, 335, 240, COL_TEXT#
    DRAWSTRING "Press any key or click to exit", 295, 280, COL_TEXT#
RETURN

' ============================================
' End of game
' ============================================

[sub:victory]
    bannerLine$ = FSTRING("{{-moves$-}} moves, time {{-timeText$-}}")
    statusText$ = FSTRING("Solved!    Moves: {{-moves$-}}    Time: {{-timeText$-}}")

    ' The button may still be held from the winning click, so prime the
    ' edge detector to avoid closing the window instantly.
    mouseWas$ = MOUSELEFT

    WHILE INKEY = 0 AND leave$ = FALSE
        GOSUB [sub:renderWin]
        mouseNow$ = MOUSELEFT
        IF mouseNow$ = 1 AND mouseWas$ = 0 THEN leave$ = TRUE
        mouseWas$ = mouseNow$
        SLEEP 16
    WEND
RETURN

[sub:cleanup]
    FOR r$ = 0 TO PIECES# - 1
        REMOVESHAPE sprites$(r$)
    NEXT
RETURN

' Output:
' A 800x540 window opens with the scrambled 8x5 image and a status bar:
'   Moves: 0    In place: 1 / 40    Time: 0:07    Right button = peek
' Left-click a piece (yellow frame), left-click another, and they swap.
' Hold the right button: the solved image is shown until you release it.
' When all 40 are in place, a "Puzzle solved!" banner shows moves and time.