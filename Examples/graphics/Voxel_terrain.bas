' ============================================
' Voxel Terrain — optimized, with FPS counter
' Comanche-style heightmap renderer (Voxel Space)
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Controls:
'   Arrow keys  = Move / Rotate
'   PgUp/PgDn   = Camera height
'   W / S       = Horizon tilt
'   ESC         = Quit
' ============================================

' UPDATED 15th Oct. 2026
' I think I was able to double the speed of this one
' EK

[inits]
    ' --- Screen ---
    LET SCREEN_W# = 640
    LET SCREEN_H# = 480

    ' --- Terrain & renderer tuning ---
    LET MAP_SIZE# = 128                 ' heightmap is MAP_SIZE# x MAP_SIZE#, wraps at edges
    LET MAX_DIST# = 150                 ' view distance in map units
    LET COL_STEP# = 2                   ' screen columns per ray (1 = sharper but ~2x slower)
    LET SCALE#    = 110                 ' vertical projection scale
    LET FOV#      = 60                  ' horizontal field of view, degrees
    LET DZ_GROW#  = 0.02                ' sample spacing growth per step (0 = uniform, as original)

    ' --- Derived constants ---
    LET PLANE_LEN#   = TAN(RAD(FOV# / 2))                          ' camera plane half-width
    LET COL_FRAC#    = 2 * COL_STEP# / SCREEN_W#                   ' plane fraction per column
    LET WRAP_OFFSET# = CEIL(MAX_DIST# * 2 / MAP_SIZE#) * MAP_SIZE# ' keeps ray coords positive (FOV < ~120)

    ' --- Timing ---
    LET FRAME_MS#  = 1000 / 60          ' movement speeds below are "per 60 FPS frame"
    LET MAX_DELTA# = 100                ' cap a single time step (no teleport after a stall)

    ' --- Colors and texts (computed once, never in the hot loop) ---
    LET SKY_TOP#  = RGB(60, 100, 180)
    LET SKY_BOT#  = RGB(120, 160, 210)
    LET GROUND#   = RGB(70, 90, 55)
    LET HUD_BG#   = RGB(0, 0, 0)
    LET HUD_TEXT# = RGB(255, 255, 255)
    LET HUD_FPS#  = RGB(255, 230, 80)
    LET HUD_HELP# = "Arrows=Move/Turn  PgUp/Dn=Height  W/S=Tilt  ESC=Quit"

    ' --- Map data: flat 1D arrays, index = y * MAP_SIZE# + x ---
    DIM heightmap$                      ' raw terrain height
    DIM heightProj$                     ' height * SCALE#, pre-multiplied for projection
    DIM colormap$                       ' RGB color per cell

    ' --- Camera ---
    LET camX$     = 64
    LET camY$     = 64
    LET camAngle$ = 0
    LET camH$     = 110
    LET horizon$  = 160
    LET dirX$     = 1
    LET dirY$     = 0

    ' --- Movement speeds (per 60 FPS frame, scaled by delta time) ---
    LET moveSpeed$ = 1.8
    LET rotSpeed$  = 3
    LET liftSpeed$ = 2
    LET tiltSpeed$ = 3

    ' --- Timing / FPS state ---
    LET nowT$        = 0
    LET lastT$       = 0
    LET delta$       = 0
    LET frameScale$  = 1
    LET frames$      = 0
    LET fpsTimer$    = 0
    LET fps$         = 0
    LET renderStart$ = 0
    LET renderSum$   = 0
    LET renderMs$    = 0
    LET statusText$  = ""
    LET angleI$, heightI$, horizonI$

    ' --- Working variables: terrain generation ---
    LET idx$, row$, gx0$, gx1$, gy0$, gy1$, avg$, h$, gv$, rv$, sv$

    ' --- Working variables: renderer ---
    LET camHS$, baseX$, baseY$, rdx$, rdy$, colDX$, colDY$
    LET maxY$, z$, dz$, wx$, wy$, cell$, projY$

[init:terrain]
    PRINT "Generating voxel terrain, please wait..."
    GOSUB [sub:generateTerrain]
    PRINT "Done! Starting renderer..."
    SLEEP 800

[init:gfx]
    SCREEN 0, SCREEN_W#, SCREEN_H#, "Voxel Terrain"
    lastT$    = TICKS
    fpsTimer$ = lastT$

