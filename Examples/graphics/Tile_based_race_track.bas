' ============================================
' Tile-based race track: 64x64 tiles, automatic kerbs
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
'
' Controls: UP = throttle, DOWN = brake/reverse,
'           LEFT/RIGHT = steer, ESC = quit
'
' Map legend:  .  grass
'              =  road (kerbs are placed automatically)
'              T  grass with a tree (only the trunk is solid)
'              any other character is treated as grass

[inits]
    ' --- Screen: 10 x 7 tiles + 32 px HUD strip ---
    LET TILE#      = 64
    LET HALF_TILE# = TILE# / 2
    LET GRID_W#    = 10
    LET GRID_H#    = 7
    LET SCREEN_W#  = GRID_W# * TILE#        ' 640
    LET PLAY_H#    = GRID_H# * TILE#        ' 448
    LET SCREEN_H#  = PLAY_H# + 32           ' 480
    LET FRAME_MS#  = 16.667                 ' one frame at 60 FPS

    ' --- Tile types: what the map says ---
    LET TILE_GRASS# = 0
    LET TILE_ROAD#  = 1
    LET TILE_TREE#  = 2

    ' --- Surface types: what the car feels ---
    LET SURF_GRASS# = 0
    LET SURF_ROAD#  = 1
    LET SURF_SOLID# = 2

    ' --- Kerb sides as bit values ---
    LET SIDE_UP#    = 1
    LET SIDE_RIGHT# = 2
    LET SIDE_DOWN#  = 4
    LET SIDE_LEFT#  = 8

    ' Neighbour offsets, index b$ matches bit value POW(2, b$)
    DIM dirX$, dirY$
    dirX$(0) = 0
    dirY$(0) = -1                           ' b$ = 0 -> up    (1)
    dirX$(1) = 1
    dirY$(1) = 0                            ' b$ = 1 -> right (2)
    dirX$(2) = 0
    dirY$(2) = 1                            ' b$ = 2 -> down  (4)
    dirX$(3) = -1
    dirY$(3) = 0                            ' b$ = 3 -> left  (8)

    ' --- Look ---
    LET KERB#   = 8                         ' kerb thickness in pixels
    LET STRIPE# = 16                        ' red/white stripe length
    LET TREE_R# = 14                        ' trunk collision radius
    LET CANOPY# = 24                        ' drawn canopy radius (larger!)

    LET GRASS_COLOR#  = RGB(40, 140, 40)
    LET ROAD_COLOR#   = RGB(90, 90, 95)
    LET KERB_RED#     = RGB(200, 30, 30)
    LET KERB_WHITE#   = RGB(240, 240, 240)
    LET CANOPY_DARK#  = RGB(20, 90, 30)
    LET CANOPY_LIGHT# = RGB(45, 125, 50)
    LET CAR_COLOR#    = RGB(40, 90, 230)
    LET HUD_BG#       = RGB(0, 0, 0)
    LET TEXT_COLOR#   = RGB(255, 255, 255)

    ' --- The track: GRID_H# rows, each GRID_W# characters ---
    DIM mapRows$
    mapRows$(0) = "T........T"
    mapRows$(1) = ".======..."
    mapRows$(2) = ".=....=..."
    mapRows$(3) = ".=....===."
    mapRows$(4) = ".=..T...=."
    mapRows$(5) = ".========."
    mapRows$(6) = "T..T......"

    ' --- Start tile: must be road ---
    LET START_GX#    = 3
    LET START_GY#    = 5
    LET START_X#     = START_GX# * TILE# + HALF_TILE#
    LET START_Y#     = START_GY# * TILE# + HALF_TILE#
    LET START_ANGLE# = 0                    ' facing right

    ' --- Handling (values per 60 FPS frame) ---
    LET ACCEL#           = 0.08
    LET BRAKE#           = 0.15
    LET ROAD_MAX#        = 4
    LET GRASS_MAX#       = 1.5
    LET REVERSE_MAX#     = 1.5
    LET ROAD_DRAG#       = 0.01
    LET GRASS_DRAG#      = 0.04
    LET OVERSPEED_DECEL# = 0.12
    LET TURN#            = 6                ' degrees per frame at full speed
    LET BOUNCE#          = 0.3              ' speed kept (reversed) after a crash

    ' --- Track data built from mapRows$ ---
    DIM tile$, kerb$

    ' --- Work variables for the subroutines ---
    LET ch$     = ""
    LET m$      = 0
    LET nx$     = 0
    LET ny$     = 0
    LET isRoad$ = FALSE
    LET tx$     = 0
    LET ty$     = 0
    LET ks$     = 0
    LET kx1$    = 0
    LET ky1$    = 0
    LET kx2$    = 0
    LET ky2$    = 0
    LET horiz$  = TRUE
    LET cx$     = 0
    LET cy$     = 0

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
    LET qt$   = 0
    LET surf$ = 0

    ' --- Timing and HUD ---
    LET lastTick$ = 0
    LET now$      = 0
    LET dt$       = 1
    LET kmh$      = 0
    LET surfName$ = ""
    LET hud$      = ""

