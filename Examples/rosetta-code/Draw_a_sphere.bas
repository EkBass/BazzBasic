' ============================================
' ROSETTA: https://rosettacode.org/wiki/Draw_a_sphere
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Draws a shaded sphere of radius 100 pixel by pixel in a 640x480 window, using a precomputed table of teal shades, and waits for a key press.
' CATEGORY: drawing
' TAGS: sphere, shading, pset, 3d, lookup table
' MINVERSION: 1.5
' ============================================

[inits]
    LET W# = 640
    LET H# = 480
    LET r$  = 100
    LET r2$ = r$ * r$
    LET x0$ = W# / 2
    LET y0$ = H# / 2
    LET x$, y$, c$, d2$, yy$, ybase$, xrange$, i$
    LET wkv$

    SCREEN 0, W#, H#, "Sphere"

    ' precompute RGB lookup: col$(c) = RGB(0, c, c) for c = 0..255
    DIM col$
    FOR i$ = 0 TO 255
        col$(i$) = RGB(0, i$, i$)
    NEXT

[main]
    SCREENLOCK ON
        FOR y$ = -r$ TO r$
            yy$     = y$ * y$ 
            ybase$  = 130 - y$ / 2
            xrange$ = INT(SQR(r2$ - yy$))
            FOR x$ = -xrange$ TO xrange$
                d2$ = x$ * x$ + yy$
                c$  = CLAMP(INT(SQR(r2$ - d2$) - x$ / 2 + ybase$), 0, 255)
                PSET(x$ + x0$, y$ + y0$), col$(c$)
            NEXT
        NEXT
    SCREENLOCK OFF

    wkv$ = WAITKEY()
END