REM ============================================
REM PLATFORMER - Gravity & Jump Game
REM BazzBasic version: https://ekbass.github.io/BazzBasic/
REM ============================================
REM Arrow keys = Move
REM SPACE = Jump  
REM ESC = Quit
REM Don't fall more than 5 blocks or you die!
REM ============================================

REM Screen constants
LET SCREEN_W# = 640
LET SCREEN_H# = 480
LET TILE_SIZE# = 20

REM Physics constants
LET GRAVITY# = 0.4
LET MAX_FALL_SPEED# = 12
LET JUMP_POWER# = -10
LET MOVE_SPEED# = 3
LET AIR_CONTROL# = 2
LET GROUND_FRICTION# = 0.85
LET AIR_FRICTION# = 0.98
LET DEATH_FALL# = 5

REM Player hitbox
LET PLAYER_WIDTH# = 0.4
LET PLAYER_HEIGHT# = 0.8

REM Map definition
DIM m$
GOSUB [sub:readMap]
LET MAP_H# = 21
LET MAP_W# = 31

REM Player state
LET px$ = 2
LET py$ = 2
LET vx$ = 0
LET vy$ = 0
LET onGround$ = 0
LET highestY$ = py$
LET alive$ = 1

REM Camera offset
LET camX$ = 0
LET camY$ = 0

REM Initialize graphics
SCREEN 0, SCREEN_W#, SCREEN_H#, "PLATFORMER - Don't Fall!"
CLS

REM Colors
LET BG_COLOR# = RGB(20, 20, 30)
LET WALL_COLOR# = RGB(100, 100, 120)
LET FLOOR_COLOR# = RGB(80, 60, 40)
LET PLAYER_COLOR# = RGB(255, 200, 0)
LET DEATH_COLOR# = RGB(200, 0, 0)

REM Declare loop variables once
LET moveInput$ = 0
LET newX$ = 0
LET newY$ = 0
LET leftEdge$ = 0
LET rightEdge$ = 0
LET topEdge$ = 0
LET bottomEdge$ = 0
LET testX$ = 0
LET testY$ = 0
LET testYBottom$ = 0
LET testYTop$ = 0
LET hitLeft$ = 0
LET hitRight$ = 0
LET hitFloor$ = 0
LET hitCeiling$ = 0
LET fallDistance$ = 0
LET startX$ = 0
LET startY$ = 0
LET endX$ = 0
LET endY$ = 0
LET x$ = 0
LET y$ = 0
LET sx$ = 0
LET sy$ = 0
LET screenX$ = 0
LET screenY$ = 0
LET drawWidth$ = 0
LET drawHeight$ = 0

