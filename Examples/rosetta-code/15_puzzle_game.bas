' ============================================
' ROSETTA: https://rosettacode.org/wiki/15_puzzle_game
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Fifteen puzzle: a shuffled 4x4 sliding-tile board where clicking a tile next to the gap slides it in, with a move counter and a solved message.
' CATEGORY: games
' TAGS: sliding puzzle, mouse, loadsheet, shuffle
' REQUIRES: assets/15.png
' MINVERSION: 1.5
' ============================================

[inits]
    LET TILE#          = 128
    LET SIZE#          = 4
    LET CELLS#         = SIZE# * SIZE#
    LET BOARD_PX#      = TILE# * SIZE#
    LET BAR_H#         = 40
    LET BAR_Y#         = BOARD_PX# + 12
    LET SCREEN_W#      = BOARD_PX#
    LET SCREEN_H#      = BOARD_PX# + BAR_H#
    LET SHUFFLE_MOVES# = 1000

    SCREEN 0, SCREEN_W#, SCREEN_H#, "15 Puzzle"

    LET BG_COLOR#   = RGB(30, 30, 40)
    LET BAR_COLOR#  = RGB(15, 15, 20)
    LET TEXT_COLOR# = RGB(230, 230, 230)
    LET WIN_COLOR#  = RGB(120, 230, 120)

    ' 128 x 1920 sheet -> tiles$(0) = "1" ... tiles$(14) = "15"
    DIM tiles$
    LOADSHEET tiles$, TILE#, TILE#, "assets/15.png"

    ' board$(cell) = tile number, 0 = gap. cell = row * SIZE# + col
    DIM board$
    LET blank$      = 0
    LET target$     = 0
    LET moved$      = FALSE
    LET moves$      = 0
    LET solved$     = FALSE
    LET running$    = TRUE
    LET key$        = 0
    LET mouseNow$   = 0
    LET mousePrev$  = 0
    LET row$ = 0, col$ = 0
    LET br$ = 0, bc$ = 0, tr$ = 0, tc$ = 0
    LET dir$ = 0, done$ = 0
    LET t$ = 0, x$ = 0, y$ = 0

[main]
    GOSUB [sub:newGame]

    WHILE running$
        key$ = INKEY
        IF key$ = KEY_ESC# THEN running$ = FALSE
        IF solved$ = TRUE AND key$ = KEY_SPACE# THEN GOSUB [sub:newGame]

        ' React to the press itself, not to a held button
        mouseNow$ = MOUSELEFT
        IF mouseNow$ = 1 AND mousePrev$ = 0 AND solved$ = FALSE THEN GOSUB [sub:click]
        mousePrev$ = mouseNow$

        GOSUB [sub:draw]
        SLEEP 16
    WEND

    FOR i$ = 0 TO ROWCOUNT(tiles$()) - 1
        REMOVESHAPE tiles$(i$)
    NEXT
END

' Solved board, then scrambled with legal moves -> always solvable
[sub:newGame]
    FOR i$ = 0 TO CELLS# - 2
        board$(i$) = i$ + 1
    NEXT
    board$(CELLS# - 1) = 0
    blank$ = CELLS# - 1
    GOSUB [sub:shuffle]
    moves$ = 0
RETURN

[sub:shuffle]
    solved$ = TRUE
    WHILE solved$
        done$ = 0
        WHILE done$ < SHUFFLE_MOVES#
            row$ = INT(blank$ / SIZE#)
            col$ = MOD(blank$, SIZE#)
            dir$ = RND(4)
            IF dir$ = 0 THEN
                row$ -= 1
            ELSEIF dir$ = 1 THEN
                row$ += 1
            ELSEIF dir$ = 2 THEN
                col$ -= 1
            ELSE
                col$ += 1
            END IF
            IF BETWEEN(row$, 0, SIZE# - 1) AND BETWEEN(col$, 0, SIZE# - 1) THEN
                target$ = row$ * SIZE# + col$
                GOSUB [sub:slide]
                done$ += 1
            END IF
        WEND
        GOSUB [sub:checkSolved]     ' reshuffle in the unlikely case it came back solved
    WEND
RETURN

[sub:click]
    IF MOUSEY < BOARD_PX# THEN
        row$ = CLAMP(INT(MOUSEY / TILE#), 0, SIZE# - 1)
        col$ = CLAMP(INT(MOUSEX / TILE#), 0, SIZE# - 1)
        target$ = row$ * SIZE# + col$
        GOSUB [sub:slide]
        IF moved$ THEN
            moves$ += 1
            GOSUB [sub:checkSolved]
        END IF
    END IF
RETURN

' Move tile at target$ into the gap if they are neighbours
[sub:slide]
    moved$ = FALSE
    br$ = INT(blank$ / SIZE#)
    bc$ = MOD(blank$, SIZE#)
    tr$ = INT(target$ / SIZE#)
    tc$ = MOD(target$, SIZE#)
    IF ABS(br$ - tr$) + ABS(bc$ - tc$) = 1 THEN
        board$(blank$)  = board$(target$)
        board$(target$) = 0
        blank$ = target$
        moved$ = TRUE
    END IF
RETURN

[sub:checkSolved]
    solved$ = TRUE
    FOR i$ = 0 TO CELLS# - 2
        IF board$(i$) <> i$ + 1 THEN solved$ = FALSE
    NEXT
RETURN

[sub:draw]
    SCREENLOCK ON
    LINE (0, 0)-(SCREEN_W#, SCREEN_H#), BG_COLOR#, BF

    FOR i$ = 0 TO CELLS# - 1
        IF board$(i$) > 0 THEN
            t$ = board$(i$) - 1
            x$ = MOD(i$, SIZE#) * TILE#
            y$ = INT(i$ / SIZE#) * TILE#
            MOVESHAPE tiles$(t$), x$, y$
            DRAWSHAPE tiles$(t$)
        END IF
    NEXT

    LINE (0, BOARD_PX#)-(SCREEN_W#, SCREEN_H#), BAR_COLOR#, BF
    IF solved$ THEN
        DRAWSTRING FSTRING("Solved in {{-moves$-}} moves!  SPACE = new game, ESC = quit"), 10, BAR_Y#, WIN_COLOR#
    ELSE
        DRAWSTRING FSTRING("Moves: {{-moves$-}}    Click a tile next to the gap    ESC = quit"), 10, BAR_Y#, TEXT_COLOR#
    END IF
    SCREENLOCK OFF
RETURN

' Output:
' A 512 x 552 window with a scrambled 4 x 4 board and a move counter.
' Clicking a tile beside the gap slides it in; when tiles 1-15 are in
' order the status bar shows "Solved in N moves!".