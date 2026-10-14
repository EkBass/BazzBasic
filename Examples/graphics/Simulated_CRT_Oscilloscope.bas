' =============================================================
' Arneodo Attractor — Simulated CRT Oscilloscope
' QB64 original by K Moerman 2026, ported to BazzBasic
' https://ekbass.github.io/BazzBasic/
'
' The attractor is governed by three coupled ODEs:
'   dx/dt = y
'   dy/dt = z
'   dz/dt = a*x - c*x^3 - b*y - z
'
' Solved with Euler integration. Each frame, new points are
' pushed into a circular ring buffer. The buffer is then
' rendered oldest-to-newest in eight brightness tiers to
' simulate phosphor persistence without alpha blending.
'
' =============================================================

[inits]
    ' ----- Attractor parameters -----
    LET A_PARAM# = 5.5
    LET B_PARAM# = 3.5
    LET C_PARAM# = 1.0
    LET DT#      = 0.005  ' Euler time step

    ' ----- Screen layout -----
    LET SW#  = 750         ' Window width  in pixels
    LET SH#  = 600         ' Window height in pixels
    LET BRD# = 30          ' Border / bezel width in pixels

    ' ----- World-to-screen coordinate mapping -----
    ' QB64 used Window(-XMAX,-ZMAX)-(XMAX,ZMAX) for auto-scaling.
    ' Here we compute the scale factors manually so that the
    ' world range [-XMAX..+XMAX] fills the drawable area
    ' horizontally, and [-ZMAX..+ZMAX] fills it vertically.
    LET XMAX# = 4.5
    LET ZMAX# = 14.0
    LET SCALE_X# = (SW# - 2 * BRD#) / (2 * XMAX#)   ' pixels per world unit, X
    LET SCALE_Z# = (SH# - 2 * BRD#) / (2 * ZMAX#)   ' pixels per world unit, Z
    LET CX# = SW# / 2     ' screen centre X
    LET CZ# = SH# / 2     ' screen centre Z (vertical)

    ' ----- Phosphor persistence ring buffer -----
    ' QB64 achieved persistence by blending with a semi-transparent
    ' black overlay each frame (_RGBA32 with low alpha).
    ' BazzBasic has no per-pixel alpha blending, so we store the
    ' last TRAIL_LEN# screen positions in a circular buffer and
    ' render them in eight brightness tiers on every frame.
    LET TRAIL_LEN#       = 2000   ' how many trail points to keep
    LET STEPS_PER_FRAME# = 150    ' Euler steps computed each frame
    LET SEG_COUNT#       = 8      ' number of brightness tiers
    LET SEG_LEN#         = 250    ' TRAIL_LEN# / SEG_COUNT# = 2000/8

    ' ----- Pre-computed colors -----
    LET COL_BG#    = RGB(0, 0, 0)
    LET COL_GRID#  = RGB(55, 55, 55)
    LET COL_LABEL# = RGB(80, 80, 80)

    ' ----- Mutable state -----
    LET x$     = 1.0        ' current attractor X
    LET y$     = 1.0        ' current attractor Y (drives Z via dy/dt = z)
    LET z$     = 0.0        ' current attractor Z (plotted on screen Y axis)
    LET xNew$  = 0
    LET yNew$  = 0
    LET zNew$  = 0

    LET head$     = 0       ' write-pointer into the ring buffer
    LET frameNum$ = 0       ' counts frames for the periodic IC reset
    LET running$  = TRUE

    ' Variables used inside the draw / grid subroutines.
    ' Declared here because all subroutines share the same scope.
    LET bright$ = 0
    LET col$    = 0
    LET tIdx$   = 0
    LET tx$     = 0
    LET ty$     = 0
    LET gx$     = 0
    LET gy$     = 0

    ' ----- Ring buffer arrays -----
    DIM trailX$   ' screen X coordinates of recent trajectory points
    DIM trailZ$   ' screen Y coordinates (mapped from world Z)

    SCREEN 0, SW#, SH#, "Arneodo Attractor — CRT Oscilloscope"

    ' Pre-warm: run the simulation for TRAIL_LEN# steps before the
    ' first frame so the buffer is fully populated and the shape is
    ' visible immediately rather than building up from empty.
    FOR i$ = 0 TO TRAIL_LEN# - 1
        xNew$ = x$ + DT# * y$
        yNew$ = y$ + DT# * z$
        zNew$ = z$ + DT# * (A_PARAM# * x$ - C_PARAM# * x$ * x$ * x$ - B_PARAM# * y$ - z$)
        x$ = xNew$
        y$ = yNew$
        z$ = zNew$
        trailX$(i$) = CINT(CX# + x$ * SCALE_X#)
        trailZ$(i$) = CINT(CZ# - z$ * SCALE_Z#)   ' Z axis inverted: up = positive
    NEXT

[main]
    WHILE running$
        IF INKEY = KEY_ESC# THEN running$ = FALSE

        ' Replaces QB64's On Timer callback.
        ' Reset to initial conditions every ~10 seconds (600 frames at 60 fps)
        ' to prevent any long-term numerical drift in the Euler integrator.
        frameNum$ += 1
        IF frameNum$ >= 600 THEN
            x$ = 1.0
            y$ = 1.0
            z$ = 0.0
            frameNum$ = 0
        END IF

        ' ----- Euler integration -----
        ' Advance the attractor by STEPS_PER_FRAME# time steps
        ' and record each screen-mapped position into the ring buffer.
        FOR i$ = 1 TO STEPS_PER_FRAME#
            xNew$ = x$ + DT# * y$
            yNew$ = y$ + DT# * z$
            zNew$ = z$ + DT# * (A_PARAM# * x$ - C_PARAM# * x$ * x$ * x$ - B_PARAM# * y$ - z$)
            x$ = xNew$
            y$ = yNew$
            z$ = zNew$
            trailX$(head$) = CINT(CX# + x$ * SCALE_X#)
            trailZ$(head$) = CINT(CZ# - z$ * SCALE_Z#)
            head$ = MOD(head$ + 1, TRAIL_LEN#)
        NEXT

        GOSUB [sub:draw]
        SLEEP 16
    WEND
END

' --------------------------------------------------------------
' [sub:draw]  Render one complete frame
' --------------------------------------------------------------
[sub:draw]
    SCREENLOCK ON

    ' Clear to black — faster than CLS
    LINE (0, 0)-(SW#, SH#), COL_BG#, BF

    ' Draw oscilloscope grid below the trace
    GOSUB [sub:grid]

    ' Render the ring buffer oldest-first, newest-last.
    ' head$ points at the oldest entry (next write position),
    ' so iterating TRAIL_LEN# steps from head$ covers the full
    ' history in chronological order: dim → bright.
    '
    ' Eight tiers of SEG_LEN# points each:
    '   seg=1 (oldest) → RGB(0, 30, 0)   barely visible
    '   seg=8 (newest) → RGB(0, 240, 0)  bright phosphor green
    tIdx$ = head$
    FOR seg$ = 1 TO SEG_COUNT#
        bright$ = seg$ * 30
        col$ = RGB(0, bright$, 0)
        FOR j$ = 1 TO SEG_LEN#
            PSET (trailX$(tIdx$), trailZ$(tIdx$)), col$
            tIdx$ = MOD(tIdx$ + 1, TRAIL_LEN#)
        NEXT
    NEXT

    SCREENLOCK OFF
RETURN

' --------------------------------------------------------------
' [sub:grid]  Draw oscilloscope bezel, grid lines, labels
' Matches the overlay image that QB64 generated once at startup.
' Here it is redrawn every frame since we clear the screen each
' frame — the cost is acceptable given how few LINE calls it is.
' --------------------------------------------------------------
[sub:grid]
    ' Outer border — drawn twice for a slightly thicker line
    LINE (BRD#, BRD#)-(SW#-BRD#, SH#-BRD#), COL_GRID#, B
    LINE (BRD#+1, BRD#+1)-(SW#-BRD#-1, SH#-BRD#-1), COL_GRID#, B

    ' Centre cross-hair axes
    LINE (BRD#, SH#/2)-(SW#-BRD#, SH#/2), COL_GRID#
    LINE (SW#/2, BRD#)-(SW#/2, SH#-BRD#), COL_GRID#

    ' Minor tick marks along the horizontal centre line (50 ticks)
    FOR i$ = 1 TO 49
        tx$ = CINT(i$ / 50 * (SW# - 2 * BRD#) + BRD#)
        LINE (tx$, SH#/2 - 8)-(tx$, SH#/2 + 8), COL_GRID#
    NEXT

    ' Minor tick marks along the vertical centre line (40 ticks)
    FOR i$ = 1 TO 39
        ty$ = CINT(i$ / 40 * (SH# - 2 * BRD#) + BRD#)
        LINE (SW#/2 - 8, ty$)-(SW#/2 + 8, ty$), COL_GRID#
    NEXT

    ' Major vertical grid lines (9 lines = 10 equal divisions)
    FOR i$ = 1 TO 9
        gx$ = CINT(i$ / 10 * (SW# - 2 * BRD#) + BRD#)
        LINE (gx$, BRD#)-(gx$, SH#-BRD#), COL_GRID#
    NEXT

    ' Major horizontal grid lines (7 lines = 8 equal divisions)
    FOR i$ = 1 TO 7
        gy$ = CINT(i$ / 8 * (SH# - 2 * BRD#) + BRD#)
        LINE (BRD#, gy$)-(SW#-BRD#, gy$), COL_GRID#
    NEXT

    ' Channel labels — SDL2_ttf.dll required for DRAWSTRING
    DRAWSTRING "Arneodo Attractor  XZ", BRD#+2, 10, COL_LABEL#
    DRAWSTRING "CH1: 0.5V/DIV   CH2: 2V/DIV", BRD#+2, SH#-BRD#+4, COL_LABEL#
RETURN
