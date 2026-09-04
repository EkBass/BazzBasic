' ==========================================
' Voxel_terrain.bas — BazzBasic
' Comanche-style heightmap renderer
' Procedural terrain, column-by-column voxel cast
' https://ekbass.github.io/BazzBasic/
' ==========================================
' Controls:
'   Arrow keys  = Move / Rotate
'   PgUp/PgDn   = Camera height
'   W / S       = Horizon tilt
'   ESC         = Quit
' ==========================================

[inits]
    ' Screen
    LET SCREEN_W# = 640
    LET SCREEN_H# = 480

    ' Terrain
    LET MAP_SIZE# = 128
    LET MAX_DIST# = 150
    LET COL_STEP# = 2
    LET SCALE#    = 110
    LET FOV#      = 60

    ' Color palette indices
    LET LGRAY# = 7

    ' Sky / ground gradient colors (RGB)
    LET SKY_TOP#  = RGB(60,  100, 180)
    LET SKY_BOT#  = RGB(120, 160, 210)
    LET GROUND#   = RGB(70,  90,  55)

    DIM heightmap$
    DIM colormap$

    ' Camera
    LET camX$     = 64
    LET camY$     = 64
    LET camAngle$ = 0
    LET camH$     = 110
    LET horizon$  = 160

    ' Movement
    LET moveSpeed$ = 1.8
    LET rotSpeed$  = 3

    ' App state
    LET running$ = TRUE

    ' Shared working variables — terrain generation
    LET gx$, gy$, gx0$, gx1$, gy0$, gy1$
    LET avg$, pass$, h$, gv$, rv$, sv$

    ' Shared working variables — render loop
    LET sc$, maxY$, rayRatio$, rayAngle$
    LET rCos$, rSin$, dist$, hitSky$
    LET wx$, wy$, mx$, my$
    LET terrH$, projY$, terrColor$

[init:terrain]
    PRINT "Generating voxel terrain, please wait..."
    GOSUB [sub:generateTerrain]
    PRINT "Done! Starting renderer..."
    SLEEP 800

[init:gfx]
    SCREEN 0, SCREEN_W#, SCREEN_H#, "Voxel Terrain"
    CLS
    FastTrig(TRUE)