REM === Main Loop ===
LET running$ = TRUE
WHILE running$ AND alive$
    REM === INPUT ===
    IF INKEY = KEY_ESC# THEN running$ = FALSE
    
    moveInput$ = 0
    IF KEYDOWN(KEY_LEFT#) THEN moveInput$ = -1
    IF KEYDOWN(KEY_RIGHT#) THEN moveInput$ = 1
    
    IF KEYDOWN(KEY_SPACE#) AND onGround$ = 1 THEN
        vy$ = JUMP_POWER#
        onGround$ = 0
    ENDIF
    
    REM === PHYSICS ===
    
    IF onGround$ = 1 THEN
        vx$ = moveInput$ * MOVE_SPEED#
        vx$ = vx$ * GROUND_FRICTION#
    ELSE
        vx$ = vx$ + (moveInput$ * AIR_CONTROL#)
        vx$ = vx$ * AIR_FRICTION#
        IF vx$ > MOVE_SPEED# THEN vx$ = MOVE_SPEED#
        IF vx$ < -MOVE_SPEED# THEN vx$ = -MOVE_SPEED#
    ENDIF
    
    vy$ = vy$ + GRAVITY#
    IF vy$ > MAX_FALL_SPEED# THEN vy$ = MAX_FALL_SPEED#
    
    IF py$ < highestY$ THEN highestY$ = py$
    
    REM === COLLISION WITH HITBOX ===
    
    newX$ = px$ + vx$ * 0.016
    
    leftEdge$ = newX$ - PLAYER_WIDTH# / 2
    rightEdge$ = newX$ + PLAYER_WIDTH# / 2
    topEdge$ = py$ - PLAYER_HEIGHT# / 2
    bottomEdge$ = py$ + PLAYER_HEIGHT# / 2
    
    hitLeft$ = 0
    IF vx$ < 0 THEN
        testX$ = INT(leftEdge$)
        testY$ = INT(py$)
        IF testX$ >= 0 AND testX$ < MAP_W# AND testY$ >= 0 AND testY$ < MAP_H# THEN
            IF MID(m$(testY$), testX$ + 1, 1) = "#" THEN
                hitLeft$ = 1
            ENDIF
        ENDIF
    ENDIF
    
    hitRight$ = 0
    IF vx$ > 0 THEN
        testX$ = INT(rightEdge$)
        testY$ = INT(py$)
        IF testX$ >= 0 AND testX$ < MAP_W# AND testY$ >= 0 AND testY$ < MAP_H# THEN
            IF MID(m$(testY$), testX$ + 1, 1) = "#" THEN
                hitRight$ = 1
            ENDIF
        ENDIF
    ENDIF
    
    IF hitLeft$ = 0 AND hitRight$ = 0 THEN
        px$ = newX$
    ELSE
        vx$ = 0
    ENDIF
    
    newY$ = py$ + vy$ * 0.016
    
    leftEdge$ = px$ - PLAYER_WIDTH# / 2
    rightEdge$ = px$ + PLAYER_WIDTH# / 2
    topEdge$ = newY$ - PLAYER_HEIGHT# / 2
    bottomEdge$ = newY$ + PLAYER_HEIGHT# / 2
    
    IF vy$ >= 0 THEN
        hitFloor$ = 0
        testYBottom$ = INT(bottomEdge$)
        
        testX$ = INT(leftEdge$)
        IF testX$ >= 0 AND testX$ < MAP_W# AND testYBottom$ >= 0 AND testYBottom$ < MAP_H# THEN
            IF MID(m$(testYBottom$), testX$ + 1, 1) = "#" THEN
                hitFloor$ = 1
            ENDIF
        ENDIF
        
        testX$ = INT(rightEdge$)
        IF testX$ >= 0 AND testX$ < MAP_W# AND testYBottom$ >= 0 AND testYBottom$ < MAP_H# THEN
            IF MID(m$(testYBottom$), testX$ + 1, 1) = "#" THEN
                hitFloor$ = 1
            ENDIF
        ENDIF
        
        IF hitFloor$ = 1 THEN
            fallDistance$ = py$ - highestY$
            
            IF fallDistance$ > DEATH_FALL# THEN
                alive$ = 0
                GOSUB [sub:deathScreen]
            ENDIF
            
            py$ = testYBottom$ - PLAYER_HEIGHT# / 2
            vy$ = 0
            onGround$ = 1
            highestY$ = py$
        ELSE
            py$ = newY$
            onGround$ = 0
        ENDIF
    ENDIF
    
    IF vy$ < 0 THEN
        hitCeiling$ = 0
        testYTop$ = INT(topEdge$)
        
        testX$ = INT(leftEdge$)
        IF testX$ >= 0 AND testX$ < MAP_W# AND testYTop$ >= 0 AND testYTop$ < MAP_H# THEN
            IF MID(m$(testYTop$), testX$ + 1, 1) = "#" THEN
                hitCeiling$ = 1
            ENDIF
        ENDIF
        
        testX$ = INT(rightEdge$)
        IF testX$ >= 0 AND testX$ < MAP_W# AND testYTop$ >= 0 AND testYTop$ < MAP_H# THEN
            IF MID(m$(testYTop$), testX$ + 1, 1) = "#" THEN
                hitCeiling$ = 1
            ENDIF
        ENDIF
        
        IF hitCeiling$ = 1 THEN
            py$ = testYTop$ + 1 + PLAYER_HEIGHT# / 2
            vy$ = 0
        ELSE
            py$ = newY$
        ENDIF
    ENDIF
    
    REM === CAMERA ===
    camX$ = INT(px$ * TILE_SIZE# - SCREEN_W# / 2)
    camY$ = INT(py$ * TILE_SIZE# - SCREEN_H# / 2)
    
    IF camX$ < 0 THEN camX$ = 0
    IF camY$ < 0 THEN camY$ = 0
    IF camX$ > MAP_W# * TILE_SIZE# - SCREEN_W# THEN
        camX$ = MAP_W# * TILE_SIZE# - SCREEN_W#
    ENDIF
    IF camY$ > MAP_H# * TILE_SIZE# - SCREEN_H# THEN
        camY$ = MAP_H# * TILE_SIZE# - SCREEN_H#
    ENDIF
    
    REM === RENDERING ===
    SCREENLOCK ON
    
    LINE (0, 0)-(SCREEN_W#, SCREEN_H#), BG_COLOR#, BF
    
    startX$ = INT(camX$ / TILE_SIZE#)
    startY$ = INT(camY$ / TILE_SIZE#)
    endX$ = startX$ + INT(SCREEN_W# / TILE_SIZE#) + 2
    endY$ = startY$ + INT(SCREEN_H# / TILE_SIZE#) + 2
    
    IF endX$ > MAP_W# THEN endX$ = MAP_W#
    IF endY$ > MAP_H# THEN endY$ = MAP_H#
    
    FOR y$ = startY$ TO endY$
        FOR x$ = startX$ TO endX$
            IF x$ >= 0 AND x$ < MAP_W# AND y$ >= 0 AND y$ < MAP_H# THEN
                IF MID(m$(y$), x$ + 1, 1) = "#" THEN
                    sx$ = x$ * TILE_SIZE# - camX$
                    sy$ = y$ * TILE_SIZE# - camY$
                    
                    LINE (sx$, sy$)-(sx$ + TILE_SIZE#, sy$ + TILE_SIZE#), WALL_COLOR#, BF
                    LINE (sx$ + 1, sy$ + 1)-(sx$ + TILE_SIZE# - 1, sy$ + TILE_SIZE# - 1), FLOOR_COLOR#, B
                ENDIF
            ENDIF
        NEXT
    NEXT
    
    screenX$ = INT(px$ * TILE_SIZE# - camX$)
    screenY$ = INT(py$ * TILE_SIZE# - camY$)
    drawWidth$ = PLAYER_WIDTH# * TILE_SIZE#
    drawHeight$ = PLAYER_HEIGHT# * TILE_SIZE#
    
    LINE (screenX$ - drawWidth$/2, screenY$ - drawHeight$/2)-(screenX$ + drawWidth$/2, screenY$ + drawHeight$/2), PLAYER_COLOR#, BF
    
    SCREENLOCK OFF
    SLEEP 16
WEND

COLOR 7, 0
CLS
PRINT "\nThanks for playing!"
END

REM -----------------------------------------------
REM Death screen
REM -----------------------------------------------
[sub:deathScreen]
    SCREENLOCK ON
    
    LINE (0, 0)-(SCREEN_W#, SCREEN_H#), DEATH_COLOR#, BF
    
    COLOR 15, 0
    LOCATE 10, 15
    PRINT "*** YOU FELL TOO FAR! ***"
    LOCATE 12, 18
    PRINT "Fall distance: "; INT(py$ - highestY$); " blocks"
    LOCATE 14, 20
    PRINT "Press any key..."
    
    SCREENLOCK OFF
    
    WHILE INKEY = 0
        SLEEP 16
    WEND
RETURN

REM -----------------------------------------------
REM Read map - designed for platforming!
REM -----------------------------------------------
[sub:readMap]
    m$(0)   = "###############################"
    m$(1)   = "#.............................#"
    m$(2)   = "#.............................#"
    m$(3)   = "######........................#"
    m$(4)   = "#......#####.......#####......#"
    m$(5)   = "#............#####..........###"
    m$(6)   = "#.......................##....#"
    m$(7)   = "#...####........########......#"
    m$(8)   = "##.......##...................#"
    m$(9)   = "#..#........####..............#"
    m$(10)  = "#....#........................#"
    m$(11)  = "#......#......................#"
    m$(12)  = "#..#.#.........#...#..####..###"
    m$(13)  = "##......###############.......#"
    m$(14)  = "####.....................#.##.#"
    m$(15)  = "#...#....................#.##.#"
    m$(16)  = "#...##########................#"
    m$(17)  = "#...............##...........##"
    m$(18)  = "#....#.#.#.#.#.....##.........#"
    m$(19)  = "#...#.........................#"
    m$(20)  = "###############################"
RETURN