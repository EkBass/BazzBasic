REM ============================================
REM 3D RAYCASTER - Optimized Version
REM BazzBasic version: https://ekbass.github.io/BazzBasic/
REM ============================================
REM
REM OPTIMIZATION NOTES:
REM - All constants initialized once at program start
REM - Pre-calculated values (FOV/2, slice width, etc.)
REM - FastTrig lookup tables for 20x faster sin/cos
REM - Array-based map for fast collision detection
REM ============================================

REM ============================================
REM CONSTANTS - Initialized Once
REM ============================================

REM [Main + sub:RenderView + sub:DrawMinimap]
LET SCREEN_W# = 640
LET SCREEN_H# = 480
LET HALF_H# = 240

REM [sub:RenderView]
LET FOV# = 60                    ' Field of view in degrees
LET HALF_FOV# = 30               ' Pre-calculated FOV / 2
LET NUM_RAYS# = 180              ' Number of rays to cast
LET STEP_SIZE# = 0.05            ' Ray step size
LET MAX_STEPS# = 512             ' Maximum ray steps
LET WALL_SCALE# = 0.6            ' Wall height multiplier
LET MIN_BRIGHTNESS# = 20         ' Minimum wall brightness
LET BRIGHTNESS_FACTOR# = 25      ' Distance-to-darkness factor

REM [Main loop - movement]
LET MOVE_SPEED# = 0.1            ' Player movement speed
LET ROT_SPEED# = 5               ' Rotation speed in degrees

REM [sub:RenderView - pre-calculated]
LET SLICE_WIDTH# = SCREEN_W# / NUM_RAYS#  ' Width of each wall slice

REM [sub:DrawMinimap]
LET MAP_SCALE# = 6               ' Minimap tile size
LET MAP_OFFSET_X# = 10           ' Minimap X position
LET MAP_OFFSET_Y# = 10           ' Minimap Y position
LET MAP_BORDER# = 2              ' Minimap border size
LET PLAYER_DOT_SIZE# = 3         ' Player indicator size
LET PLAYER_DIR_LEN# = 8          ' Player direction arrow length

REM [sub:RenderView - colors (RGB pre-calculated if needed)]
LET SKY_R# = 50
LET SKY_G# = 50
LET SKY_B# = 100
LET FLOOR_R# = 40
LET FLOOR_G# = 40
LET FLOOR_B# = 40

REM [sub:DrawMinimap - colors]
LET MINIMAP_BG_COLOR# = RGB(0, 0, 0)
LET MINIMAP_WALL_COLOR# = RGB(150, 150, 150)
LET PLAYER_COLOR# = RGB(255, 255, 0)

REM [FPS counter]
LET FPS_UPDATE_INTERVAL# = 1000  ' Update FPS every 1000ms

REM ============================================
REM MAP DATA
REM ============================================
DIM m$
DIM map$
GOSUB [sub:readMap]

LET MAP_H# = 21
LET MAP_W# = 31

REM ============================================
REM PLAYER STATE (Mutable Variables)
REM ============================================
LET px$ = 3.5                    ' Player X position
LET py$ = 3.5                    ' Player Y position
LET pAngle$ = 0                  ' Player angle in degrees (0-359)

REM ============================================
REM WORKING VARIABLES (Re-used per frame)
REM ============================================
REM [Main loop]
LET key$ = 0
LET nx$ = 0
LET ny$ = 0

REM [sub:RenderView]
LET ray$ = 0
LET rayRatio$ = 0
LET rayAngle$ = 0
LET dx$ = 0
LET dy$ = 0
LET rx$ = 0
LET ry$ = 0
LET hit$ = 0
LET distance$ = 0
LET steps$ = 0
LET cx$ = 0
LET cy$ = 0
LET angleDiff$ = 0
LET correctedDist$ = 0
LET wallHeight$ = 0
LET wallTop$ = 0
LET wallBottom$ = 0
LET brightness$ = 0
LET screenX$ = 0
LET screenX2$ = 0
LET wallColor$ = 0

REM [sub:DrawMinimap]
LET my$ = 0
LET mx$ = 0
LET sx$ = 0
LET sy$ = 0
LET plrX$ = 0
LET plrY$ = 0
LET dirX$ = 0
LET dirY$ = 0

REM [FPS counter]
LET frameCount$ = 0
LET lastFpsUpdate$ = 0
LET currentTime$ = 0
LET fps$ = 0

REM ============================================
REM INITIALIZATION
REM ============================================

REM Pre-process: convert string map to integer array
GOSUB [sub:convertMapToArray]

REM Initialize graphics
SCREEN 12
VSYNC(FALSE)
CLS

REM CRITICAL: Enable FastTrig for massive performance boost!
FastTrig(TRUE)

REM Initialize FPS counter
lastFpsUpdate$ = TICKS

