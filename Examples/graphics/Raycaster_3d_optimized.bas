' ==========================================
' raycaster_3d.bas — BazzBasic
' Classic Wolf3D-style renderer.
' FastTrig lookup tables for fast sin/cos.
' https://ekbass.github.io/BazzBasic/
' ==========================================
' Controls:
'   Arrow keys  = Move / Rotate
'   ESC         = Quit
' ==========================================

[inits]
    ' Screen
    LET SCREEN_W# = 640
    LET SCREEN_H# = 480
    LET HALF_H#   = 240

    ' Raycaster
    LET FOV#               = 60
    LET HALF_FOV#          = 30
    LET NUM_RAYS#          = 180
    LET STEP_SIZE#         = 0.05
    LET MAX_STEPS#         = 512
    LET WALL_SCALE#        = 0.6
    LET MIN_BRIGHTNESS#    = 20
    LET BRIGHTNESS_FACTOR# = 25
    LET SLICE_WIDTH#       = SCREEN_W# / NUM_RAYS#

    ' Movement
    LET MOVE_SPEED# = 0.1
    LET ROT_SPEED#  = 5

    ' Sky / floor colors (pre-calculated RGB)
    LET SKY_COLOR#   = RGB(50, 50, 100)
    LET FLOOR_COLOR# = RGB(40, 40, 40)

    ' Minimap
    LET MAP_SCALE#       = 6
    LET MAP_OFFSET_X#    = 10
    LET MAP_OFFSET_Y#    = 10
    LET MAP_BORDER#      = 2
    LET PLAYER_DOT_SIZE# = 3
    LET PLAYER_DIR_LEN#  = 8
    LET MINIMAP_BG#      = RGB(0,   0,   0)
    LET MINIMAP_WALL#    = RGB(150, 150, 150)
    LET PLAYER_COLOR#    = RGB(255, 255, 0)

    ' FPS counter
    LET FPS_INTERVAL# = 1000

    ' Console palette
    LET LGRAY# = 7
    LET WHITE# = 15

    ' Map dimensions
    LET MAP_H# = 21
    LET MAP_W# = 31

    DIM m$
    DIM map$

    ' Player state
    LET px$     = 3.5
    LET py$     = 3.5
    LET pAngle$ = 0

    ' Working variables — main loop
    LET nx$, ny$

    ' Working variables — RenderView
    LET ray$, rayRatio$, rayAngle$
    LET dx$, dy$, rx$, ry$
    LET hit$, distance$, steps$, cx$, cy$
    LET angleDiff$, correctedDist$
    LET wallHeight$, wallTop$, wallBottom$
    LET brightness$, screenX$, screenX2$, wallColor$

    ' Working variables — DrawMinimap
    LET my$, mx$, sx$, sy$
    LET plrX$, plrY$, dirX$, dirY$

    ' FPS counter
    LET frameCount$    = 0
    LET lastFpsUpdate$ = 0
    LET currentTime$   = 0
    LET fps$           = 0

    LET running$ = TRUE

[init:map]
    GOSUB [sub:readMap]
    GOSUB [sub:convertMapToArray]

[init:gfx]
    SCREEN 0, SCREEN_W#, SCREEN_H#, "3D Raycaster"
    VSYNC(FALSE)
    CLS
    FastTrig(TRUE)
    lastFpsUpdate$ = TICKS

