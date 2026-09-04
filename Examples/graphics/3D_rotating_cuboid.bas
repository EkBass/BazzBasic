' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' 3D rotating cuboid
' ============================================
' Draws a 2 x 3 x 4 cuboid in 3D with perspective projection,
' rotated continuously around the X and Y axes.
' Three faces remain visible at virtually any rotation angle.
' Press ESC to exit.

[inits]
    LET SW#  = 800
    LET SH#  = 600
    LET CX#  = SW# / 2
    LET CY#  = SH# / 2
    LET FOV# = 400          ' focal length / perspective strength
    LET CAM# = 8            ' camera distance from cuboid

    LET LINE_COL# = RGB(0, 255, 120)
    LET HUD_COL#  = RGB(180, 180, 180)
    LET BG#       = RGB(0, 0, 0)

    LET DEG_X# = 0.7        ' X-axis rotation per frame (deg)
    LET DEG_Y# = 1.1        ' Y-axis rotation per frame (deg)

    SCREEN 0, SW#, SH#, "Draw a Cuboid - BazzBasic"

    ' Cuboid half-extents - relative dimensions 2 x 3 x 4.
    LET HW# = 1.0           ' half-width  on X (full = 2)
    LET HH# = 1.5           ' half-height on Y (full = 3)
    LET HD# = 2.0           ' half-depth  on Z (full = 4)

    ' 8 vertices of the cuboid, centered at the origin.
    ' Indices 0..3 = near face (z = -HD#), 4..7 = far face (z = +HD#).
    DIM vx$, vy$, vz$
    vx$(0) = -HW# : vy$(0) = -HH# : vz$(0) = -HD#
    vx$(1) =  HW# : vy$(1) = -HH# : vz$(1) = -HD#
    vx$(2) =  HW# : vy$(2) =  HH# : vz$(2) = -HD#
    vx$(3) = -HW# : vy$(3) =  HH# : vz$(3) = -HD#
    vx$(4) = -HW# : vy$(4) = -HH# : vz$(4) =  HD#
    vx$(5) =  HW# : vy$(5) = -HH# : vz$(5) =  HD#
    vx$(6) =  HW# : vy$(6) =  HH# : vz$(6) =  HD#
    vx$(7) = -HW# : vy$(7) =  HH# : vz$(7) =  HD#

    ' 12 edges, each stored as a pair of vertex indices.
    DIM ea$, eb$
    ea$(0)  = 0 : eb$(0)  = 1
    ea$(1)  = 1 : eb$(1)  = 2
    ea$(2)  = 2 : eb$(2)  = 3
    ea$(3)  = 3 : eb$(3)  = 0
    ea$(4)  = 4 : eb$(4)  = 5
    ea$(5)  = 5 : eb$(5)  = 6
    ea$(6)  = 6 : eb$(6)  = 7
    ea$(7)  = 7 : eb$(7)  = 4
    ea$(8)  = 0 : eb$(8)  = 4
    ea$(9)  = 1 : eb$(9)  = 5
    ea$(10) = 2 : eb$(10) = 6
    ea$(11) = 3 : eb$(11) = 7

    ' Per-frame projected screen coordinates for each vertex.
    DIM sx$, sy$

    ' Animation state and per-frame scratch variables.
    LET angX$  = 25
    LET angY$  = 35
    LET cosAx$ = 0
    LET sinAx$ = 0
    LET cosAy$ = 0
    LET sinAy$ = 0
    LET y1$    = 0
    LET z1$    = 0
    LET x2$    = 0
    LET z2$    = 0
    LET zp$    = 0
    LET ai$    = 0
    LET bi$    = 0

    LET running$ = TRUE

[main]
    WHILE running$
        IF INKEY = KEY_ESC# THEN running$ = FALSE

        ' Pre-compute trig once per frame, not per vertex.
        cosAx$ = COS(RAD(angX$))
        sinAx$ = SIN(RAD(angX$))
        cosAy$ = COS(RAD(angY$))
        sinAy$ = SIN(RAD(angY$))

        ' Rotate every vertex around X then Y, then project to 2D.
        FOR i$ = 0 TO 7
            ' Rotation around X: rewrites (y, z)
            y1$ = vy$(i$) * cosAx$ - vz$(i$) * sinAx$
            z1$ = vy$(i$) * sinAx$ + vz$(i$) * cosAx$

            ' Rotation around Y: rewrites (x, z) using freshly rotated z1$
            x2$ =  vx$(i$) * cosAy$ + z1$ * sinAy$
            z2$ = -vx$(i$) * sinAy$ + z1$ * cosAy$

            ' Perspective projection: divide by (z + cameraDistance).
            zp$ = z2$ + CAM#
            IF zp$ = 0 THEN zp$ = 0.0001
            sx$(i$) = CX# + (x2$ * FOV#) / zp$
            sy$(i$) = CY# + (y1$ * FOV#) / zp$
        NEXT

        SCREENLOCK ON
            LINE (0, 0)-(SW#, SH#), BG#, BF

            FOR i$ = 0 TO 11
                ai$ = ea$(i$)
                bi$ = eb$(i$)
                LINE (sx$(ai$), sy$(ai$))-(sx$(bi$), sy$(bi$)), LINE_COL#
            NEXT

            DRAWSTRING "Cuboid 2 x 3 x 4 - press ESC to quit", 10, 10, HUD_COL#
        SCREENLOCK OFF

        angX$ = angX$ + DEG_X#
        angY$ = angY$ + DEG_Y#
        IF angX$ >= 360 THEN angX$ = angX$ - 360
        IF angY$ >= 360 THEN angY$ = angY$ - 360

        SLEEP 16
    WEND
END

' Output:
' An 800x600 SDL2 window opens showing a green wireframe cuboid
' (relative dimensions 2 x 3 x 4) tumbling smoothly around the X
' and Y axes. Three faces are visible at virtually every angle.
' ESC closes the window.