REM ============================================
REM MAIN LOOP
REM ============================================
LET running$ = TRUE
WHILE running$
    key$ = INKEY
    
    REM Movement with collision detection
    IF key$ = KEY_UP# THEN
        nx$ = px$ + FastCos(pAngle$) * MOVE_SPEED#
        ny$ = py$ + FastSin(pAngle$) * MOVE_SPEED#
        IF map$(INT(ny$), INT(nx$)) = 0 THEN
            px$ = nx$
            py$ = ny$
        ENDIF
    ENDIF
    
    IF key$ = KEY_DOWN# THEN
        nx$ = px$ - FastCos(pAngle$) * MOVE_SPEED#
        ny$ = py$ - FastSin(pAngle$) * MOVE_SPEED#
        IF map$(INT(ny$), INT(nx$)) = 0 THEN
            px$ = nx$
            py$ = ny$
        ENDIF
    ENDIF
    
    IF key$ = KEY_LEFT# THEN
        pAngle$ = pAngle$ - ROT_SPEED#
        IF pAngle$ < 0 THEN pAngle$ = pAngle$ + 360
    ENDIF
    
    IF key$ = KEY_RIGHT# THEN
        pAngle$ = pAngle$ + ROT_SPEED#
        IF pAngle$ >= 360 THEN pAngle$ = pAngle$ - 360
    ENDIF
    
    IF key$ = KEY_ESC# THEN running$ = FALSE
    
    REM ===== RENDERING =====
    SCREENLOCK ON
    
    REM Draw sky (top half)
    LINE (0, 0)-(SCREEN_W#, HALF_H#), RGB(SKY_R#, SKY_G#, SKY_B#), BF
    
    REM Draw floor (bottom half)
    LINE (0, HALF_H#)-(SCREEN_W#, SCREEN_H#), RGB(FLOOR_R#, FLOOR_G#, FLOOR_B#), BF
    
    GOSUB [sub:RenderView]
    GOSUB [sub:DrawMinimap]
    
    REM FPS Counter
    frameCount$ = frameCount$ + 1
    currentTime$ = TICKS
    IF currentTime$ - lastFpsUpdate$ >= FPS_UPDATE_INTERVAL# THEN
        fps$ = frameCount$ / ((currentTime$ - lastFpsUpdate$) / 1000)
        frameCount$ = 0
        lastFpsUpdate$ = currentTime$
    ENDIF
    
    REM Display FPS
    COLOR 15, 0
    LOCATE 1, 1
    PRINT "FPS: "; INT(fps$); "  "
    
    SCREENLOCK OFF
    SLEEP 1
WEND

REM Cleanup
FastTrig(FALSE)
COLOR 7, 0
CLS
END

REM ============================================
REM SUBROUTINES
REM ============================================

REM -----------------------------------------------
REM Convert map: 0 = empty floor, 1 = wall
REM -----------------------------------------------
[sub:convertMapToArray]
    FOR cy$ = 0 TO MAP_H# - 1
        FOR cx$ = 0 TO MAP_W# - 1
            IF MID(m$(cy$), cx$ + 1, 1) = "#" THEN
                map$(cy$, cx$) = 1
            ELSE
                map$(cy$, cx$) = 0
            ENDIF
        NEXT
    NEXT
RETURN

REM -----------------------------------------------
REM Render 3D view using FastTrig
REM -----------------------------------------------
[sub:RenderView]
    FOR ray$ = 0 TO NUM_RAYS# - 1
        rayRatio$ = ray$ / NUM_RAYS#
        
        REM Calculate ray angle (using pre-calculated HALF_FOV#)
        rayAngle$ = pAngle$ - HALF_FOV# + (rayRatio$ * FOV#)
        
        REM Normalize ray angle to 0-359
        IF rayAngle$ < 0 THEN rayAngle$ = rayAngle$ + 360
        IF rayAngle$ >= 360 THEN rayAngle$ = rayAngle$ - 360
        
        REM Ray direction using FastTrig
        dx$ = FastCos(rayAngle$) * STEP_SIZE#
        dy$ = FastSin(rayAngle$) * STEP_SIZE#
        rx$ = px$
        ry$ = py$
        hit$ = 0
        distance$ = 0
        steps$ = 0
        
        REM Ray marching loop
        WHILE hit$ = 0 AND steps$ < MAX_STEPS#
            rx$ = rx$ + dx$
            ry$ = ry$ + dy$
            steps$ = steps$ + 1
            distance$ = distance$ + STEP_SIZE#
            
            cx$ = INT(rx$)
            cy$ = INT(ry$)
            
            IF cx$ >= 0 AND cx$ < MAP_W# AND cy$ >= 0 AND cy$ < MAP_H# THEN
                IF map$(cy$, cx$) = 1 THEN
                    hit$ = 1
                ENDIF
            ELSE
                hit$ = 1
            ENDIF
        WEND
        
        IF hit$ = 1 THEN
            REM Fish-eye correction
            angleDiff$ = rayAngle$ - pAngle$
            IF angleDiff$ > 180 THEN angleDiff$ = angleDiff$ - 360
            IF angleDiff$ < -180 THEN angleDiff$ = angleDiff$ + 360
            
            correctedDist$ = distance$ * FastCos(angleDiff$)
            
            REM Calculate wall height (using pre-calculated WALL_SCALE#)
            wallHeight$ = (HALF_H# / correctedDist$) * WALL_SCALE#
            IF wallHeight$ > SCREEN_H# THEN wallHeight$ = SCREEN_H#
            
            wallTop$ = HALF_H# - wallHeight$
            wallBottom$ = HALF_H# + wallHeight$
            
            REM Calculate brightness (using pre-calculated constants)
            brightness$ = 255 - (correctedDist$ * BRIGHTNESS_FACTOR#)
            IF brightness$ < MIN_BRIGHTNESS# THEN brightness$ = MIN_BRIGHTNESS#
            IF brightness$ > 255 THEN brightness$ = 255
            
            REM Draw wall slice
            screenX$ = INT(rayRatio$ * SCREEN_W#)
            screenX2$ = INT((ray$ + 1) / NUM_RAYS# * SCREEN_W#)
            wallColor$ = RGB(brightness$, brightness$ * 0.8, brightness$ * 0.6)
            
            LINE (screenX$, wallTop$)-(screenX2$, wallBottom$), wallColor$, BF
        ENDIF
    NEXT
RETURN

REM -----------------------------------------------
REM Draw mini-map with player position
REM -----------------------------------------------
[sub:DrawMinimap]
    REM Draw map background (using pre-calculated constants)
    LINE (MAP_OFFSET_X# - MAP_BORDER#, MAP_OFFSET_Y# - MAP_BORDER#)-(MAP_OFFSET_X# + MAP_W# * MAP_SCALE# + MAP_BORDER#, MAP_OFFSET_Y# + MAP_H# * MAP_SCALE# + MAP_BORDER#), MINIMAP_BG_COLOR#, BF
    
    REM Draw walls
    FOR my$ = 0 TO MAP_H# - 1
        FOR mx$ = 0 TO MAP_W# - 1
            IF map$(my$, mx$) = 1 THEN
                sx$ = MAP_OFFSET_X# + mx$ * MAP_SCALE#
                sy$ = MAP_OFFSET_Y# + my$ * MAP_SCALE#
                LINE (sx$, sy$)-(sx$ + MAP_SCALE# - 1, sy$ + MAP_SCALE# - 1), MINIMAP_WALL_COLOR#, BF
            ENDIF
        NEXT
    NEXT
    
    REM Draw player position (using pre-calculated constants)
    plrX$ = MAP_OFFSET_X# + INT(px$ * MAP_SCALE#)
    plrY$ = MAP_OFFSET_Y# + INT(py$ * MAP_SCALE#)
    CIRCLE (plrX$, plrY$), PLAYER_DOT_SIZE#, PLAYER_COLOR#, 1
    
    REM Draw player direction
    dirX$ = plrX$ + INT(FastCos(pAngle$) * PLAYER_DIR_LEN#)
    dirY$ = plrY$ + INT(FastSin(pAngle$) * PLAYER_DIR_LEN#)
    LINE (plrX$, plrY$)-(dirX$, dirY$), PLAYER_COLOR#
RETURN

REM -----------------------------------------------
REM Read map into string array
REM -----------------------------------------------
[sub:readMap]
    m$(0)   = "###############################"
    m$(1)   = "#...........#..#........#.....#"
    m$(2)   = "####..#..####..#######..#..#..#"
    m$(3)   = "#.....#........#...........#..#"
    m$(4)   = "#######..#..#..#..####..#######"
    m$(5)   = "#........#..#.....#..#........#"
    m$(6)   = "#######..#..####..#..####..####"
    m$(7)   = "#.....#..#..#.....#.....#.....#"
    m$(8)   = "####..##########..#..#######..#"
    m$(9)   = "#...........#.....#..#..#..#..#"
    m$(10)  = "####..####..#..####..#..#..#..#"
    m$(11)  = "#.....#.....#..............#..#"
    m$(12)  = "#..#######..#..#..##########..#"
    m$(13)  = "#.....#.....#..#........#..#..#"
    m$(14)  = "#######..##########..####..#..#"
    m$(15)  = "#...........#.....#..#..#.....#"
    m$(16)  = "#..##########..#######..####..#"
    m$(17)  = "#..............#..............#"
    m$(18)  = "##########..#..####..####..#..#"
    m$(19)  = "#...........#...........#..#..#"
    m$(20)  = "###############################"
RETURN