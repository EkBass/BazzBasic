' ============================================
' https://rosettacode.org/wiki/Archimedean_spiral
' BazzBasic: https://github.com/EkBass/BazzBasic
' Task: draw an Archimedean spiral, r = a + b * theta.
' ============================================

[inits]
    LET SCREEN_W# = 640
    LET SCREEN_H# = 480
    LET CX# = SCREEN_W# / 2         ' world origin at screen centre
    LET CY# = SCREEN_H# / 2
    LET SCALE# = 120                ' pixels per world unit (same view as QBasic's WINDOW)

    LET A# = 0.2                    ' starting radius
    LET B# = 0.05                   ' growth per radian
    LET STEPS# = 400
    LET H# = PI# / 40               ' angle increment

    LET SPIRAL_COL# = RGB(255, 255, 0)
    LET TEXT_COL# = RGB(160, 160, 160)

    LET t$ = 0
    LET r$ = 0
    LET px$ = 0
    LET py$ = 0
    LET prevX$ = 0
    LET prevY$ = 0
    LET wkv$ = 0

    SCREEN 0, SCREEN_W#, SCREEN_H#, "Archimedean spiral"

[main]
    SCREENLOCK ON
    LINE (0, 0)-(SCREEN_W#, SCREEN_H#), 0, BF

    ' Start at theta = 0, where r = a
    prevX$ = CX# + A# * SCALE#
    prevY$ = CY#

    FOR i$ = 1 TO STEPS#
        t$ = i$ * H#
        r$ = A# + B# * t$
        px$ = CX# + r$ * COS(t$) * SCALE#
        py$ = CY# - r$ * SIN(t$) * SCALE#     ' screen y grows downward
        LINE (prevX$, prevY$)-(px$, py$), SPIRAL_COL#
        prevX$ = px$
        prevY$ = py$
    NEXT

    DRAWSTRING "Press any key to exit", 10, SCREEN_H# - 26, TEXT_COL#
    SCREENLOCK OFF

    wkv$ = WAITKEY()
END

' Output:
' A yellow spiral of five turns drawn outward from the centre
' of a 640x480 window, counter-clockwise.