' BazzBasic version 1.4
' https://ekbass.github.io/BazzBasic/
' Egg Catcher - Ported from Python to BazzBasic
' https://github.com/Buzzpy/Python-Projects/blob/main/egg_catcher.py

[inits]
    ' Screen and game settings
    LET WIDTH# = 800
    LET HEIGHT# = 400
    SCREEN 0, WIDTH#, HEIGHT#, "Egg Catcher - BazzBasic"
    
    ' Colors (Pre-computed for speed)
    LET SKY_COL#    = RGB(0, 191, 255)  ' Deep sky blue
    LET GRASS_COL#  = RGB(46, 139, 87)  ' Sea green
    LET SUN_COL#    = RGB(255, 165, 0)  ' Orange
    LET TEXT_COL#   = RGB(0, 0, 139)    ' Dark blue
    LET BUCKET_COL# = RGB(0, 0, 255)    ' Blue
    
    ' Game Variables
    LET score$ = 0
    LET lives$ = 3
    LET eggWidth# = 45
    LET eggHeight# = 55
    LET eggInterval$ = 4000
    LET eggSpeed$ = 50
    LET difficulty# = 0.95
    LET lastEggTime$ = TICKS
    LET lastMoveTime$ = TICKS
    
    ' Bucket position (Arc style)
    LET bucketW# = 100
    LET bucketH# = 100
    LET bucketX$ = (WIDTH# / 2) - (bucketW# / 2)
    LET bucketY$ = HEIGHT# - 120
    
    ' Egg Data
    DIM eggsX$
    DIM eggsY$
    DIM eggsCol$
    DIM colors$
    colors$(0) = RGB(173, 216, 230) : colors$(1) = RGB(144, 238, 144)
    colors$(2) = RGB(255, 192, 203) : colors$(3) = RGB(255, 255, 224)
    colors$(4) = RGB(224, 255, 255)
    
    LET running$ = TRUE

[main]
    WHILE running$
        ' Check for exit
        IF INKEY = KEY_ESC# THEN running$ = FALSE
        
        ' 1. Logic: Spawn Eggs
        IF TICKS - lastEggTime$ > eggInterval$ THEN
            GOSUB [sub:create_egg]
            lastEggTime$ = TICKS
        END IF
        
        ' 2. Logic: Move and Catch Eggs
        IF TICKS - lastMoveTime$ > eggSpeed$ THEN
            GOSUB [sub:move_eggs]
            GOSUB [sub:check_catch]
            lastMoveTime$ = TICKS
        END IF
        
        ' 3. Logic: Player Movement
        IF KEYDOWN(KEY_LEFT#) AND bucketX$ > 0 THEN bucketX$ -= 10
        IF KEYDOWN(KEY_RIGHT#) AND bucketX$ < (WIDTH# - bucketW#) THEN bucketX$ += 10
        
        ' 4. Render
        GOSUB [sub:draw]
        
        ' Game Over Check
        IF lives$ <= 0 THEN
            PRINT "GAME OVER! Final Score: "; score$
            SLEEP 3000
            running$ = FALSE
        END IF
        
        SLEEP 16 ' ~60 FPS
    WEND
END

[sub:create_egg]
    LET count$ = ROWCOUNT(eggsX$())
    eggsX$(count$) = RND(WIDTH# - eggWidth#)
    eggsY$(count$) = 40
    eggsCol$(count$) = colors$(RND(5))
RETURN

[sub:move_eggs]
    FOR i$ = 0 TO ROWCOUNT(eggsX$()) - 1
        IF HASKEY(eggsY$(i$)) THEN
            eggsY$(i$) += 10
            ' Check if dropped
            IF eggsY$(i$) > HEIGHT# THEN
                DELKEY eggsX$(i$) : DELKEY eggsY$(i$) : DELKEY eggsCol$(i$)
                lives$ -= 1
            END IF
        END IF
    NEXT
RETURN

[sub:check_catch]
    FOR i$ = 0 TO ROWCOUNT(eggsX$()) - 1
        IF HASKEY(eggsX$(i$)) THEN
            ' Simple collision check
            IF DISTANCE(eggsX$(i$), eggsY$(i$), bucketX$ + 50, bucketY$ + 50) < 50 THEN ' Dropped < 60 to < 50
                DELKEY eggsX$(i$) : DELKEY eggsY$(i$) : DELKEY eggsCol$(i$)
                score$ += 10
                ' Increase Difficulty
                eggSpeed$ = INT(eggSpeed$ * difficulty#)
                eggInterval$ = INT(eggInterval$ * difficulty#)
            END IF
        END IF
    NEXT
RETURN

[sub:draw]
    SCREENLOCK ON
    ' Background (Grass and Sky)
    LINE (0, 0)-(WIDTH#, HEIGHT#), SKY_COL#, BF
    LINE (0, HEIGHT# - 100)-(WIDTH#, HEIGHT#), GRASS_COL#, BF
    CIRCLE (-20, -20), 100, SUN_COL#, 1 ' Sun
    
    ' Draw Eggs
    FOR i$ = 0 TO ROWCOUNT(eggsX$()) - 1
        IF HASKEY(eggsX$(i$)) THEN
            CIRCLE (eggsX$(i$), eggsY$(i$)), 25, eggsCol$(i$), 1
        END IF
    NEXT
    
    ' Draw Bucket (Represented as a bowl/circle segment)
    CIRCLE (bucketX$ + 50, bucketY$ + 75), 40, BUCKET_COL#, 1
    LINE (bucketX$, bucketY$ + 25)-(bucketX$ + 100, bucketY$ + 50), GRASS_COL#, BF ' GRASS_COL#, not SKY_COL#
    
    ' UI
    DRAWSTRING "Score: " + STR(score$), 10, 10, TEXT_COL#
    DRAWSTRING "Lives: " + STR(lives$), WIDTH# - 120, 10, TEXT_COL#
    SCREENLOCK OFF
RETURN
