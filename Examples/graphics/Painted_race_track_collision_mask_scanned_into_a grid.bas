' ============================================
' Painted race track: collision mask scanned into a grid
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
'
' Controls: UP = throttle, DOWN = brake/reverse,
'           LEFT/RIGHT = steer, ESC = quit
'
' Optional assets (same folder as this .bas, 640x480, PNG):
'   track.png       - visual track, anything you like
'   track_mask.png  - flat colours only; road in ONE colour
' Without them a built-in ring track is used.

' DISCLAIMER
' This is one way to do it, but it takes pretty much computing power during the start.


[inits]
    ' --- Screen ---
    LET SCREEN_W# = 640
    LET SCREEN_H# = 480
    LET FRAME_MS# = 16.667                  ' one frame at 60 FPS

    ' --- Collision grid ---
    LET CELL#      = 4                      ' pixels per grid cell
    LET HALF_CELL# = CELL# / 2              ' sample the centre of each cell
    LET GRID_W#    = SCREEN_W# / CELL#      ' 160 columns
    LET GRID_H#    = SCREEN_H# / CELL#      ' 120 rows

    ' --- Surface types stored in the grid ---
    LET SURF_GRASS# = 0
    LET SURF_ROAD#  = 1
    LET SURF_OUT#   = 2                     ' outside the map = solid wall

    ' --- Start position: MUST be on the road (used as colour reference) ---
    LET START_X#     = 320
    LET START_Y#     = 80
    LET START_ANGLE# = 0                    ' 0 = facing right

    ' --- Handling (values per 60 FPS frame) ---
    LET ACCEL#           = 0.08
    LET BRAKE#           = 0.15
    LET ROAD_MAX#        = 4
    LET GRASS_MAX#       = 1.5
    LET REVERSE_MAX#     = 1.5
    LET ROAD_DRAG#       = 0.01
    LET GRASS_DRAG#      = 0.04
    LET OVERSPEED_DECEL# = 0.12             ' how hard grass bleeds off extra speed
    LET TURN#            = 3                ' degrees per frame at full speed

    ' --- Colours ---
    LET GRASS_COLOR# = RGB(40, 140, 40)
    LET ROAD_COLOR#  = RGB(120, 85, 50)
    LET CAR_COLOR#   = RGB(220, 30, 30)
    LET TEXT_COLOR#  = RGB(255, 255, 255)

    ' --- Assets ---
    LET TRACK_FILE# = PRG_ROOT# + "track.png"
    LET MASK_FILE#  = PRG_ROOT# + "track_mask.png"
    LET hasImages$  = FILEEXISTS(TRACK_FILE#) AND FILEEXISTS(MASK_FILE#)

    ' --- Collision data ---
    DIM road$
    LET roadRef$   = 0                      ' reference road colour from POINT
    LET roadCells$ = 0                      ' sanity counter shown on HUD

    ' --- Car state ---
    LET carX$     = START_X#
    LET carY$     = START_Y#
    LET angle$    = START_ANGLE#
    LET speed$    = 0
    LET maxSpeed$ = ROAD_MAX#
    LET drag$     = ROAD_DRAG#
    LET steer$    = 0
    LET newX$     = 0
    LET newY$     = 0
    LET curSurf$  = SURF_ROAD#

    ' --- [sub:surfaceAt] parameters: in qx$, qy$ -> out surf$ ---
    LET qx$   = 0
    LET qy$   = 0
    LET qgx$  = 0
    LET qgy$  = 0
    LET surf$ = 0

    ' --- Timing and HUD ---
    LET lastTick$  = 0
    LET now$       = 0
    LET dt$        = 1
    LET kmh$       = 0
    LET surfName$  = ""
    LET hud$       = ""

[init:screen]
    SCREEN 0, SCREEN_W#, SCREEN_H#, "Painted Track"
    FastTrig(TRUE)

    LET CAR# = LOADSHAPE("RECTANGLE", 20, 10, CAR_COLOR#)   ' long axis = forward

    IF hasImages$ THEN
        LET TRACK_IMG# = LOADIMAGE(TRACK_FILE#)
        LET MASK_IMG#  = LOADIMAGE(MASK_FILE#)
        MOVESHAPE TRACK_IMG#, 0, 0          ' images are top-left anchored
        MOVESHAPE MASK_IMG#, 0, 0
    END IF

    GOSUB [sub:buildGrid]                   ' the ONLY place POINT is used

[main]
    lastTick$ = TICKS
    WHILE INKEY <> KEY_ESC#
        now$ = TICKS
        dt$ = CLAMP((now$ - lastTick$) / FRAME_MS#, 0, 3)   ' cap after hiccups
        lastTick$ = now$

        GOSUB [sub:update]
        GOSUB [sub:draw]
    WEND

    FastTrig(FALSE)
    REMOVESHAPE CAR#
    IF hasImages$ THEN
        REMOVESHAPE TRACK_IMG#
        REMOVESHAPE MASK_IMG#
    END IF
END

' --------------------------------------------
' Draw the mask once, read it into road$(gx, gy)
' --------------------------------------------
[sub:buildGrid]
    SCREENLOCK ON
    GOSUB [sub:drawMask]
    SCREENLOCK OFF

    roadRef$   = POINT(START_X#, START_Y#)
    roadCells$ = 0

    FOR gy$ = 0 TO GRID_H# - 1
        FOR gx$ = 0 TO GRID_W# - 1
            IF POINT(gx$ * CELL# + HALF_CELL#, gy$ * CELL# + HALF_CELL#) = roadRef$ THEN
                road$(gx$, gy$) = SURF_ROAD#
                roadCells$ += 1
            ELSE
                road$(gx$, gy$) = SURF_GRASS#
            END IF
        NEXT
    NEXT
RETURN

' --------------------------------------------
' Surface lookup: in qx$, qy$ (pixels) -> out surf$
' --------------------------------------------
[sub:surfaceAt]
    qgx$ = FLOOR(qx$ / CELL#)               ' FLOOR, not INT: -0.5 must be -1
    qgy$ = FLOOR(qy$ / CELL#)
    IF BETWEEN(qgx$, 0, GRID_W# - 1) AND BETWEEN(qgy$, 0, GRID_H# - 1) THEN
        surf$ = road$(qgx$, qgy$)
    ELSE
        surf$ = SURF_OUT#
    END IF
RETURN

' --------------------------------------------
' Physics
' --------------------------------------------
[sub:update]
    ' 1) What are we driving on right now?
    qx$ = carX$
    qy$ = carY$
    GOSUB [sub:surfaceAt]
    curSurf$ = surf$
    IF curSurf$ = SURF_ROAD# THEN
        maxSpeed$ = ROAD_MAX#
        drag$     = ROAD_DRAG#
    ELSE
        maxSpeed$ = GRASS_MAX#
        drag$     = GRASS_DRAG#
    END IF

    ' 2) Throttle, brake, drag
    IF KEYDOWN(KEY_UP#) AND speed$ < maxSpeed$ THEN speed$ += ACCEL# * dt$
    IF KEYDOWN(KEY_DOWN#) THEN speed$ -= BRAKE# * dt$
    speed$ -= speed$ * drag$ * dt$
    IF speed$ > maxSpeed$ THEN speed$ -= OVERSPEED_DECEL# * dt$
    speed$ = CLAMP(speed$, -REVERSE_MAX#, ROAD_MAX#)

    ' 3) Steering scales with speed: no spinning on the spot,
    '    and it naturally inverts when reversing
    steer$ = TURN# * dt$ * (speed$ / ROAD_MAX#)
    IF KEYDOWN(KEY_LEFT#)  THEN angle$ -= steer$
    IF KEYDOWN(KEY_RIGHT#) THEN angle$ += steer$
    IF angle$ < 0 THEN angle$ += 360
    IF angle$ >= 360 THEN angle$ -= 360

    ' 4) Test the new position BEFORE committing to it
    newX$ = carX$ + FastCos(angle$) * speed$ * dt$
    newY$ = carY$ + FastSin(angle$) * speed$ * dt$
    qx$ = newX$
    qy$ = newY$
    GOSUB [sub:surfaceAt]
    IF surf$ = SURF_OUT# THEN
        speed$ = 0                          ' hit the edge of the world
    ELSE
        carX$ = newX$
        carY$ = newY$
    END IF
RETURN

' --------------------------------------------
' Rendering
' --------------------------------------------
[sub:draw]
    kmh$ = ROUND(ABS(speed$) * 30)
    IF curSurf$ = SURF_ROAD# THEN
        surfName$ = "road"
    ELSE
        surfName$ = "grass"
    END IF
    hud$ = FSTRING("Speed: {{-kmh$-}} km/h   Surface: {{-surfName$-}}   Road cells: {{-roadCells$-}}")

    SCREENLOCK ON
    GOSUB [sub:drawVisual]
    MOVESHAPE CAR#, carX$, carY$            ' shapes are centre anchored
    ROTATESHAPE CAR#, angle$                ' absolute degrees, clockwise
    DRAWSHAPE CAR#
    DRAWSTRING hud$, 10, 10, TEXT_COLOR#
    SCREENLOCK OFF
RETURN

[sub:drawVisual]
    IF hasImages$ THEN
        DRAWSHAPE TRACK_IMG#
    ELSE
        GOSUB [sub:drawTestTrack]
    END IF
RETURN

[sub:drawMask]
    IF hasImages$ THEN
        DRAWSHAPE MASK_IMG#
    ELSE
        GOSUB [sub:drawTestTrack]
    END IF
RETURN

' Fallback track: a ring of road between radius 120 and 200
[sub:drawTestTrack]
    LINE (0, 0)-(SCREEN_W#, SCREEN_H#), GRASS_COLOR#, BF
    CIRCLE (320, 240), 200, ROAD_COLOR#, 1
    CIRCLE (320, 240), 120, GRASS_COLOR#, 1
RETURN

' Output (graphics window):
' A red car on a brown ring track. On the road it reaches full speed;
' on grass it slows down and tops out at about a third of road speed.
' HUD example: "Speed: 120 km/h   Surface: road   Road cells: 8040"