' Caterpillar Game - Ported from Python
' BazzBasic version 1.4
' original https://github.com/SmallLion/Python-Projects/blob/main/Caterpillar.py

[inits]
    LET WIDTH# = 640
    LET HEIGHT# = 480
    SCREEN 0, WIDTH#, HEIGHT#, "Caterpillar - BazzBasic"
    
    ' Colors
    LET BG_COL#     = RGB(255, 255, 0)   ' Yellow
    LET CAT_COL#    = RGB(255, 0, 0)     ' Red
    LET LEAF_COL#   = RGB(0, 128, 0)     ' Green
    LET TEXT_COL#   = RGB(0, 0, 0)       ' Black
    
    ' Game Variables
    LET score$ = 0
    LET speed$ = 5        ' Initial pixels per move

    ' Increased segSize$ from 20 to 25
    LET segSize# = 25     ' Size of each segment
    LET gameStarted$ = FALSE
    LET running$ = TRUE
    
    ' Segment Arrays (Tail management)
    DIM segX$
    DIM segY$
    LET length$ = 3
    
    ' Initial position and direction (0=Right, 90=Up, 180=Left, 270=Down)
    LET headX$ = WIDTH# / 2
    LET headY$ = HEIGHT# / 2
    LET curDir$ = 0 
    
    FOR i$ = 0 TO length$ - 1
        segX$(i$) = headX$ - (i$ * segSize#)
        segY$(i$) = headY$
    NEXT
    
    ' Leaf Position
    LET leafX$ = RND(WIDTH# - 40) + 20
    LET leafY$ = RND(HEIGHT# - 40) + 20
    
    ' Timing
    LET lastMove$ = TICKS

[intro]
    SCREENLOCK ON
        LINE (0,0)-(WIDTH#, HEIGHT#), BG_COL#, BF
        DRAWSTRING "Press SPACE to Start", WIDTH# / 2 - 100, HEIGHT# / 2, TEXT_COL#
    SCREENLOCK OFF
    
    IF WAITKEY(KEY_SPACE#) THEN gameStarted$ = TRUE

[main]
    WHILE running$
        IF INKEY = KEY_ESC# THEN running$ = FALSE
        
        ' 1. Input: Change Direction
        IF KEYDOWN(KEY_UP#)    AND curDir$ <> 270 THEN curDir$ = 90
        IF KEYDOWN(KEY_DOWN#)  AND curDir$ <> 90  THEN curDir$ = 270
        IF KEYDOWN(KEY_LEFT#)  AND curDir$ <> 0   THEN curDir$ = 180
        IF KEYDOWN(KEY_RIGHT#) AND curDir$ <> 180 THEN curDir$ = 0
        
        ' 2. Logic: Movement Timing
        IF TICKS - lastMove$ > 50 THEN
            ' Move Tail: each segment follows the one before it
            FOR i$ = length$ - 1 TO 1 STEP -1
                segX$(i$) = segX$(i$ - 1)
                segY$(i$) = segY$(i$ - 1)
            NEXT
            
            ' Move Head
            IF curDir$ = 0   THEN segX$(0) += segSize#
            IF curDir$ = 180 THEN segX$(0) -= segSize#
            IF curDir$ = 90  THEN segY$(0) -= segSize#
            IF curDir$ = 270 THEN segY$(0) += segSize#
            
            ' Check Boundary (Game Over)
            IF segX$(0) < 0 OR segX$(0) > WIDTH# OR segY$(0) < 0 OR segY$(0) > HEIGHT# THEN
                GOSUB [sub:game_over]
                running$ = FALSE
            END IF
            
            ' Check Leaf Collision
            IF DISTANCE(segX$(0), segY$(0), leafX$, leafY$) < segSize# THEN
                score$ += 10
                length$ += 1
                ' Randomize new leaf
                leafX$ = RND(WIDTH# - 40) + 20
                leafY$ = RND(HEIGHT# - 40) + 20
            END IF
            
            lastMove$ = TICKS
        END IF
        
        ' 3. Render
        GOSUB [sub:draw]

        ' Increased SLEEP from 16 to 30
        SLEEP 30
    WEND
END

[sub:draw]
    SCREENLOCK ON
        LINE (0,0)-(WIDTH#, HEIGHT#), BG_COL#, BF
        
        ' Draw Leaf
        CIRCLE (leafX$, leafY$), 10, LEAF_COL#, 1
        
        ' Draw Caterpillar
        FOR i$ = 0 TO length$ - 1
            IF HASKEY(segX$(i$)) THEN
                LINE (segX$(i$), segY$(i$))-(segX$(i$)+segSize#-2, segY$(i$)+segSize#-2), CAT_COL#, BF
            END IF
        NEXT
        
        ' UI
        DRAWSTRING "Score: " + STR(score$), 10, 10, TEXT_COL#
    SCREENLOCK OFF
RETURN

[sub:game_over]
    SCREENLOCK ON
        DRAWSTRING "GAME OVER!", WIDTH# / 2 - 50, HEIGHT# / 2, TEXT_COL#
    SCREENLOCK OFF
    SLEEP 2000
RETURN
