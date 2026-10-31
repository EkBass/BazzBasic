' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Flies a plane sprite turned with the left and right mouse buttons, and wraps it to the opposite screen edge once it has fully left the screen.
' CATEGORY: input
' TAGS: mouse, mouse buttons, sprite rotation, screen wrap, delta time
' REQUIRES: assets/plane.png
' MINVERSION: 1.5
' ============================================

[inits]
    ' --- Screen ---
    LET SCREEN_W# = 800
    LET SCREEN_H# = 600

    ' --- Plane image ---
    LET PLANE_FILE# = PRG_ROOT# + "assets/plane.png"
    LET PLANE_SIZE# = 128               ' image is 128x128
    LET HALF#       = PLANE_SIZE# / 2   ' offset from centre to top-left

    ' --- Flight ---
    LET SPEED#     = 200                ' pixels per second
    LET TURN_RATE# = 180                ' degrees per second while a button is held
    LET MAX_DT#    = 0.05               ' longest allowed frame step (50 ms)

    ' --- Wrap boundaries for the plane's CENTRE point ---
    ' The plane must leave the screen completely before it reappears,
    ' so the limits sit half a plane-width outside each edge.
    LET WRAP_MIN_X# = 0 - HALF#
    LET WRAP_MAX_X# = SCREEN_W# + HALF#
    LET WRAP_MIN_Y# = 0 - HALF#
    LET WRAP_MAX_Y# = SCREEN_H# + HALF#
    LET WRAP_W#     = SCREEN_W# + PLANE_SIZE#
    LET WRAP_H#     = SCREEN_H# + PLANE_SIZE#

    ' --- Colours ---
    LET COL_BG#   = RGB(90, 150, 210)
    LET COL_TEXT# = RGB(255, 255, 255)

    ' --- State ---
    LET x$        = SCREEN_W# / 2       ' plane CENTRE point
    LET y$        = SCREEN_H# / 2
    LET heading$  = 0                   ' degrees: 0 = north, clockwise positive
    LET rad$      = 0
    LET key$      = 0
    LET running$  = TRUE
    LET now$      = 0
    LET lastTick$ = 0
    LET dt$       = 0

    ' Check the asset before opening a window, so a missing file
    ' gives a clear message instead of a load error.
    IF NOT FILEEXISTS(PLANE_FILE#) THEN
        PRINT "Missing file: " + PLANE_FILE#
        END
    END IF

[init:screen]
    SCREEN 0, SCREEN_W#, SCREEN_H#, "Plane"
    LET PLANE# = LOADIMAGE(PLANE_FILE#)
    lastTick$ = TICKS

[main]
    WHILE running$
        key$ = INKEY
        IF key$ = KEY_ESC# THEN running$ = FALSE

        now$ = TICKS
        dt$ = MIN((now$ - lastTick$) / 1000, MAX_DT#)
        lastTick$ = now$

        GOSUB [sub:steer]
        GOSUB [sub:move]
        GOSUB [sub:draw]
        SLEEP 16
    WEND
    REMOVESHAPE PLANE#
END

' ============================================
' Subroutines
' ============================================

[sub:steer]
    ' Held buttons turn continuously. Both held = they cancel out.
    IF MOUSELEFT  THEN heading$ -= TURN_RATE# * dt$
    IF MOUSERIGHT THEN heading$ += TURN_RATE# * dt$

    ' Keep heading in 0..360 so the number never grows without limit
    IF heading$ >= 360 THEN heading$ -= 360
    IF heading$ < 0    THEN heading$ += 360
RETURN

[sub:move]
    ' Compass heading -> screen velocity.
    ' Screen Y grows downward, so north means negative Y:
    '   heading   0 -> (0, -1)  north
    '   heading  90 -> (1,  0)  east
    rad$ = RAD(heading$)
    x$ += SIN(rad$) * SPEED# * dt$
    y$ -= COS(rad$) * SPEED# * dt$

    ' Wrap once the whole plane is off screen
    IF x$ < WRAP_MIN_X# THEN x$ += WRAP_W#
    IF x$ > WRAP_MAX_X# THEN x$ -= WRAP_W#
    IF y$ < WRAP_MIN_Y# THEN y$ += WRAP_H#
    IF y$ > WRAP_MAX_Y# THEN y$ -= WRAP_H#
RETURN

[sub:draw]
    SCREENLOCK ON
        LINE (0, 0)-(SCREEN_W#, SCREEN_H#), COL_BG#, BF
        ROTATESHAPE PLANE#, heading$
        ' Images are positioned by their top-left corner, so shift by half size
        MOVESHAPE PLANE#, CINT(x$ - HALF#), CINT(y$ - HALF#)
        DRAWSHAPE PLANE#
        DRAWSTRING "Left mouse = turn left   Right mouse = turn right   ESC = quit", 10, 10, COL_TEXT#
    SCREENLOCK OFF
RETURN

' Output:
' An 800x600 sky-blue window with the plane in the middle, flying north.
' Holding a mouse button turns it; flying off an edge brings it back
' from the opposite edge. ESC closes the window.