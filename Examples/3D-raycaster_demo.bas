' ============================================
' 3D RAYCASTER - Optimized Version
' BazzBasic version: https://ekbass.github.io/BazzBasic/
' ============================================

LET PI# = 3.14159265
LET PI2# = 6.28318530
LET FOV# = 1.0472
LET NUM_RAYS# = 180
LET STEP_SIZE# = 0.05
LET MAX_STEPS# = 512

LET SCREEN_W# = 640
LET SCREEN_H# = 480
LET HALF_H# = 240

' Map definition
DIM m$
DIM map$  ' Optimized map with integers
GOSUB [sub:readMap]

LET MAP_H# = 21
LET MAP_W# = 31
LET px$ = 3.5
LET py$ = 3.5
LET pAngle$ = 0

' pre-proces: change string map as integers
GOSUB [sub:convertMapToArray]

SCREEN 12
CLS

' === Main Loop ===
LET running$ = TRUE
WHILE running$
    LET key$ = INKEY
    
    LET moveSpeed$ = 0.1
    LET rotSpeed$ = 0.08
    
    IF key$ = KEY_UP# THEN
        LET nx$ = px$ + COS(pAngle$) * moveSpeed$
        LET ny$ = py$ + SIN(pAngle$) * moveSpeed$
        IF map$(INT(ny$), INT(nx$)) = 0 THEN
            px$ = nx$
            py$ = ny$
        ENDIF
    ENDIF
    
    IF key$ = KEY_DOWN# THEN
        LET nx$ = px$ - COS(pAngle$) * moveSpeed$
        LET ny$ = py$ - SIN(pAngle$) * moveSpeed$
        IF map$(INT(ny$), INT(nx$)) = 0 THEN
            px$ = nx$
            py$ = ny$
        ENDIF
    ENDIF
    
    IF key$ = KEY_LEFT# THEN
        pAngle$ = pAngle$ - rotSpeed$
        IF pAngle$ < 0 THEN pAngle$ = pAngle$ + PI2#
    ENDIF
    
    IF key$ = KEY_RIGHT# THEN
        pAngle$ = pAngle$ + rotSpeed$
        IF pAngle$ >= PI2# THEN pAngle$ = pAngle$ - PI2#
    ENDIF
    
    IF key$ = KEY_ESC# THEN running$ = FALSE
    
    SCREENLOCK ON
    
    LINE (0,0)-(SCREEN_W#, HALF_H#), RGB(50, 50, 100), BF
    LINE (0,HALF_H#)-(SCREEN_W#, SCREEN_H#), RGB(40, 40, 40), BF
    
    GOSUB [sub:RenderView]
    GOSUB [sub:DrawMinimap]
    
    SCREENLOCK OFF
    SLEEP 16
WEND

COLOR 7, 0
CLS
END

' -----------------------------------------------
' 0 = empty floor, 1 = wall
' -----------------------------------------------
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

' -----------------------------------------------
' Render 3D view - collision check
' -----------------------------------------------
[sub:RenderView]
    LET sliceWidth$ = SCREEN_W# / NUM_RAYS#
    
    FOR ray$ = 0 TO NUM_RAYS# - 1
        LET rayRatio$ = ray$ / NUM_RAYS#
        LET rayAngle$ = pAngle$ - (FOV# / 2) + (rayRatio$ * FOV#)
        
        LET dx$ = COS(rayAngle$) * STEP_SIZE#
        LET dy$ = SIN(rayAngle$) * STEP_SIZE#
        LET rx$ = px$
        LET ry$ = py$
        LET hit$ = 0
        LET distance$ = 0
        LET steps$ = 0
        
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
            LET angleDiff$ = rayAngle$ - pAngle$
            LET correctedDist$ = distance$ * COS(angleDiff$)
            
            LET wallHeight$ = (HALF_H# / correctedDist$) * 0.6
            IF wallHeight$ > SCREEN_H# THEN wallHeight$ = SCREEN_H#
            
            LET wallTop$ = HALF_H# - wallHeight$
            LET wallBottom$ = HALF_H# + wallHeight$
            
            LET brightness$ = 255 - (correctedDist$ * 25)
            IF brightness$ < 20 THEN brightness$ = 20
            IF brightness$ > 255 THEN brightness$ = 255
            
            LET screenX$ = INT(rayRatio$ * SCREEN_W#)
            LET screenX2$ = INT((ray$ + 1) / NUM_RAYS# * SCREEN_W#)
            LET wallColor$ = RGB(brightness$, brightness$ * 0.8, brightness$ * 0.6)
            
            LINE (screenX$, wallTop$)-(screenX2$, wallBottom$), wallColor$, BF
        ENDIF
    NEXT
RETURN

' -----------------------------------------------
' Draw mini-map 
' -----------------------------------------------
[sub:DrawMinimap]
    LET mapScale$ = 6
    LET mapOffsetX$ = 10
    LET mapOffsetY$ = 10
    
    LINE (mapOffsetX$-2, mapOffsetY$-2)-(mapOffsetX$ + MAP_W# * mapScale$ + 2, mapOffsetY$ + MAP_H# * mapScale$ + 2), RGB(0,0,0), BF
    
    FOR my$ = 0 TO MAP_H# - 1
        FOR mx$ = 0 TO MAP_W# - 1
            IF map$(my$, mx$) = 1 THEN
                LET sx$ = mapOffsetX$ + mx$ * mapScale$
                LET sy$ = mapOffsetY$ + my$ * mapScale$
                LINE (sx$, sy$)-(sx$ + mapScale$ - 1, sy$ + mapScale$ - 1), RGB(150, 150, 150), BF
            ENDIF
        NEXT
    NEXT
    
    LET plrX$ = mapOffsetX$ + INT(px$ * mapScale$)
    LET plrY$ = mapOffsetY$ + INT(py$ * mapScale$)
    CIRCLE (plrX$, plrY$), 3, RGB(255, 255, 0), 1
    
    LET dirX$ = plrX$ + INT(COS(pAngle$) * 8)
    LET dirY$ = plrY$ + INT(SIN(pAngle$) * 8)
    LINE (plrX$, plrY$)-(dirX$, dirY$), RGB(255, 255, 0)
RETURN

' -----------------------------------------------
' Read map into string array
' -----------------------------------------------
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