[main]
    WHILE INKEY <> KEY_ESC#
        GOSUB [sub:updateTiming]
        GOSUB [sub:updateCamera]

        SCREENLOCK ON
        LINE (0, 0)-(SCREEN_W#, horizon$ - 30), SKY_TOP#, BF
        LINE (0, horizon$ - 30)-(SCREEN_W#, horizon$), SKY_BOT#, BF
        LINE (0, horizon$)-(SCREEN_W#, SCREEN_H#), GROUND#, BF

        renderStart$ = TICKS
        GOSUB [sub:renderVoxel]
        renderSum$ += TICKS - renderStart$

        GOSUB [sub:drawHUD]
        SCREENLOCK OFF              ' VSync paces the loop — no SLEEP needed

        GOSUB [sub:updateFps]
    WEND
END

' -----------------------------------------------
' Procedural heightmap + colormap (runs once)
' -----------------------------------------------
[sub:generateTerrain]
    ' 1) Random heights
    FOR idx$ = 0 TO MAP_SIZE# * MAP_SIZE# - 1
        heightmap$(idx$) = RND(90) + 5
    NEXT

    ' 2) Smoothing passes, in place, wrapping at the edges
    FOR pass$ = 1 TO 8
        FOR gy$ = 0 TO MAP_SIZE# - 1
            row$ = gy$ * MAP_SIZE#
            gy0$ = MOD(gy$ - 1 + MAP_SIZE#, MAP_SIZE#) * MAP_SIZE#
            gy1$ = MOD(gy$ + 1, MAP_SIZE#) * MAP_SIZE#
            FOR gx$ = 0 TO MAP_SIZE# - 1
                gx0$ = MOD(gx$ - 1 + MAP_SIZE#, MAP_SIZE#)
                gx1$ = MOD(gx$ + 1, MAP_SIZE#)
                idx$ = row$ + gx$
                avg$ = (heightmap$(row$ + gx0$) + heightmap$(row$ + gx1$) +
                        heightmap$(gy0$ + gx$) + heightmap$(gy1$ + gx$) +
                        heightmap$(idx$) * 2) / 6
                heightmap$(idx$) = avg$
            NEXT
        NEXT
    NEXT

    ' 3) Colors by height band + pre-scaled projection heights
    FOR idx$ = 0 TO MAP_SIZE# * MAP_SIZE# - 1
        h$ = heightmap$(idx$)
        heightProj$(idx$) = h$ * SCALE#

        IF h$ < 22 THEN
            colormap$(idx$) = RGB(20, 50, 160)              ' deep water
        ELSEIF h$ < 28 THEN
            colormap$(idx$) = RGB(40, 80, 200)              ' shallow water
        ELSEIF h$ < 34 THEN
            colormap$(idx$) = RGB(220, 200, 130)            ' sand / beach
        ELSEIF h$ < 58 THEN
            gv$ = 100 + INT((h$ - 34) * 1.5)
            colormap$(idx$) = RGB(35, gv$, 30)              ' low grassland
        ELSEIF h$ < 75 THEN
            colormap$(idx$) = RGB(25, 90, 20)               ' forest
        ELSEIF h$ < 88 THEN
            rv$ = 75 + INT((h$ - 75) * 2)
            colormap$(idx$) = RGB(rv$, rv$ - 10, rv$ - 15)  ' rock
        ELSE
            sv$ = MIN(220 + INT((h$ - 88) * 1.5), 255)
            colormap$(idx$) = RGB(sv$, sv$, sv$)            ' snow
        END IF
    NEXT
RETURN

' -----------------------------------------------
' Delta time: makes movement independent of FPS
' -----------------------------------------------
[sub:updateTiming]
    nowT$       = TICKS
    delta$      = MIN(nowT$ - lastT$, MAX_DELTA#)
    lastT$      = nowT$
    frameScale$ = delta$ / FRAME_MS#
RETURN

' -----------------------------------------------
' Input -> camera state
' -----------------------------------------------
[sub:updateCamera]
    IF KEYDOWN(KEY_LEFT#)  THEN camAngle$ -= rotSpeed$ * frameScale$
    IF KEYDOWN(KEY_RIGHT#) THEN camAngle$ += rotSpeed$ * frameScale$
    IF camAngle$ < 0    THEN camAngle$ += 360
    IF camAngle$ >= 360 THEN camAngle$ -= 360

    ' Full-precision trig: only two calls per frame, so FastTrig is not needed
    dirX$ = COS(RAD(camAngle$))
    dirY$ = SIN(RAD(camAngle$))

    IF KEYDOWN(KEY_UP#) THEN
        camX$ += dirX$ * moveSpeed$ * frameScale$
        camY$ += dirY$ * moveSpeed$ * frameScale$
    END IF
    IF KEYDOWN(KEY_DOWN#) THEN
        camX$ -= dirX$ * moveSpeed$ * frameScale$
        camY$ -= dirY$ * moveSpeed$ * frameScale$
    END IF

    ' The world wraps; keeping the camera in [0, MAP_SIZE#) lets
    ' the renderer use one MOD per axis instead of two (see WRAP_OFFSET#)
    IF camX$ < 0         THEN camX$ += MAP_SIZE#
    IF camX$ >= MAP_SIZE# THEN camX$ -= MAP_SIZE#
    IF camY$ < 0         THEN camY$ += MAP_SIZE#
    IF camY$ >= MAP_SIZE# THEN camY$ -= MAP_SIZE#

    IF KEYDOWN(KEY_PGUP#) THEN camH$ += liftSpeed$ * frameScale$
    IF KEYDOWN(KEY_PGDN#) THEN camH$ -= liftSpeed$ * frameScale$
    IF KEYDOWN(KEY_W#)    THEN horizon$ -= tiltSpeed$ * frameScale$
    IF KEYDOWN(KEY_S#)    THEN horizon$ += tiltSpeed$ * frameScale$

    horizon$ = CLAMP(horizon$, 80, 350)
    camH$    = MAX(camH$, 30)
RETURN

' -----------------------------------------------
' Voxel Space renderer — one ray per column strip
' -----------------------------------------------
[sub:renderVoxel]
    camHS$ = camH$ * SCALE#             ' pairs with pre-scaled heightProj$
    baseX$ = camX$ + WRAP_OFFSET#
    baseY$ = camY$ + WRAP_OFFSET#

    ' Camera plane = perpendicular of dir: (-dirY, dirX) * PLANE_LEN#
    ' First ray = dir - plane (left edge), shifted to the centre of its column strip
    colDX$ = -dirY$ * PLANE_LEN# * COL_FRAC#
    colDY$ =  dirX$ * PLANE_LEN# * COL_FRAC#
    rdx$   = dirX$ + dirY$ * PLANE_LEN# + colDX$ / 2
    rdy$   = dirY$ - dirX$ * PLANE_LEN# + colDY$ / 2

    FOR sc$ = 0 TO SCREEN_W# - 1 STEP COL_STEP#
        maxY$ = SCREEN_H#
        z$    = 1
        dz$   = 1
        wx$   = baseX$ + rdx$
        wy$   = baseY$ + rdy$

        WHILE z$ <= MAX_DIST# AND maxY$ > 0
            cell$  = MOD(INT(wy$), MAP_SIZE#) * MAP_SIZE# + MOD(INT(wx$), MAP_SIZE#)
            projY$ = INT((camHS$ - heightProj$(cell$)) / z$ + horizon$)

            IF projY$ < maxY$ THEN
                LINE (sc$, projY$)-(sc$ + COL_STEP# - 1, maxY$ - 1), colormap$(cell$), BF
                maxY$ = projY$
            END IF

            ' Coarser sampling with distance: far terrain needs less detail
            dz$ += DZ_GROW#
            z$  += dz$
            wx$ += rdx$ * dz$
            wy$ += rdy$ * dz$
        WEND

        rdx$ += colDX$
        rdy$ += colDY$
    NEXT
RETURN

' -----------------------------------------------
' FPS + average render time, refreshed once a second
' -----------------------------------------------
[sub:updateFps]
    frames$ += 1
    IF nowT$ - fpsTimer$ >= 1000 THEN
        fps$       = ROUND(frames$ * 1000 / (nowT$ - fpsTimer$))
        renderMs$  = ROUND(renderSum$ / frames$ * 10) / 10
        frames$    = 0
        renderSum$ = 0
        fpsTimer$  = nowT$
    END IF
RETURN

' -----------------------------------------------
' HUD overlay — graphics text, not console PRINT
' -----------------------------------------------
[sub:drawHUD]
    angleI$   = INT(camAngle$)
    heightI$  = INT(camH$)
    horizonI$ = INT(horizon$)
    statusText$ = FSTRING("FPS: {{-fps$-}}   Render: {{-renderMs$-}} ms   Angle: {{-angleI$-}}   Height: {{-heightI$-}}   Horizon: {{-horizonI$-}}")

    LINE (0, 0)-(SCREEN_W# - 1, 41), HUD_BG#, BF
    DRAWSTRING HUD_HELP#, 6, 3, HUD_TEXT#
    DRAWSTRING statusText$, 6, 22, HUD_FPS#
RETURN