' [inits], with the other constants:
    LET CAR_FILE#  = PRG_ROOT# + "assets/plr_car.png"
    LET CAR_SCALE# = 0.14                       ' 200 x 92 -> 28 x 12 px
    LET CAR_W#     = INT(200 * CAR_SCALE#)      ' BazzBasic has no image-size query,
    LET CAR_H#     = INT(92 * CAR_SCALE#)       ' so the source size is written out
    ' (remove CAR_COLOR#, it's no longer used)

' [init:track], before the window opens, so the error PRINTs normally:
    IF NOT FILEEXISTS(CAR_FILE#) THEN
        PRINT "Missing car image: " + CAR_FILE#
        END
    END IF
    GOSUB [sub:buildTrack]

[init:screen]
    SCREEN 0, SCREEN_W#, SCREEN_H#, "Tile Track"
    FastTrig(TRUE)
    LET CAR# = LOADIMAGE(CAR_FILE#)
    SCALESHAPE CAR#, CAR_SCALE#

[main]
    lastTick$ = TICKS
    WHILE INKEY <> KEY_ESC#
        now$ = TICKS
        dt$ = CLAMP((now$ - lastTick$) / FRAME_MS#, 0, 3)
        lastTick$ = now$

        GOSUB [sub:update]
        GOSUB [sub:draw]
    WEND

    FastTrig(FALSE)
    REMOVESHAPE CAR#
END

' --------------------------------------------
' Parse the text map, validate it, compute kerb masks
' --------------------------------------------
[sub:buildTrack]
    IF LEN(mapRows$()) <> GRID_H# THEN
        PRINT FSTRING("Map error: expected {{-GRID_H#-}} rows.")
        END
    END IF

    ' Pass 1: characters -> tile types
    FOR gy$ = 0 TO GRID_H# - 1
        IF LEN(mapRows$(gy$)) <> GRID_W# THEN
            PRINT FSTRING("Map error: row {{-gy$-}} must be {{-GRID_W#-}} characters.")
            END
        END IF
        FOR gx$ = 0 TO GRID_W# - 1
            ch$ = MID(mapRows$(gy$), gx$ + 1, 1)
            IF ch$ = "=" THEN
                tile$(gx$, gy$) = TILE_ROAD#
            ELSEIF ch$ = "T" THEN
                tile$(gx$, gy$) = TILE_TREE#
            ELSE
                tile$(gx$, gy$) = TILE_GRASS#
            END IF
        NEXT
    NEXT

    IF tile$(START_GX#, START_GY#) <> TILE_ROAD# THEN
        PRINT "Map error: the start tile is not road."
        END
    END IF

    ' Pass 2: kerb on every side whose neighbour is not road
    FOR gy$ = 0 TO GRID_H# - 1
        FOR gx$ = 0 TO GRID_W# - 1
            m$ = 0
            IF tile$(gx$, gy$) = TILE_ROAD# THEN
                FOR b$ = 0 TO 3
                    nx$ = gx$ + dirX$(b$)
                    ny$ = gy$ + dirY$(b$)
                    GOSUB [sub:isRoadAt]
                    IF NOT isRoad$ THEN m$ += POW(2, b$)
                NEXT
            END IF
            kerb$(gx$, gy$) = m$
        NEXT
    NEXT
RETURN

' in nx$, ny$ (tile coords) -> out isRoad$
' Nested IF on purpose: never read tile$() outside the map
[sub:isRoadAt]
    isRoad$ = FALSE
    IF BETWEEN(nx$, 0, GRID_W# - 1) AND BETWEEN(ny$, 0, GRID_H# - 1) THEN
        IF tile$(nx$, ny$) = TILE_ROAD# THEN isRoad$ = TRUE
    END IF
RETURN

' --------------------------------------------
' Surface lookup: in qx$, qy$ (pixels) -> out surf$
' Step 1: tile type. Step 2: local test for special tiles.
' --------------------------------------------
[sub:surfaceAt]
    qgx$ = FLOOR(qx$ / TILE#)
    qgy$ = FLOOR(qy$ / TILE#)
    surf$ = SURF_SOLID#                     ' outside the map = wall
    IF BETWEEN(qgx$, 0, GRID_W# - 1) AND BETWEEN(qgy$, 0, GRID_H# - 1) THEN
        qt$ = tile$(qgx$, qgy$)
        IF qt$ = TILE_ROAD# THEN
            surf$ = SURF_ROAD#
        ELSEIF qt$ = TILE_TREE# THEN
            surf$ = SURF_GRASS#
            IF DISTANCE(qx$, qy$, qgx$ * TILE# + HALF_TILE#, qgy$ * TILE# + HALF_TILE#) < TREE_R# THEN
                surf$ = SURF_SOLID#
            END IF
        ELSE
            surf$ = SURF_GRASS#
        END IF
    END IF
RETURN

' --------------------------------------------
' Physics
' --------------------------------------------
[sub:update]
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

    IF KEYDOWN(KEY_UP#) AND speed$ < maxSpeed$ THEN speed$ += ACCEL# * dt$
    IF KEYDOWN(KEY_DOWN#) THEN speed$ -= BRAKE# * dt$
    speed$ -= speed$ * drag$ * dt$
    IF speed$ > maxSpeed$ THEN speed$ -= OVERSPEED_DECEL# * dt$
    speed$ = CLAMP(speed$, -REVERSE_MAX#, ROAD_MAX#)

    steer$ = TURN# * dt$ * (speed$ / ROAD_MAX#)
    IF KEYDOWN(KEY_LEFT#)  THEN angle$ -= steer$
    IF KEYDOWN(KEY_RIGHT#) THEN angle$ += steer$
    IF angle$ < 0 THEN angle$ += 360
    IF angle$ >= 360 THEN angle$ -= 360

    newX$ = carX$ + FastCos(angle$) * speed$ * dt$
    newY$ = carY$ + FastSin(angle$) * speed$ * dt$
    qx$ = newX$
    qy$ = newY$
    GOSUB [sub:surfaceAt]
    IF surf$ = SURF_SOLID# THEN
        speed$ = -speed$ * BOUNCE#          ' small bounce off trees and walls
    ELSE
        carX$ = newX$
        carY$ = newY$
    END IF
RETURN

' --------------------------------------------
' Rendering: grass -> roads -> car -> trees -> HUD
' Trees are drawn after the car, so the car slips under the canopy
' --------------------------------------------
[sub:draw]
    kmh$ = ROUND(ABS(speed$) * 30)
    IF curSurf$ = SURF_ROAD# THEN
        surfName$ = "road"
    ELSE
        surfName$ = "grass"
    END IF
    hud$ = FSTRING("Speed: {{-kmh$-}} km/h   Surface: {{-surfName$-}}")

    SCREENLOCK ON
    LINE (0, 0)-(SCREEN_W#, PLAY_H#), GRASS_COLOR#, BF

    FOR gy$ = 0 TO GRID_H# - 1
        FOR gx$ = 0 TO GRID_W# - 1
            IF tile$(gx$, gy$) = TILE_ROAD# THEN
                tx$ = gx$ * TILE#
                ty$ = gy$ * TILE#
                GOSUB [sub:drawRoadTile]
            END IF
        NEXT
    NEXT

    MOVESHAPE CAR#, carX$ - CAR_W# / 2, carY$ - CAR_H# / 2   ' centre -> top-left
    ROTATESHAPE CAR#, angle$
    DRAWSHAPE CAR#

    FOR gy$ = 0 TO GRID_H# - 1
        FOR gx$ = 0 TO GRID_W# - 1
            IF tile$(gx$, gy$) = TILE_TREE# THEN
                tx$ = gx$ * TILE#
                ty$ = gy$ * TILE#
                GOSUB [sub:drawTree]
            END IF
        NEXT
    NEXT

    LINE (0, PLAY_H#)-(SCREEN_W#, SCREEN_H#), HUD_BG#, BF
    DRAWSTRING hud$, 10, PLAY_H# + 8, TEXT_COLOR#
    SCREENLOCK OFF
RETURN

' in tx$, ty$ (tile top-left), gx$, gy$ (tile coords)
[sub:drawRoadTile]
    LINE (tx$, ty$)-(tx$ + TILE# - 1, ty$ + TILE# - 1), ROAD_COLOR#, BF
    m$ = kerb$(gx$, gy$)
    FOR b$ = 0 TO 3
        ks$ = POW(2, b$)
        IF MOD(INT(m$ / ks$), 2) = 1 THEN GOSUB [sub:drawKerb]
    NEXT
RETURN

' in tx$, ty$, ks$ (SIDE_* value)
[sub:drawKerb]
    kx1$ = tx$
    ky1$ = ty$
    kx2$ = tx$ + TILE# - 1
    ky2$ = ty$ + TILE# - 1
    horiz$ = TRUE
    IF ks$ = SIDE_UP# THEN
        ky2$ = ty$ + KERB# - 1
    ELSEIF ks$ = SIDE_DOWN# THEN
        ky1$ = ty$ + TILE# - KERB#
    ELSEIF ks$ = SIDE_RIGHT# THEN
        kx1$ = tx$ + TILE# - KERB#
        horiz$ = FALSE
    ELSE
        kx2$ = tx$ + KERB# - 1
        horiz$ = FALSE
    END IF

    ' Red base, then white stripes. Period 32 divides 64,
    ' so stripes line up seamlessly across neighbouring tiles.
    LINE (kx1$, ky1$)-(kx2$, ky2$), KERB_RED#, BF
    FOR s$ = 0 TO TILE# - 1 STEP STRIPE# * 2
        IF horiz$ THEN
            LINE (kx1$ + s$, ky1$)-(kx1$ + s$ + STRIPE# - 1, ky2$), KERB_WHITE#, BF
        ELSE
            LINE (kx1$, ky1$ + s$)-(kx2$, ky1$ + s$ + STRIPE# - 1), KERB_WHITE#, BF
        END IF
    NEXT
RETURN

' in tx$, ty$
[sub:drawTree]
    cx$ = tx$ + HALF_TILE#
    cy$ = ty$ + HALF_TILE#
    CIRCLE (cx$, cy$), CANOPY#, CANOPY_DARK#, 1
    CIRCLE (cx$ - 6, cy$ - 6), CANOPY# / 2, CANOPY_LIGHT#, 1
RETURN

' Output (graphics window):
' A grey loop track on grass with red/white kerbs on every outer edge,
' a blue car on the bottom straight, and five trees. The window opens
' instantly (no pixel scan). Hitting a trunk bounces the car back;
' the canopy edge can be driven under.
' HUD example: "Speed: 120 km/h   Surface: road"