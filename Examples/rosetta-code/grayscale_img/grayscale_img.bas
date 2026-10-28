' ============================================
' https://rosettacode.org/wiki/Grayscale_image
' https://ekbass.github.io/BazzBasic
' Translation of: #BASIC256
' ============================================

' BB needs fixing. POINT in large loops makes computer freeze.
' POINT in a large loop freezes the whole system

END
[inits]
LET wid# = 293
LET hgt# = 341
SCREEN 0, wid#, hgt#
LET raster# = LOADIMAGE ("mavbeacon.png")
DRAWSHAPE raster#
    FOR x$ = 0 TO wid# - 1
        FOR y$ = 0 TO hgt# - 1
            LET pt$ = POINT(x$, y$)
            LET blu$ = pt$ % 256
            LET pt$ = INT(pt$ / 256)
            LET grn$ = pt$ % 256
            LET pt$ = INT(pt$ / 256)
            LET red$ = pt$ % 256
            LET lum$ = INT(0.2126 * red$ + 0.7152 * grn$ + 0.0722 * blu$ + 0.5)
            PSET (x$, y$), RGB(lum$, lum$, lum$)
        NEXT y$
    NEXT x$
SLEEP 2500
END
