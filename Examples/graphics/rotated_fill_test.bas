' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Visual test that filled LOADSHAPE shapes stay solid at every angle: a rectangle and a triangle rotate continuously next to a static circle while the current angle is shown.
' CATEGORY: drawing
' TAGS: loadshape, rotateshape, filled shapes, test
' MINVERSION: 1.5
' ============================================

[inits]
    LET SCREEN_W# = 640
    LET SCREEN_H# = 480
    LET BG_COLOR#   = RGB(0, 0, 0)
    LET TEXT_COLOR# = RGB(255, 255, 255)
    LET angle$ = 0

[init:screen]
    SCREEN 0, SCREEN_W#, SCREEN_H#, "Rotated fill test"
    LET RECT# = LOADSHAPE("RECTANGLE", 120, 60, RGB(40, 90, 230))
    LET TRI#  = LOADSHAPE("TRIANGLE", 100, 100, RGB(230, 60, 40))
    LET CIRC# = LOADSHAPE("CIRCLE", 100, 100, RGB(40, 200, 80))
    MOVESHAPE RECT#, 140, 240
    MOVESHAPE TRI#, 320, 240
    MOVESHAPE CIRC#, 500, 240

[main]
    WHILE INKEY <> KEY_ESC#
        angle$ += 1
        IF angle$ >= 360 THEN angle$ -= 360
        ROTATESHAPE RECT#, angle$
        ROTATESHAPE TRI#, angle$

        SCREENLOCK ON
        LINE (0, 0)-(SCREEN_W#, SCREEN_H#), BG_COLOR#, BF
        DRAWSHAPE RECT#
        DRAWSHAPE TRI#
        DRAWSHAPE CIRC#
        DRAWSTRING "Angle: " + angle$, 10, 10, TEXT_COLOR#
        SCREENLOCK OFF
    WEND

    REMOVESHAPE RECT#
    REMOVESHAPE TRI#
    REMOVESHAPE CIRC#
END

' Expected: all three shapes solid at every angle.
