' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Camera-transform zoom demo: a small landscape is drawn through a world-to-screen zoom around the crosshair, and holding the right mouse button shows a round 2x sniper-scope view in which the aimed spot stays fixed.
' CATEGORY: drawing
' TAGS: camera transform, zoom, mouse, scope mask, crosshair
' MINVERSION: 1.5
' ============================================
' Idea: nothing is "copied and enlarged". The world is described once,
' in world coordinates, and drawn through a camera transform:
'
'     screen = (world - focus) * zoom + focus
'
' With zoom = 1 the world is drawn normally. With zoom = 2 everything
' is drawn twice as big, scaled around the focus point (the crosshair).
' The focus point itself never moves, which is why whatever you were
' aiming at stays under the crosshair when the scope comes up.
' A black mask with a round hole is then drawn over everything.
'
' Controls: hold RIGHT mouse button = scope, ESC = quit

' Scale one world coordinate around the focus point.
DEF FN ToScreen$(world$, focus$, zoom$)
    RETURN (world$ - focus$) * zoom$ + focus$
END DEF

[inits]
    LET SCREEN_W# = 640
    LET SCREEN_H# = 480
    LET SCOPE_ZOOM# = 2.0
    LET SCOPE_R#    = 150       ' scope radius in pixels

    ' Colors computed once, not every frame
    LET C_SKY#    = RGB(120, 170, 230)
    LET C_HILL1#  = RGB(70, 120, 70)
    LET C_HILL2#  = RGB(55, 100, 60)
    LET C_GROUND# = RGB(90, 140, 60)
    LET C_TRUNK#  = RGB(90, 60, 30)
    LET C_CROWN#  = RGB(30, 90, 40)
    LET C_WALL#   = RGB(200, 190, 170)
    LET C_ROOF#   = RGB(140, 50, 40)
    LET C_WINDOW# = RGB(250, 220, 90)
    LET C_POST#   = RGB(110, 80, 50)
    LET C_RED#    = RGB(220, 30, 30)
    LET C_WHITE#  = RGB(255, 255, 255)
    LET C_BLACK#  = RGB(0, 0, 0)
    LET C_TEXT#   = RGB(255, 255, 255)

    ' Camera state
    LET zoom$ = 1
    LET fx$ = 0                 ' focus point (= crosshair)
    LET fy$ = 0
    LET mx$ = 0
    LET my$ = 0

    ' Parameters for the [sub:box] and [sub:disc] helpers (world coords)
    LET wx1$ = 0
    LET wy1$ = 0
    LET wx2$ = 0
    LET wy2$ = 0
    LET wx$ = 0
    LET wy$ = 0
    LET wr$ = 0
    LET col$ = 0

    ' Scratch variables (screen coords)
    LET x1$ = 0
    LET y1$ = 0
    LET x2$ = 0
    LET y2$ = 0
    LET r$ = 0
    LET top$ = 0
    LET bottom$ = 0
    LET w$ = 0
    LET dy$ = 0

    ' Precompute half-width of the scope circle for every pixel row.
    ' Row 0 = top of circle, row 2*R = bottom. Saves a SQR per row per frame.
    DIM halfW$
    FOR row$ = 0 TO SCOPE_R# * 2
        dy$ = row$ - SCOPE_R#
        halfW$(row$) = SQR(SCOPE_R# * SCOPE_R# - dy$ * dy$)
    NEXT row$

    SCREEN 0, SCREEN_W#, SCREEN_H#, "Sniper Scope Demo"
    MOUSEHIDE

[main]
    WHILE INKEY <> KEY_ESC#
        mx$ = MOUSEX
        my$ = MOUSEY

        IF MOUSERIGHT THEN zoom$ = SCOPE_ZOOM# ELSE zoom$ = 1
        fx$ = mx$
        fy$ = my$

        SCREENLOCK ON
        GOSUB [sub:drawWorld]
        IF zoom$ > 1 THEN
            GOSUB [sub:drawScopeMask]
            GOSUB [sub:drawReticle]
        ELSE
            GOSUB [sub:drawCursor]
        END IF
        DRAWSTRING "Hold RIGHT mouse button to aim  |  ESC = quit", 10, 10, C_TEXT#
        SCREENLOCK OFF

        SLEEP 16
    WEND

    MOUSESHOW
END

' --------------------------------------------
' The whole scene, described ONCE in world coordinates.
' The same code draws both the normal view and the zoomed view.
' --------------------------------------------
[sub:drawWorld]
    ' Sky
    wx1$ = 0 : wy1$ = 0 : wx2$ = SCREEN_W# : wy2$ = SCREEN_H# : col$ = C_SKY#
    GOSUB [sub:box]

    ' Distant hills (half hidden by the ground drawn after them)
    wx$ = 160 : wy$ = 360 : wr$ = 140 : col$ = C_HILL1#
    GOSUB [sub:disc]
    wx$ = 480 : wy$ = 390 : wr$ = 170 : col$ = C_HILL2#
    GOSUB [sub:disc]

    ' Ground
    wx1$ = 0 : wy1$ = 300 : wx2$ = SCREEN_W# : wy2$ = SCREEN_H# : col$ = C_GROUND#
    GOSUB [sub:box]

    ' Tree
    wx1$ = 90 : wy1$ = 268 : wx2$ = 96 : wy2$ = 300 : col$ = C_TRUNK#
    GOSUB [sub:box]
    wx$ = 93 : wy$ = 260 : wr$ = 14 : col$ = C_CROWN#
    GOSUB [sub:disc]

    ' House with a lit window
    wx1$ = 380 : wy1$ = 260 : wx2$ = 440 : wy2$ = 300 : col$ = C_WALL#
    GOSUB [sub:box]
    wx1$ = 374 : wy1$ = 250 : wx2$ = 446 : wy2$ = 260 : col$ = C_ROOF#
    GOSUB [sub:box]
    wx1$ = 402 : wy1$ = 270 : wx2$ = 412 : wy2$ = 280 : col$ = C_WINDOW#
    GOSUB [sub:box]

    ' Small target on a post - hard to see without the scope
    wx1$ = 519 : wy1$ = 290 : wx2$ = 521 : wy2$ = 302 : col$ = C_POST#
    GOSUB [sub:box]
    wx$ = 520 : wy$ = 287 : wr$ = 5 : col$ = C_WHITE#
    GOSUB [sub:disc]
    wx$ = 520 : wy$ = 287 : wr$ = 3.5 : col$ = C_RED#
    GOSUB [sub:disc]
    wx$ = 520 : wy$ = 287 : wr$ = 1.5 : col$ = C_WHITE#
    GOSUB [sub:disc]
RETURN

' Filled box: world corners (wx1$,wy1$)-(wx2$,wy2$), color col$
[sub:box]
    x1$ = FN ToScreen$(wx1$, fx$, zoom$)
    y1$ = FN ToScreen$(wy1$, fy$, zoom$)
    x2$ = FN ToScreen$(wx2$, fx$, zoom$)
    y2$ = FN ToScreen$(wy2$, fy$, zoom$)
    LINE (x1$, y1$)-(x2$, y2$), col$, BF
RETURN

' Filled circle: world center (wx$,wy$), world radius wr$, color col$
[sub:disc]
    x1$ = FN ToScreen$(wx$, fx$, zoom$)
    y1$ = FN ToScreen$(wy$, fy$, zoom$)
    r$ = wr$ * zoom$            ' sizes scale too, positions scale around focus
    CIRCLE (x1$, y1$), r$, col$, 1
RETURN

' --------------------------------------------
' Black everywhere except a round hole at the crosshair.
' Above and below the circle: two big boxes.
' Inside the circle's bounding rows: per row, black left and right
' of the circle edge.
' --------------------------------------------
[sub:drawScopeMask]
    top$    = my$ - SCOPE_R#
    bottom$ = my$ + SCOPE_R#

    IF top$ > 0 THEN LINE (0, 0)-(SCREEN_W#, top$), C_BLACK#, BF
    IF bottom$ < SCREEN_H# THEN LINE (0, bottom$ + 1)-(SCREEN_W#, SCREEN_H#), C_BLACK#, BF

    FOR row$ = 0 TO SCOPE_R# * 2
        y1$ = top$ + row$
        IF BETWEEN(y1$, 0, SCREEN_H#) THEN
            w$ = halfW$(row$)
            IF mx$ - w$ > 0 THEN LINE (0, y1$)-(mx$ - w$, y1$), C_BLACK#
            IF mx$ + w$ < SCREEN_W# THEN LINE (mx$ + w$, y1$)-(SCREEN_W#, y1$), C_BLACK#
        END IF
    NEXT row$
RETURN

' Scope reticle: thick rim + crosshair with an open center
[sub:drawReticle]
    FOR ring$ = 0 TO 3
        CIRCLE (mx$, my$), SCOPE_R# - ring$, C_BLACK#
    NEXT ring$
    LINE (mx$ - SCOPE_R#, my$)-(mx$ - 12, my$), C_BLACK#
    LINE (mx$ + 12, my$)-(mx$ + SCOPE_R#, my$), C_BLACK#
    LINE (mx$, my$ - SCOPE_R#)-(mx$, my$ - 12), C_BLACK#
    LINE (mx$, my$ + 12)-(mx$, my$ + SCOPE_R#), C_BLACK#
    PSET (mx$, my$), C_RED#
RETURN

' Small aiming cursor when not scoped
[sub:drawCursor]
    CIRCLE (mx$, my$), 8, C_BLACK#
    LINE (mx$ - 12, my$)-(mx$ - 4, my$), C_BLACK#
    LINE (mx$ + 4, my$)-(mx$ + 12, my$), C_BLACK#
    LINE (mx$, my$ - 12)-(mx$, my$ - 4), C_BLACK#
    LINE (mx$, my$ + 4)-(mx$, my$ + 12), C_BLACK#
RETURN

' Behaviour:
' A small landscape with a tree, a house and a tiny target.
' Holding the right mouse button turns the screen black except for a
' round scope view, in which everything is twice as large and the spot
' under the crosshair stays exactly where it was.
