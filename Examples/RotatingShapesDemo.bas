' BazzBasic version 1.3b
' https://ekbass.github.io/BazzBasic/

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
    LET WHITE#     = RGB(255, 255, 255)
    LET angle$     = 0
    LET running$   = TRUE

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
        ROTATESHAPE SQUARE#,   angle$            ' full speed forward
        ROTATESHAPE CIRCLE#,   angle$ * 0.5      ' half speed forward
        ROTATESHAPE TRIANGLE#, angle$ * -1       ' full speed, reverse direction
        SCREENLOCK ON
            LINE (0, 0)-(SCREEN_W#, SCREEN_H#), 0, BF
            DRAWSHAPE SQUARE#
            DRAWSHAPE CIRCLE#
            DRAWSHAPE TRIANGLE#
            DRAWSTRING "Red: x1   Green: x0.5   Blue: x-1   (ESC to exit)", 4, 4, WHITE#
        SCREENLOCK OFF
        SLEEP 16
    WEND
    REMOVESHAPE SQUARE#
    REMOVESHAPE CIRCLE#
    REMOVESHAPE TRIANGLE#
END