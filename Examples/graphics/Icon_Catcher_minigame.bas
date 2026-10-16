' ============================================================
' Icon Catcher - BazzBasic port of a SmallBasic minigame
' Original: https://smallbasic.com/smallbasic.com/program/?nts150
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================================
' Move the bucket with the mouse and catch the falling icons.
' ESC quits.
' ============================================================

[inits]
    ' --- Screen & layout ---
    LET SCREEN_W#      = 640
    LET SCREEN_H#      = 480
    LET NUM_FRUITS#    = 10
    LET BUCKET_W#      = 80
    LET BUCKET_H#      = 20
    LET BUCKET_Y#      = 450                ' bucket centre Y (LOADSHAPE is centre-anchored)
    LET ICON_SIZE#     = 64                 ' native size of B-icon.png in pixels
    LET SCALE_DIVISOR# = 3                  ' fall speed / SCALE_DIVISOR# = render scale

    ' --- Assets (relative to PRG_ROOT#) ---
    LET FRUIT_PATH# = "assets\\B-icon.png"
    LET COIN_PATH#  = "assets\\coin.mp3"

    ' --- Colours (computed once, not per frame) ---
    LET COL_SKY#    = RGB(135, 206, 235)
    LET COL_BUCKET# = RGB(160, 100, 40)
    LET COL_TEXT#   = RGB(255, 255, 0)

    SCREEN 0, SCREEN_W#, SCREEN_H#, "Icon Catcher"

    LET COIN#   = LOADSOUND(COIN_PATH#)
    LET BUCKET# = LOADSHAPE("RECTANGLE", BUCKET_W#, BUCKET_H#, COL_BUCKET#)

    ' --- Per-fruit state ---
    DIM fruits$                             ' image handles
    DIM fruitX$                             ' centre X
    DIM fruitY$                             ' centre Y
    DIM fruitSpeed$                         ' pixels per frame
    DIM fruitHalf$                          ' half of the rendered (scaled) size

    ' --- Game state ---
    LET hits$    = 0
    LET missed$  = 0
    LET total$   = 0
    LET bx$      = SCREEN_W# / 2
    LET running$ = TRUE

    FOR i$ = 0 TO NUM_FRUITS# - 1
        fruits$(i$)     = LOADIMAGE(FRUIT_PATH#)
        fruitSpeed$(i$) = (6 + RND(10)) / 5                       ' 1.2 .. 3.0
        fruitHalf$(i$)  = ICON_SIZE# * (fruitSpeed$(i$) / SCALE_DIVISOR#) / 2
        SCALESHAPE fruits$(i$), fruitSpeed$(i$) / SCALE_DIVISOR#  ' faster = bigger
        GOSUB [sub:respawn]
    NEXT

[main]
    MOUSEHIDE
    WHILE running$
        IF INKEY = KEY_ESC# THEN running$ = FALSE
        GOSUB [sub:update]
        GOSUB [sub:draw]
        SLEEP 10
    WEND

    ' --- Clean up ---
    FOR i$ = 0 TO NUM_FRUITS# - 1
        REMOVESHAPE fruits$(i$)
    NEXT
    REMOVESHAPE BUCKET#
    SOUNDSTOPALL
    MOUSESHOW
END

' ------------------------------------------------------------
' Put fruit i$ back above the top edge at a random X.
' Uses the caller's i$ (GOSUB shares scope). Contains no loop
' of its own, so it cannot clobber the caller's loop variable.
' ------------------------------------------------------------
[sub:respawn]
    fruitX$(i$) = RND(SCREEN_W#)
    fruitY$(i$) = -100 - RND(200)
RETURN

[sub:update]
    bx$ = CLAMP(MOUSEX, BUCKET_W# / 2, SCREEN_W# - BUCKET_W# / 2)

    FOR i$ = 0 TO NUM_FRUITS# - 1
        fruitY$(i$) = fruitY$(i$) + fruitSpeed$(i$)

        ' Box-overlap test: centre distance vs. sum of half-sizes
        IF ABS(bx$ - fruitX$(i$)) < BUCKET_W# / 2 + fruitHalf$(i$) AND
           ABS(BUCKET_Y# - fruitY$(i$)) < BUCKET_H# / 2 + fruitHalf$(i$) THEN
            hits$ = hits$ + 1
            SOUNDONCE(COIN#)
            GOSUB [sub:respawn]
        ELSEIF fruitY$(i$) - fruitHalf$(i$) > SCREEN_H# THEN
            missed$ = missed$ + 1
            GOSUB [sub:respawn]
        END IF

        ' LOADIMAGE is top-left anchored: shift by half-size to centre it
        MOVESHAPE fruits$(i$), fruitX$(i$) - fruitHalf$(i$), fruitY$(i$) - fruitHalf$(i$)
    NEXT

    MOVESHAPE BUCKET#, bx$, BUCKET_Y#
    total$ = hits$ + missed$
RETURN

[sub:draw]
    SCREENLOCK ON
    LINE (0, 0)-(SCREEN_W#, SCREEN_H#), COL_SKY#, BF
    FOR i$ = 0 TO NUM_FRUITS# - 1
        DRAWSHAPE fruits$(i$)
    NEXT
    DRAWSHAPE BUCKET#
    DRAWSTRING FSTRING("Caught: {{-hits$-}}   Missed: {{-missed$-}}   Total: {{-total$-}}"), 10, 10, COL_TEXT#
    SCREENLOCK OFF
RETURN

' Output:
' A 640x480 window with sky-blue background. Ten icons fall at
' different speeds (faster ones are drawn larger). A brown bucket
' follows the mouse along the bottom; caught icons play a coin
' sound. The HUD shows e.g. "Caught: 12   Missed: 3   Total: 15".