' Fidget Spinner - Ported from Python
' BazzBasic version 1.4

[inits]
    LET WIDTH# = 420
    LET HEIGHT# = 420
    SCREEN 0, WIDTH#, HEIGHT#, "Fidget Spinner - BazzBasic"
    
    ' Colors
    LET BG_COL#     = RGB(255, 255, 255) ' White
    LET RED_COL#    = RGB(255, 0, 0)
    LET GREEN_COL#  = RGB(0, 255, 0)
    LET BLUE_COL#   = RGB(0, 1, 255) ' BUG in BazzBasic 1.4: 0, 0, 255 draws white circle, not blue
    LET LINE_COL#   = RGB(0, 0, 0)
    
    ' Spinner State
    LET turn$  = 0     ' Speed
    LET angle$ = 0     ' Degrees
    LET radius# = 100  
    LET CX# = WIDTH# / 2
    LET CY# = HEIGHT# / 2

    ' Declare variables once here for max performance
    LET x$, y$, deg$, k$
    
    ' Enable Fast Trig lookup tables (~20x faster)
    FastTrig(TRUE)
    
    LET running$ = TRUE

[main]
    WHILE running$
        ' 1. Input: Flick with Space
        k$ = INKEY
        IF k$ = KEY_ESC# THEN running$ = FALSE
        IF k$ = KEY_SPACE# THEN turn$ += 20 
        
        ' 2. Logic: Momentum and Friction
        IF turn$ > 0 THEN
            angle$ += (turn$ / 10)
            angle$ = MOD(angle$, 360)
            turn$ -= 0.2
        END IF
        
        IF turn$ < 0 THEN turn$ = 0
        
        ' 3. Render
        GOSUB [sub:draw]
        SLEEP 20 
    WEND
    FastTrig(FALSE)
END

[sub:draw]
    SCREENLOCK ON
        LINE (0,0)-(WIDTH#, HEIGHT#), BG_COL#, BF
        DRAWSTRING "Press SPACE to spin!", 10, 10, RGB(50, 50, 50)
        
        GOSUB [sub:draw_arm_red]
        GOSUB [sub:draw_arm_green]
        GOSUB [sub:draw_arm_blue]
        
        ' Bonus: Draw a center cap
        CIRCLE (CX#, CY#), 15, LINE_COL#, 1
    SCREENLOCK OFF
RETURN

[sub:draw_arm_red]
    x$ = CX# + (radius# * FastCos(angle$))
    y$ = CY# + (radius# * FastSin(angle$))
    LINE (CX#, CY#)-(x$, y$), LINE_COL#
    CIRCLE (x$, y$), 60, RED_COL#, 1
RETURN

[sub:draw_arm_green]
    deg$ = angle$ + 120
    x$ = CX# + (radius# * FastCos(deg$))
    y$ = CY# + (radius# * FastSin(deg$))
    LINE (CX#, CY#)-(x$, y$), LINE_COL#
    CIRCLE (x$, y$), 60, GREEN_COL#, 1
RETURN

[sub:draw_arm_blue]
    deg$ = angle$ + 240
    x$ = CX# + (radius# * FastCos(deg$))
    y$ = CY# + (radius# * FastSin(deg$)) ' Cleaned line
    LINE (CX#, CY#)-(x$, y$), LINE_COL#
    CIRCLE (x$, y$), 60, BLUE_COL#, 1
RETURN