[main]
    WHILE running$

        ' --- Input ---
        ' ESC via INKEY; movement via KEYDOWN for smooth hold-to-move
        IF INKEY = KEY_ESC# THEN running$ = FALSE

        IF KEYDOWN(KEY_UP#) THEN
            nx$ = px$ + FastCos(pAngle$) * MOVE_SPEED#
            ny$ = py$ + FastSin(pAngle$) * MOVE_SPEED#
            IF map$(INT(ny$), INT(nx$)) = 0 THEN
                px$ = nx$
                py$ = ny$
            END IF
        END IF

        IF KEYDOWN(KEY_DOWN#) THEN
            nx$ = px$ - FastCos(pAngle$) * MOVE_SPEED#
            ny$ = py$ - FastSin(pAngle$) * MOVE_SPEED#
            IF map$(INT(ny$), INT(nx$)) = 0 THEN
                px$ = nx$
                py$ = ny$
            END IF
        END IF

        IF KEYDOWN(KEY_LEFT#) THEN
            pAngle$ = pAngle$ - ROT_SPEED#
            IF pAngle$ < 0 THEN pAngle$ = pAngle$ + 360
        END IF

        IF KEYDOWN(KEY_RIGHT#) THEN
            pAngle$ = pAngle$ + ROT_SPEED#
            IF pAngle$ >= 360 THEN pAngle$ = pAngle$ - 360
        END IF

        ' --- Render ---
        SCREENLOCK ON

        LINE (0, 0)-(SCREEN_W#, HALF_H#),         SKY_COLOR#,   BF
        LINE (0, HALF_H#)-(SCREEN_W#, SCREEN_H#),  FLOOR_COLOR#, BF

        GOSUB [sub:RenderView]
        GOSUB [sub:DrawMinimap]

        ' FPS counter
        frameCount$  = frameCount$ + 1
        currentTime$ = TICKS
        IF currentTime$ - lastFpsUpdate$ >= FPS_INTERVAL# THEN
            fps$           = frameCount$ / ((currentTime$ - lastFpsUpdate$) / 1000)
            frameCount$    = 0
            lastFpsUpdate$ = currentTime$
        END IF

        COLOR WHITE#, 0
        LOCATE 1, 1
        PRINT "FPS: "; INT(fps$); "  "

        SCREENLOCK OFF
        SLEEP 1

    WEND

    FastTrig(FALSE)
    COLOR LGRAY#, 0
    CLS
END

' -----------------------------------------------
' Convert string map to numeric array
' 0 = floor, 1 = wall
' -----------------------------------------------
[sub:convertMapToArray]
    FOR cy$ = 0 TO MAP_H# - 1
        FOR cx$ = 0 TO MAP_W# - 1
            IF MID(m$(cy$), cx$ + 1, 1) = "#" THEN
                map$(cy$, cx$) = 1
            ELSE
                map$(cy$, cx$) = 0
            END IF
        NEXT
    NEXT
RETURN

' -----------------------------------------------
' Render 3D view — one vertical slice per ray
' -----------------------------------------------
[sub:RenderView]
    FOR ray$ = 0 TO NUM_RAYS# - 1
        rayRatio$ = ray$ / NUM_RAYS#
        rayAngle$ = pAngle$ - HALF_FOV# + (rayRatio$ * FOV#)

        IF rayAngle$ < 0    THEN rayAngle$ = rayAngle$ + 360
        IF rayAngle$ >= 360 THEN rayAngle$ = rayAngle$ - 360

        dx$       = FastCos(rayAngle$) * STEP_SIZE#
        dy$       = FastSin(rayAngle$) * STEP_SIZE#
        rx$       = px$
        ry$       = py$
        hit$      = 0
        distance$ = 0
        steps$    = 0

        WHILE hit$ = 0 AND steps$ < MAX_STEPS#
            rx$       = rx$ + dx$
            ry$       = ry$ + dy$
            steps$    = steps$ + 1
            distance$ = distance$ + STEP_SIZE#

            cx$ = INT(rx$)
            cy$ = INT(ry$)

            IF cx$ >= 0 AND cx$ < MAP_W# AND cy$ >= 0 AND cy$ < MAP_H# THEN
                IF map$(cy$, cx$) = 1 THEN hit$ = 1
            ELSE
                hit$ = 1
            END IF
        WEND

        IF hit$ = 1 THEN
            ' Fish-eye correction
            angleDiff$ = rayAngle$ - pAngle$
            IF angleDiff$ >  180 THEN angleDiff$ = angleDiff$ - 360
            IF angleDiff$ < -180 THEN angleDiff$ = angleDiff$ + 360

            correctedDist$ = distance$ * FastCos(angleDiff$)

            wallHeight$ = (HALF_H# / correctedDist$) * WALL_SCALE#
            IF wallHeight$ > SCREEN_H# THEN wallHeight$ = SCREEN_H#

            wallTop$    = HALF_H# - wallHeight$
            wallBottom$ = HALF_H# + wallHeight$

            brightness$ = CLAMP(255 - (correctedDist$ * BRIGHTNESS_FACTOR#), MIN_BRIGHTNESS#, 255)

            screenX$   = INT(rayRatio$ * SCREEN_W#)
            screenX2$  = INT((ray$ + 1) / NUM_RAYS# * SCREEN_W#)
            wallColor$ = RGB(brightness$, brightness$ * 0.8, brightness$ * 0.6)

            LINE (screenX$, wallTop$)-(screenX2$, wallBottom$), wallColor$, BF
        END IF
    NEXT
RETURN

' -----------------------------------------------
' Draw minimap with player position + direction
' -----------------------------------------------
[sub:DrawMinimap]
    LINE (MAP_OFFSET_X# - MAP_BORDER#, MAP_OFFSET_Y# - MAP_BORDER#)-(MAP_OFFSET_X# + MAP_W# * MAP_SCALE# + MAP_BORDER#, MAP_OFFSET_Y# + MAP_H# * MAP_SCALE# + MAP_BORDER#), MINIMAP_BG#, BF

    FOR my$ = 0 TO MAP_H# - 1
        FOR mx$ = 0 TO MAP_W# - 1
            IF map$(my$, mx$) = 1 THEN
                sx$ = MAP_OFFSET_X# + mx$ * MAP_SCALE#
                sy$ = MAP_OFFSET_Y# + my$ * MAP_SCALE#
                LINE (sx$, sy$)-(sx$ + MAP_SCALE# - 1, sy$ + MAP_SCALE# - 1), MINIMAP_WALL#, BF
            END IF
        NEXT
    NEXT

    plrX$ = MAP_OFFSET_X# + INT(px$ * MAP_SCALE#)
    plrY$ = MAP_OFFSET_Y# + INT(py$ * MAP_SCALE#)
    CIRCLE (plrX$, plrY$), PLAYER_DOT_SIZE#, PLAYER_COLOR#, 1

    dirX$ = plrX$ + INT(FastCos(pAngle$) * PLAYER_DIR_LEN#)
    dirY$ = plrY$ + INT(FastSin(pAngle$) * PLAYER_DIR_LEN#)
    LINE (plrX$, plrY$)-(dirX$, dirY$), PLAYER_COLOR#
RETURN

' -----------------------------------------------
' Load map into string array
' -----------------------------------------------
[sub:readMap]
    m$(0)  = "###############################"
    m$(1)  = "#...........#..#........#.....#"
    m$(2)  = "####..#..####..#######..#..#..#"
    m$(3)  = "#.....#........#...........#..#"
    m$(4)  = "#######..#..#..#..####..#######"
    m$(5)  = "#........#..#.....#..#........#"
    m$(6)  = "#######..#..####..#..####..####"
    m$(7)  = "#.....#..#..#.....#.....#.....#"
    m$(8)  = "####..##########..#..#######..#"
    m$(9)  = "#...........#.....#..#..#..#..#"
    m$(10) = "####..####..#..####..#..#..#..#"
    m$(11) = "#.....#.....#..............#..#"
    m$(12) = "#..#######..#..#..##########..#"
    m$(13) = "#.....#.....#..#........#..#..#"
    m$(14) = "#######..##########..####..#..#"
    m$(15) = "#...........#.....#..#..#.....#"
    m$(16) = "#..##########..#######..####..#"
    m$(17) = "#..............#..............#"
    m$(18) = "##########..#..####..####..#..#"
    m$(19) = "#...........#...........#..#..#"
    m$(20) = "###############################"
RETURN
