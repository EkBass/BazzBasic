' ============================================================
' Fruit Catcher - BazzBasic port of SmallBasic minigame
' https://smallbasic.com/smallbasic.com/program/?nts150
' ============================================================
[inits]
    LET NUM_FRUITS# = 10
    LET SCREEN_W#   = 640
    LET SCREEN_H#   = 480
    LET BUCKET_W#   = 80
    LET BUCKET_H#   = 20
    LET BUCKET_Y#   = 450
    LET ICON_SIZE#  = 64                          ' <<< B-icon.png native size in pixels
    LET FRUIT_PATH# = "assets\\B-icon.png"
    LET COIN_PATH#  = "assets\\coin.mp3"
    LET COL_SKY#    = RGB(135, 206, 235)
    LET COL_BUCKET# = RGB(160, 100, 40)

    SCREEN 0, SCREEN_W#, SCREEN_H#, "Fruit Catcher"

    DIM fruits$
    DIM fruitX$
    DIM fruitY$
    DIM fruitSpeed$
    DIM fruitHalf$                                ' <<< precomputed half-size per fruit

    FOR i$ = 0 TO NUM_FRUITS# - 1
        fruits$(i$)    = LOADIMAGE(FRUIT_PATH#)
        fruitX$(i$)    = RND(SCREEN_W#)
        fruitY$(i$)    = -100 - RND(200)
        fruitSpeed$(i$) = (6 + RND(10)) / 5
        fruitHalf$(i$) = (ICON_SIZE# * fruitSpeed$(i$) / 3) / 2   ' <<< rendered half-size
        SCALESHAPE fruits$(i$), fruitSpeed$(i$) / 3
        MOVESHAPE fruits$(i$), fruitX$(i$) - fruitHalf$(i$), fruitY$(i$) - fruitHalf$(i$)
    NEXT

    LET BUCKET# = LOADSHAPE("RECTANGLE", BUCKET_W#, BUCKET_H#, COL_BUCKET#)
    LET hits$    = 0
    LET missed$  = 0
    LET running$ = TRUE
    LET bx$      = SCREEN_W# / 2
    LET by$      = BUCKET_Y#
    LET coin$    = LOADSOUND(COIN_PATH#)

[main]
    WHILE running$
        IF INKEY = KEY_ESC# THEN running$ = FALSE
        GOSUB [sub:update]
        GOSUB [sub:draw]
        SLEEP 10
    WEND
    FOR i$ = 0 TO NUM_FRUITS# - 1
        REMOVESHAPE fruits$(i$)
    NEXT
    REMOVESHAPE BUCKET#
    SOUNDSTOPALL
END

[sub:update]
    bx$ = MOUSEX
    FOR i$ = 0 TO NUM_FRUITS# - 1
        fruitY$(i$) = fruitY$(i$) + fruitSpeed$(i$)
        MOVESHAPE fruits$(i$), fruitX$(i$) - fruitHalf$(i$), fruitY$(i$) - fruitHalf$(i$)
        IF ABS(bx$ - fruitX$(i$)) < 80 AND ABS(by$ - fruitY$(i$)) < 20 THEN
            hits$ = hits$ + 1
            fruitX$(i$) = RND(SCREEN_W#)
            fruitY$(i$) = -100 - RND(200)
            SOUNDONCE(coin$)
        ELSEIF fruitY$(i$) > SCREEN_H# THEN
            missed$ = missed$ + 1
            fruitX$(i$) = RND(SCREEN_W#)
            fruitY$(i$) = -100 - RND(200)
        END IF
    NEXT
    MOVESHAPE BUCKET#, bx$, by$
RETURN

[sub:draw]
    SCREENLOCK ON
    LINE (0, 0)-(SCREEN_W#, SCREEN_H#), COL_SKY#, BF
    FOR i$ = 0 TO NUM_FRUITS# - 1
        DRAWSHAPE fruits$(i$)
    NEXT
    DRAWSHAPE BUCKET#
    COLOR 14, 0
    LOCATE 1, 1
    PRINT "Caught: " + hits$ + "   Missed: " + missed$ + "   Total: " + (hits$ + missed$)
    SCREENLOCK OFF
RETURN