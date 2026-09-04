' BazzBasic version 1.3b
' https://ekbass.github.io/BazzBasic/
' ============================================
' Mandelbrot Fractal
' BazzBasic: https://github.com/EkBass/BazzBasic
' Based on: github.com/oonap0oo/QB64-projects
' z_new = z^2 + c  (complex iteration)
' ============================================

[inits]
    LET XMAX# = 640
    LET YMAX# = 480

    ' Viewing window in the complex plane.
    ' These constants define the "zoom level".
    ' Change them to explore different regions.
    LET XL# = -2.1     ' real axis lower bound
    LET XU# =  1.0     ' real axis upper bound
    LET YL# = -1.25    ' imaginary axis lower bound
    LET YU# =  1.25    ' imaginary axis upper bound

    LET MAX_ITER# = 256

    SCREEN 0, XMAX#, YMAX#, "Mandelbrot Fractal"

    ' Disable VSync so the render loop is not throttled to 60 fps.
    ' Without this each SCREENLOCK OFF would sleep ~16ms, multiplying
    ' render time by roughly 30x.
    VSYNC(FALSE)

    ' Working variables — all declared here, not inside loops,
    ' to avoid repeated allocation overhead.
    LET xspan$   = XU# - XL#
    LET yspan$   = YU# - YL#
    LET cr$      = 0.0    ' real part of c (changes with x)
    LET ci$      = 0.0    ' imaginary part of c (changes with y)
    LET zr$      = 0.0    ' real part of z
    LET zi$      = 0.0    ' imaginary part of z
    LET zr_new$  = 0.0    ' temp for new zr (zi is updated in-place)
    LET zrsq$    = 0.0    ' zr^2 — cached to avoid recomputing
    LET zisq$    = 0.0    ' zi^2 — cached to avoid recomputing
    LET counter$ = 0
    LET r$       = 0
    LET g$       = 0
    LET b$       = 0

[main]
    FOR x$ = 0 TO XMAX# - 1

        ' Map pixel x to real component of c
        cr$ = x$ / (XMAX# - 2) * xspan$ + XL#

        ' Lock the buffer for this entire column.
        ' This gives a visible left-to-right render sweep
        ' while keeping PSET calls off-screen until the column is done.
        SCREENLOCK ON

        FOR y$ = 0 TO YMAX# - 1

            ' Map pixel y to imaginary component of c
            ci$ = y$ / (YMAX# - 2) * yspan$ + YL#

            ' Reset z to origin for each pixel
            zr$      = 0.0
            zi$      = 0.0
            zrsq$    = 0.0
            zisq$    = 0.0
            counter$ = 0

            ' Iterate z = z^2 + c until |z|^2 >= 4 or max iterations reached.
            ' Using inline multiplication (zr$*zr$) instead of POW()
            ' to minimise function-call overhead in this hot inner loop.
            WHILE counter$ < MAX_ITER# AND (zrsq$ + zisq$) < 4.0
                zrsq$   = zr$ * zr$
                zisq$   = zi$ * zi$
                zr_new$ = zrsq$ - zisq$ + cr$
                zi$     = 2.0 * zr$ * zi$ + ci$
                zr$     = zr_new$
                counter$ += 1
            WEND

            ' Derive RGB from the iteration count.
            ' Different moduli produce cycling colour bands across the set boundary.
            r$ = MOD(counter$, 64)  * 4
            g$ = MOD(counter$, 32)  * 8
            b$ = MOD(counter$, 16)  * 16

            PSET (x$, y$), RGB(r$, g$, b$)

        NEXT ' y$

        SCREENLOCK OFF   ' Present this column to the screen

    NEXT ' x$

    ' Render is complete. Wait for any key before exiting.
    LET wks$ = WAITKEY()
END

' Output:
' A 640×480 window rendering the Mandelbrot set column by column,
' visible as a left-to-right sweep. Colour bands are derived from
' iteration counts using modulo cycling (same formula as the original).
' Any key closes the window after the render completes.