' Animated Lines - Ported from QB64 to BazzBasic
' Original by Eric Schraf: https://github.com/oonap0oo/QB64-projects/blob/main/linesani.bas
'
' ATAN2 built from ATAN, seeded RNG replaced with pre-generated arrays,
' Window coords mapping manually, HSB simplyfied for hue 0-60 range.

' ---- FUNCTIONS ----

DEF FN Atan2$(y$, x$)
    IF x$ > 0 THEN RETURN ATAN(y$ / x$)
    IF x$ < 0 AND y$ >= 0 THEN RETURN ATAN(y$ / x$) + PI#
    IF x$ < 0 AND y$ < 0 THEN RETURN ATAN(y$ / x$) - PI#
    IF x$ = 0 AND y$ > 0 THEN RETURN HPI#
    IF x$ = 0 AND y$ < 0 THEN RETURN 0 - HPI#
    RETURN 0
END DEF

' ---- INIT ----
[inits]
    LET SW# = 900
    LET SH# = 600
    LET NLINES# = 200
    LET NPOINTS# = 30
    LET DS# = 0.02
    LET DH# = 0.015
    LET SIXPI# = 6 * PI#
    LET BLACK# = RGB(0, 0, 0)
    LET HEADING_MIN# = 4 * PI# / 3
    LET HEADING_MAX# = 10 * PI# / 3

    ' Coordinate mapping: world [-1.5, 1.5] x [-1, 1] -> screen
    ' sx = (wx + 1.5) * XSCALE#
    ' sy = (1 - wy) * YSCALE#
    LET XSCALE# = SW# / 3
    LET YSCALE# = SH# / 2

    SCREEN 0, SW#, SH#, "Animated Lines"

    ' Pre-generate random starting points
    ' (replaces QB64's "Randomize Using 1" trick)
    DIM rx$
    DIM ry$
    FOR i$ = 0 TO NLINES#
        rx$(i$) = RND(2000) / 1000 - 1
        ry$(i$) = RND(2000) / 1000 - 1
    NEXT

    ' Pre-declare all loop variables in inits for performance
    LET heading$ = HEADING_MIN#
    LET x$ = 0
    LET y$ = 0
    LET angle$ = 0
    LET dist$ = 0
    LET px$ = 0
    LET py$ = 0
    LET nx$ = 0
    LET ny$ = 0
    LET hue$ = 0
    LET g$ = 0

' ---- MAIN LOOP ----
[main]
    WHILE INKEY <> KEY_ESC#
        SCREENLOCK ON
        LINE (0, 0)-(SW#, SH#), BLACK#, BF

        FOR i$ = 0 TO NLINES#
            x$ = rx$(i$)
            y$ = ry$(i$)

            FOR p$ = 0 TO NPOINTS#
                ' Save current position for line start
                px$ = (x$ + 1.5) * XSCALE#
                py$ = (1 - y$) * YSCALE#

                ' Compute angle: atan2(y,x) + heading + sin(6*PI*hypot)/4
                dist$ = SQR(x$ * x$ + y$ * y$)
                angle$ = FN Atan2$(y$, x$) + heading$ + SIN(SIXPI# * dist$) / 4

                ' Step forward
                x$ = x$ + DS# * COS(angle$)
                y$ = y$ + DS# * SIN(angle$)

                ' New position in screen coords
                nx$ = (x$ + 1.5) * XSCALE#
                ny$ = (1 - y$) * YSCALE#

                ' Color: HSB with hue 0-60, S=100, B=100 -> red to yellow
                hue$ = 30 + 30 * SIN(p$ / 2)
                g$ = INT(255 * hue$ / 60)
                LINE (px$, py$)-(nx$, ny$), RGB(255, g$, 0)
            NEXT
        NEXT

        SCREENLOCK OFF
        SLEEP 16

        heading$ += DH#
        IF heading$ > HEADING_MAX# THEN heading$ = HEADING_MIN#
    WEND
END
