REM ============================================
REM 3D RAYCASTER - Optimized with FastTrig
REM BazzBasic version: https://ekbass.github.io/BazzBasic/
REM ============================================
REM
REM OPTIMIZATION NOTES:
REM - Uses PI and HPI constants instead of hardcoded values
REM - Uses FastTrig lookup tables for 20x faster sin/cos
REM - All angles in degrees for maximum FastTrig performance
REM - FOV using RAD() for clarity
REM ============================================

REM Screen and rendering constants
LET SCREEN_W# = 640
LET SCREEN_H# = 480
LET HALF_H# = 240

REM View settings (now in degrees for FastTrig!)
LET FOV# = 60              ' Field of view in degrees
LET NUM_RAYS# = 180        ' Number of rays to cast
LET STEP_SIZE# = 0.05      ' Ray step size
LET MAX_STEPS# = 512       ' Maximum ray steps

REM Map definition
DIM m$
DIM map$  ' Optimized map with integers
GOSUB [sub:readMap]

LET MAP_H# = 21
LET MAP_W# = 31

REM Player position and angle (angle in degrees!)
LET px$ = 3.5
LET py$ = 3.5
LET pAngle$ = 0            ' Player angle in degrees (0-359)

REM Pre-process: convert string map to integer array
GOSUB [sub:convertMapToArray]

REM Initialize graphics
SCREEN 12
CLS

REM CRITICAL: Enable FastTrig for massive performance boost!
FastTrig(TRUE)

