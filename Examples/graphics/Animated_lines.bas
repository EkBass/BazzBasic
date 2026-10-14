' ============================================
' Animated Lines - Ported from QB64 to BazzBasic
' Original by Eric Schraf:
'   https://github.com/oonap0oo/QB64-projects/blob/main/linesani.bas
' BazzBasic:
'   https://github.com/EkBass/BazzBasic
'
' ============================================

[inits]
    LET SW#          = 900
    LET SH#          = 600
    LET NLINES#      = 200
    LET NPOINTS#     = 30
    LET DS#          = 0.02
    LET DH#          = 0.015
    LET SIXPI#       = 6 * PI#
    LET BLACK#       = RGB(0, 0, 0)
    LET HEADING_MIN# = 4 * PI# / 3
    LET HEADING_MAX# = 10 * PI# / 3

    ' World [-1.5, 1.5] x [-1, 1] -> screen
    '   sx = (wx + 1.5) * XSCALE#
    '   sy = (1 - wy)   * YSCALE#
    LET XSCALE# = SW# / 3
    LET YSCALE# = SH# / 2

    SCREEN 0, SW#, SH#, "Animated Lines"

    ' Pre-generate starting points so every line keeps the same
    ' origin from frame to frame. Continuous range [-1.0, 1.0).
    DIM rx$
    DIM ry$
    FOR i$ = 0 TO NLINES#
        rx$(i$) = RND(0) * 2 - 1
        ry$(i$) = RND(0) * 2 - 1
    NEXT

    ' All hot-loop locals declared up here to avoid the
    ' first-use existence check that LET pays inside loops.
    LET heading$ = HEADING_MIN#
    LET x$       = 0
    LET y$       = 0
    LET angle$   = 0
    LET dist$    = 0
    LET px$      = 0
    LET py$      = 0
    LET nx$      = 0
    LET ny$      = 0
    LET hue$     = 0
    LET g$       = 0

[main]
    WHILE INKEY <> KEY_ESC#
        SCREENLOCK ON
        LINE (0, 0)-(SW#, SH#), BLACK#, BF

        FOR i$ = 0 TO NLINES#
            x$ = rx$(i$)
            y$ = ry$(i$)

            FOR p$ = 0 TO NPOINTS#
                ' Current position is the start of this segment.
                px$ = (x$ + 1.5) * XSCALE#
                py$ = (1 - y$)   * YSCALE#

                ' Quadrant-correct heading, plus a radial wave term.
                dist$  = SQR(x$ * x$ + y$ * y$)
                angle$ = ATAN2(y$, x$) + heading$ + SIN(SIXPI# * dist$) / 4

                ' Step forward in the (x, y) plane.
                x$ = x$ + DS# * COS(angle$)
                y$ = y$ + DS# * SIN(angle$)

                ' Segment endpoint in screen coordinates.
                nx$ = (x$ + 1.5) * XSCALE#
                ny$ = (1 - y$)   * YSCALE#

                ' Hue 0..60 mapped onto a red -> yellow ramp.
                hue$ = 30 + 30 * SIN(p$ / 2)
                g$   = INT(255 * hue$ / 60)
                LINE (px$, py$)-(nx$, ny$), RGB(255, g$, 0)
            NEXT
        NEXT

        SCREENLOCK OFF
        SLEEP 16

        heading$ += DH#
        IF heading$ > HEADING_MAX# THEN heading$ = HEADING_MIN#
    WEND
END