REM ============================================
REM VOXEL TERRAIN - Proof of Concept
REM Comanche-style heightmap renderer
REM BazzBasic: https://ekbass.github.io/BazzBasic/
REM ============================================
REM Controls:
REM   Arrow keys  = Move / Rotate
REM   PgUp/PgDn   = Camera height
REM   W/S         = Horizon up/down (tilt effect)
REM   ESC         = Quit
REM ============================================

REM === Constants ===
LET SCREEN_W# = 640
LET SCREEN_H# = 480
LET MAP_SIZE# = 128
LET MAX_DIST# = 150
LET COL_STEP# = 2
LET SCALE# = 110
LET FOV# = 60

REM === Arrays ===
DIM heightmap$
DIM colormap$

REM === Init all variables ===
GOSUB [sub:init]

REM === Generate terrain (console mode, before SCREEN) ===
PRINT "Generating voxel terrain, please wait..."
GOSUB [sub:generateTerrain]
PRINT "Done! Starting renderer..."
SLEEP 800

REM === Init graphics ===
SCREEN 12
CLS
FastTrig(TRUE)

REM === Main loop ===
WHILE running$

    REM --- Input ---
    IF INKEY = KEY_ESC# THEN running$ = FALSE

    IF KEYDOWN(KEY_UP#) THEN
        camX$ = camX$ + FastCos(camAngle$) * moveSpeed$
        camY$ = camY$ + FastSin(camAngle$) * moveSpeed$
    ENDIF
    IF KEYDOWN(KEY_DOWN#) THEN
        camX$ = camX$ - FastCos(camAngle$) * moveSpeed$
        camY$ = camY$ - FastSin(camAngle$) * moveSpeed$
    ENDIF
    IF KEYDOWN(KEY_LEFT#) THEN
        camAngle$ = camAngle$ - rotSpeed$
        IF camAngle$ < 0 THEN camAngle$ = camAngle$ + 360
    ENDIF
    IF KEYDOWN(KEY_RIGHT#) THEN
        camAngle$ = camAngle$ + rotSpeed$
        IF camAngle$ >= 360 THEN camAngle$ = camAngle$ - 360
    ENDIF

    IF KEYDOWN(KEY_PGUP#) THEN camH$ = camH$ + 2
    IF KEYDOWN(KEY_PGDN#) THEN camH$ = camH$ - 2

    IF KEYDOWN(KEY_W#) THEN horizon$ = horizon$ - 3
    IF KEYDOWN(KEY_S#) THEN horizon$ = horizon$ + 3
    horizon$ = CLAMP(horizon$, 80, 350)
    camH$ = MAX(camH$, 30)

    REM --- Render ---
    SCREENLOCK ON

    LINE (0, 0)-(SCREEN_W#, horizon$ - 30), RGB(60, 100, 180), BF
    LINE (0, horizon$ - 30)-(SCREEN_W#, horizon$), RGB(120, 160, 210), BF
    LINE (0, horizon$)-(SCREEN_W#, SCREEN_H#), RGB(70, 90, 55), BF

    GOSUB [sub:renderVoxel]
    GOSUB [sub:drawHUD]

    SCREENLOCK OFF
    SLEEP 16

WEND

REM Cleanup
FastTrig(FALSE)
COLOR 7, 0
CLS
END


REM -----------------------------------------------
REM Init - all variables declared here, once
REM -----------------------------------------------
[sub:init]
    REM Camera
    LET camX$ = 64
    LET camY$ = 64
    LET camAngle$ = 0
    LET camH$ = 110
    LET horizon$ = 160

    REM Movement
    LET moveSpeed$ = 1.8
    LET rotSpeed$ = 3

    REM App state
    LET running$ = TRUE

    REM Terrain generation loop vars
    LET gx$ = 0
    LET gy$ = 0
    LET gx0$ = 0
    LET gx1$ = 0
    LET gy0$ = 0
    LET gy1$ = 0
    LET avg$ = 0
    LET pass$ = 0
    LET h$ = 0
    LET gv$ = 0
    LET rv$ = 0
    LET sv$ = 0

    REM Render loop vars
    LET sc$ = 0
    LET maxY$ = 0
    LET rayRatio$ = 0
    LET rayAngle$ = 0
    LET rCos$ = 0
    LET rSin$ = 0
    LET dist$ = 0
    LET hitSky$ = 0
    LET wx$ = 0
    LET wy$ = 0
    LET mx$ = 0
    LET my$ = 0
    LET terrH$ = 0
    LET projY$ = 0
    LET terrColor$ = 0
RETURN


REM -----------------------------------------------
REM Generate procedural heightmap + colormap
REM -----------------------------------------------
[sub:generateTerrain]

    FOR gy$ = 0 TO MAP_SIZE# - 1
        FOR gx$ = 0 TO MAP_SIZE# - 1
            heightmap$(gx$, gy$) = RND(90) + 5
        NEXT
    NEXT

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

    FOR gy$ = 0 TO MAP_SIZE# - 1
        FOR gx$ = 0 TO MAP_SIZE# - 1
            h$ = heightmap$(gx$, gy$)

            IF h$ < 22 THEN
                colormap$(gx$, gy$) = RGB(20, 50, 160)
            ELSEIF h$ < 28 THEN
                colormap$(gx$, gy$) = RGB(40, 80, 200)
            ELSEIF h$ < 34 THEN
                colormap$(gx$, gy$) = RGB(220, 200, 130)
            ELSEIF h$ < 58 THEN
                gv$ = 100 + INT((h$ - 34) * 1.5)
                colormap$(gx$, gy$) = RGB(35, gv$, 30)
            ELSEIF h$ < 75 THEN
                colormap$(gx$, gy$) = RGB(25, 90, 20)
            ELSEIF h$ < 88 THEN
                rv$ = 75 + INT((h$ - 75) * 2)
                colormap$(gx$, gy$) = RGB(rv$, rv$ - 10, rv$ - 15)
            ELSE
                sv$ = 220 + INT((h$ - 88) * 1.5)
                IF sv$ > 255 THEN sv$ = 255
                colormap$(gx$, gy$) = RGB(sv$, sv$, sv$)
            ENDIF

        NEXT
    NEXT

RETURN


REM -----------------------------------------------
REM Render voxel terrain - column by column
REM Classic Comanche / Voxel Space algorithm
REM -----------------------------------------------
[sub:renderVoxel]

    FOR sc$ = 0 TO SCREEN_W# - 1 STEP COL_STEP#

        maxY$ = SCREEN_H#

        rayRatio$ = sc$ / SCREEN_W#
        rayAngle$ = camAngle$ - FOV# / 2 + rayRatio$ * FOV#
        IF rayAngle$ < 0 THEN rayAngle$ = rayAngle$ + 360
        IF rayAngle$ >= 360 THEN rayAngle$ = rayAngle$ - 360

        rCos$ = FastCos(rayAngle$)
        rSin$ = FastSin(rayAngle$)

        dist$ = 1
        hitSky$ = 0

        WHILE dist$ <= MAX_DIST# AND hitSky$ = 0

            wx$ = camX$ + rCos$ * dist$
            wy$ = camY$ + rSin$ * dist$

            mx$ = MOD(MOD(INT(wx$), MAP_SIZE#) + MAP_SIZE#, MAP_SIZE#)
            my$ = MOD(MOD(INT(wy$), MAP_SIZE#) + MAP_SIZE#, MAP_SIZE#)

            terrH$ = heightmap$(mx$, my$)
            projY$ = INT((camH$ - terrH$) / dist$ * SCALE# + horizon$)

            IF projY$ < maxY$ THEN
                terrColor$ = colormap$(mx$, my$)
                LINE (sc$, projY$)-(sc$ + COL_STEP# - 1, maxY$ - 1), terrColor$, BF
                maxY$ = projY$
                IF maxY$ <= 0 THEN hitSky$ = 1
            ENDIF

            dist$ = dist$ + 1
        WEND

    NEXT

RETURN


REM -----------------------------------------------
REM HUD overlay
REM -----------------------------------------------
[sub:drawHUD]
    COLOR 15, 0
    LOCATE 1, 1
    PRINT "Arrow=Move/Turn  PgUp/Dn=Height  W/S=Tilt  ESC=Exit"
    LOCATE 2, 1
    PRINT "Angle:"; INT(camAngle$); "  Height:"; INT(camH$); "  Horizon:"; INT(horizon$); "   "
RETURN