REM === Main Loop ===
LET running$ = TRUE
WHILE running$
    LET key$ = INKEY
    
    LET moveSpeed$ = 0.1
    LET rotSpeed$ = 5      ' Rotation in degrees (was radians)
    
    IF key$ = KEY_UP# THEN
        REM Use FastCos/FastSin for movement (much faster!)
        LET nx$ = px$ + FastCos(pAngle$) * moveSpeed$
        LET ny$ = py$ + FastSin(pAngle$) * moveSpeed$
        IF map$(INT(ny$), INT(nx$)) = 0 THEN
            px$ = nx$
            py$ = ny$
        ENDIF
    ENDIF
    
    IF key$ = KEY_DOWN# THEN
        LET nx$ = px$ - FastCos(pAngle$) * moveSpeed$
        LET ny$ = py$ - FastSin(pAngle$) * moveSpeed$
        IF map$(INT(ny$), INT(nx$)) = 0 THEN
            px$ = nx$
            py$ = ny$
        ENDIF
    ENDIF
    
    IF key$ = KEY_LEFT# THEN
        pAngle$ = pAngle$ - rotSpeed$
        REM Normalize angle to 0-359 degrees
        IF pAngle$ < 0 THEN pAngle$ = pAngle$ + 360
    ENDIF
    
    IF key$ = KEY_RIGHT# THEN
        pAngle$ = pAngle$ + rotSpeed$
        REM Normalize angle to 0-359 degrees
        IF pAngle$ >= 360 THEN pAngle$ = pAngle$ - 360
    ENDIF
    
    IF key$ = KEY_ESC# THEN running$ = FALSE
    
    SCREENLOCK ON
    
    REM Draw sky (top half)
    LINE (0,0)-(SCREEN_W#, HALF_H#), RGB(50, 50, 100), BF
    REM Draw floor (bottom half)
    LINE (0,HALF_H#)-(SCREEN_W#, SCREEN_H#), RGB(40, 40, 40), BF
    
    GOSUB [sub:RenderView]
    GOSUB [sub:DrawMinimap]
    
    SCREENLOCK OFF
    SLEEP 16
WEND

REM Cleanup: Disable FastTrig and free memory
FastTrig(FALSE)
COLOR 7, 0
CLS
END

REM -----------------------------------------------
REM Convert map: 0 = empty floor, 1 = wall
REM -----------------------------------------------
[sub:convertMapToArray]
    FOR y$ = 0 TO MAP_H# - 1
        FOR x$ = 0 TO MAP_W# - 1
            IF MID(m$(y$), x$ + 1, 1) = "#" THEN
                map$(y$, x$) = 1
            ELSE
                map$(y$, x$) = 0
            ENDIF
        NEXT
    NEXT
RETURN

REM -----------------------------------------------
REM Render 3D view using FastTrig for speed
REM -----------------------------------------------
[sub:RenderView]
    LET sliceWidth$ = SCREEN_W# / NUM_RAYS#
    
    FOR ray$ = 0 TO NUM_RAYS# - 1
        LET rayRatio$ = ray$ / NUM_RAYS#
        REM Calculate ray angle in degrees
        LET rayAngle$ = pAngle$ - (FOV# / 2) + (rayRatio$ * FOV#)
        
        REM Normalize ray angle to 0-359
        IF rayAngle$ < 0 THEN rayAngle$ = rayAngle$ + 360
        IF rayAngle$ >= 360 THEN rayAngle$ = rayAngle$ - 360
        
        REM Use FastCos/FastSin for ray direction (20x faster!)
        LET dx$ = FastCos(rayAngle$) * STEP_SIZE#
        LET dy$ = FastSin(rayAngle$) * STEP_SIZE#
        LET rx$ = px$
        LET ry$ = py$
        LET hit$ = 0
        LET distance$ = 0
        LET steps$ = 0
        
        REM Ray marching loop
        WHILE hit$ = 0 AND steps$ < MAX_STEPS#
            rx$ = rx$ + dx$
            ry$ = ry$ + dy$
            steps$ = steps$ + 1
            distance$ = distance$ + STEP_SIZE#
            
            LET cx$ = INT(rx$)
            LET cy$ = INT(ry$)
            
            IF cx$ >= 0 AND cx$ < MAP_W# AND cy$ >= 0 AND cy$ < MAP_H# THEN
                IF map$(cy$, cx$) = 1 THEN
                    hit$ = 1
                ENDIF
            ELSE
                hit$ = 1
            ENDIF
        WEND
        
        IF hit$ = 1 THEN
            REM Fish-eye correction using angle difference
            LET angleDiff$ = rayAngle$ - pAngle$
            REM Normalize angle difference to -180 to 180
            IF angleDiff$ > 180 THEN angleDiff$ = angleDiff$ - 360
            IF angleDiff$ < -180 THEN angleDiff$ = angleDiff$ + 360
            
            REM Use FastCos for fisheye correction (faster!)
            LET correctedDist$ = distance$ * FastCos(angleDiff$)
            
            REM Calculate wall height
            LET wallHeight$ = (HALF_H# / correctedDist$) * 0.6
            IF wallHeight$ > SCREEN_H# THEN wallHeight$ = SCREEN_H#
            
            LET wallTop$ = HALF_H# - wallHeight$
            LET wallBottom$ = HALF_H# + wallHeight$
            
            REM Calculate brightness based on distance
            LET brightness$ = 255 - (correctedDist$ * 25)
            IF brightness$ < 20 THEN brightness$ = 20
            IF brightness$ > 255 THEN brightness$ = 255
            
            REM Draw wall slice
            LET screenX$ = INT(rayRatio$ * SCREEN_W#)
            LET screenX2$ = INT((ray$ + 1) / NUM_RAYS# * SCREEN_W#)
            LET wallColor$ = RGB(brightness$, brightness$ * 0.8, brightness$ * 0.6)
            
            LINE (screenX$, wallTop$)-(screenX2$, wallBottom$), wallColor$, BF
        ENDIF
    NEXT
RETURN

REM -----------------------------------------------
REM Draw mini-map with player position
REM -----------------------------------------------
[sub:DrawMinimap]
    LET mapScale$ = 6
    LET mapOffsetX$ = 10
    LET mapOffsetY$ = 10
    
    REM Draw map background
    LINE (mapOffsetX$-2, mapOffsetY$-2)-(mapOffsetX$ + MAP_W# * mapScale$ + 2, mapOffsetY$ + MAP_H# * mapScale$ + 2), RGB(0,0,0), BF
    
    REM Draw walls
    FOR my$ = 0 TO MAP_H# - 1
        FOR mx$ = 0 TO MAP_W# - 1
            IF map$(my$, mx$) = 1 THEN
                LET sx$ = mapOffsetX$ + mx$ * mapScale$
                LET sy$ = mapOffsetY$ + my$ * mapScale$
                LINE (sx$, sy$)-(sx$ + mapScale$ - 1, sy$ + mapScale$ - 1), RGB(150, 150, 150), BF
            ENDIF
        NEXT
    NEXT
    
    REM Draw player position
    LET plrX$ = mapOffsetX$ + INT(px$ * mapScale$)
    LET plrY$ = mapOffsetY$ + INT(py$ * mapScale$)
    CIRCLE (plrX$, plrY$), 3, RGB(255, 255, 0), 1
    
    REM Draw player direction using FastCos/FastSin
    LET dirX$ = plrX$ + INT(FastCos(pAngle$) * 8)
    LET dirY$ = plrY$ + INT(FastSin(pAngle$) * 8)
    LINE (plrX$, plrY$)-(dirX$, dirY$), RGB(255, 255, 0)
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