[main]
    WHILE running$

        ' --- Input ---
        IF INKEY = KEY_ESC# THEN running$ = FALSE

        IF KEYDOWN(KEY_UP#) THEN
            camX$ = camX$ + FastCos(camAngle$) * moveSpeed$
            camY$ = camY$ + FastSin(camAngle$) * moveSpeed$
        END IF
        IF KEYDOWN(KEY_DOWN#) THEN
            camX$ = camX$ - FastCos(camAngle$) * moveSpeed$
            camY$ = camY$ - FastSin(camAngle$) * moveSpeed$
        END IF

        IF KEYDOWN(KEY_LEFT#) THEN
            camAngle$ = camAngle$ - rotSpeed$
            IF camAngle$ < 0 THEN camAngle$ = camAngle$ + 360
        END IF
        IF KEYDOWN(KEY_RIGHT#) THEN
            camAngle$ = camAngle$ + rotSpeed$
            IF camAngle$ >= 360 THEN camAngle$ = camAngle$ - 360
        END IF

        IF KEYDOWN(KEY_PGUP#) THEN camH$ = camH$ + 2
        IF KEYDOWN(KEY_PGDN#) THEN camH$ = camH$ - 2

        IF KEYDOWN(KEY_W#) THEN horizon$ = horizon$ - 3
        IF KEYDOWN(KEY_S#) THEN horizon$ = horizon$ + 3
        horizon$ = CLAMP(horizon$, 80, 350)
        camH$    = MAX(camH$, 30)

        ' --- Render ---
        SCREENLOCK ON

        LINE (0, 0)-(SCREEN_W#, horizon$ - 30), SKY_TOP#, BF
        LINE (0, horizon$ - 30)-(SCREEN_W#, horizon$), SKY_BOT#, BF
        LINE (0, horizon$)-(SCREEN_W#, SCREEN_H#), GROUND#, BF

        GOSUB [sub:renderVoxel]
        GOSUB [sub:drawHUD]

        SCREENLOCK OFF
        SLEEP 16

    WEND

    FastTrig(FALSE)
    COLOR LGRAY#, 0
    CLS
END

' -----------------------------------------------
' Generate procedural heightmap + colormap
' -----------------------------------------------
[sub:generateTerrain]
    FOR gy$ = 0 TO MAP_SIZE# - 1
        FOR gx$ = 0 TO MAP_SIZE# - 1
            heightmap$(gx$, gy$) = RND(90) + 5
        NEXT
    NEXT

    ' Smooth passes
    FOR pass$ = 1 TO 8
        FOR gy$ = 0 TO MAP_SIZE# - 1
            FOR gx$ = 0 TO MAP_SIZE# - 1
                gx1$ = MOD(gx$ + 1, MAP_SIZE#)
                gx0$ = MOD(gx$ - 1 + MAP_SIZE#, MAP_SIZE#)
                gy1$ = MOD(gy$ + 1, MAP_SIZE#)
                gy0$ = MOD(gy$ - 1 + MAP_SIZE#, MAP_SIZE#)
                avg$ = (heightmap$(gx0$, gy$) + heightmap$(gx1$, gy$) + heightmap$(gx$, gy0$) + heightmap$(gx$, gy1$) + heightmap$(gx$, gy$) * 2) / 6
                heightmap$(gx$, gy$) = avg$
            NEXT
        NEXT
    NEXT

    ' Assign colors by height band
    FOR gy$ = 0 TO MAP_SIZE# - 1
        FOR gx$ = 0 TO MAP_SIZE# - 1
            h$ = heightmap$(gx$, gy$)

            IF h$ < 22 THEN
                colormap$(gx$, gy$) = RGB(20, 50, 160)         ' deep water
            ELSEIF h$ < 28 THEN
                colormap$(gx$, gy$) = RGB(40, 80, 200)         ' shallow water
            ELSEIF h$ < 34 THEN
                colormap$(gx$, gy$) = RGB(220, 200, 130)       ' sand / beach
            ELSEIF h$ < 58 THEN
                gv$ = 100 + INT((h$ - 34) * 1.5)
                colormap$(gx$, gy$) = RGB(35, gv$, 30)         ' low grassland
            ELSEIF h$ < 75 THEN
                colormap$(gx$, gy$) = RGB(25, 90, 20)          ' forest
            ELSEIF h$ < 88 THEN
                rv$ = 75 + INT((h$ - 75) * 2)
                colormap$(gx$, gy$) = RGB(rv$, rv$ - 10, rv$ - 15) ' rock
            ELSE
                sv$ = MIN(220 + INT((h$ - 88) * 1.5), 255)
                colormap$(gx$, gy$) = RGB(sv$, sv$, sv$)       ' snow
            END IF

        NEXT
    NEXT
RETURN

' -----------------------------------------------
' Render voxel terrain — column by column
' Classic Comanche / Voxel Space algorithm
' -----------------------------------------------
[sub:renderVoxel]
    FOR sc$ = 0 TO SCREEN_W# - 1 STEP COL_STEP#

        maxY$     = SCREEN_H#
        rayRatio$ = sc$ / SCREEN_W#
        rayAngle$ = camAngle$ - FOV# / 2 + rayRatio$ * FOV#

        IF rayAngle$ < 0   THEN rayAngle$ = rayAngle$ + 360
        IF rayAngle$ >= 360 THEN rayAngle$ = rayAngle$ - 360

        rCos$   = FastCos(rayAngle$)
        rSin$   = FastSin(rayAngle$)
        dist$   = 1
        hitSky$ = 0

        WHILE dist$ <= MAX_DIST# AND hitSky$ = 0

            wx$ = camX$ + rCos$ * dist$
            wy$ = camY$ + rSin$ * dist$

            mx$ = MOD(MOD(INT(wx$), MAP_SIZE#) + MAP_SIZE#, MAP_SIZE#)
            my$ = MOD(MOD(INT(wy$), MAP_SIZE#) + MAP_SIZE#, MAP_SIZE#)

            terrH$  = heightmap$(mx$, my$)
            projY$  = INT((camH$ - terrH$) / dist$ * SCALE# + horizon$)

            IF projY$ < maxY$ THEN
                terrColor$ = colormap$(mx$, my$)
                LINE (sc$, projY$)-(sc$ + COL_STEP# - 1, maxY$ - 1), terrColor$, BF
                maxY$ = projY$
                IF maxY$ <= 0 THEN hitSky$ = 1
            END IF

            dist$ = dist$ + 1
        WEND

    NEXT
RETURN

' -----------------------------------------------
' HUD overlay
' -----------------------------------------------
[sub:drawHUD]
    COLOR 15, 0
    LOCATE 1, 1
    PRINT "Arrows=Move/Turn  PgUp/Dn=Height  W/S=Tilt  ESC=Quit"
    LOCATE 2, 1
    PRINT "Angle:"; INT(camAngle$); "  Height:"; INT(camH$); "  Horizon:"; INT(horizon$); "   "
RETURN