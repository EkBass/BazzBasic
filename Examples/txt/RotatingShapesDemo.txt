' ==========================================
' Rotating Shapes — BazzBasic
' Three shapes, each with a different rotation
' speed and direction.
' Press ESC to exit.
' https://github.com/EkBass/BazzBasic
' ==========================================

[inits]
    LET SCREEN_W#  = 640
    LET SCREEN_H#  = 480
    LET SHAPE_SZ#  = 60
    LET RED#       = RGB(255, 0, 0)
    LET GREEN#     = RGB(0, 255, 0)
    LET BLUE#      = RGB(0, 0, 255)

    LET angle$   = 0
    LET running$ = TRUE

[init:gfx]
    SCREEN 0, SCREEN_W#, SCREEN_H#, "Rotating Shapes"

    LET SQUARE#   = LOADSHAPE("RECTANGLE", SHAPE_SZ#, SHAPE_SZ#, RED#)
    LET CIRCLE#   = LOADSHAPE("CIRCLE",    SHAPE_SZ#, SHAPE_SZ#, GREEN#)
    LET TRIANGLE# = LOADSHAPE("TRIANGLE",  SHAPE_SZ#, SHAPE_SZ#, BLUE#)

    MOVESHAPE SQUARE#,   160, 240
    MOVESHAPE CIRCLE#,   320, 240
    MOVESHAPE TRIANGLE#, 480, 240

[main]
    WHILE running$
        ' Input and logic outside SCREENLOCK
        IF INKEY = KEY_ESC# THEN running$ = FALSE

        angle$ = angle$ + 2
        IF angle$ >= 360 THEN angle$ = 0

        ROTATESHAPE SQUARE#,   angle$
        ROTATESHAPE CIRCLE#,   angle$ * 0.5
        ROTATESHAPE TRIANGLE#, angle$ * -1

        SCREENLOCK ON
            LINE (0, 0)-(SCREEN_W#, SCREEN_H#), 0, BF
            DRAWSHAPE SQUARE#
            DRAWSHAPE CIRCLE#
            DRAWSHAPE TRIANGLE#
            COLOR 15, 0
            LOCATE 1, 1
            PRINT "Red: x1   Green: x0.5   Blue: x-1   (ESC to exit)"
        SCREENLOCK OFF

        SLEEP 16
    WEND

    REMOVESHAPE SQUARE#
    REMOVESHAPE CIRCLE#
    REMOVESHAPE TRIANGLE#
END
