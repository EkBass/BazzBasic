' ==========================================
' Fov_2D_demo.bas — BazzBasic
' 2D Field-of-View: 90-ray casting on a
' console map. Walls stored in array,
' https://ekbass.github.io/BazzBasic/
' ==========================================

[inits]
    LET NUM_RAYS#  = 90
    LET STEP_SIZE# = 0.2
    LET MAX_STEPS# = 40
    LET MAP_H#     = 21
    LET MAP_W#     = 31

    ' Console color palette
    LET BLACK#  = 0
    LET LGRAY#  = 7
    LET DGRAY#  = 8
    LET LGREEN# = 10
    LET YELLOW# = 14

    ' Player position
    LET px$ = 3
    LET py$ = 3

    ' Shared working variables
    LET ch$, key$, nx$, ny$
    LET angle$, dx$, dy$, rx$, ry$
    LET hit$, mx$, my$

    DIM m$
    DIM vis$

    GOSUB [sub:readMap]
	
	' [main]
	LET running$
	
	' [sub:CastAllRays]
	LET cx$, cy$

[main]
    CLS
    running$ = TRUE

    WHILE running$

        ' 1) Reset visibility
        FOR vy$ = 0 TO MAP_H# - 1
            FOR vx$ = 0 TO MAP_W# - 1
                vis$(vy$, vx$) = 0
            NEXT
        NEXT
        vis$(py$, px$) = 1

        ' 2) Cast rays — mark visible cells
        GOSUB [sub:CastAllRays]

        ' 3) Draw map
        GOSUB [sub:DrawFOV]

        ' 4) Draw player
        COLOR LGREEN#, BLACK#
        LOCATE py$ + 1, px$ + 1
        PRINT "@";

        ' 5) Status bar
        COLOR DGRAY#, BLACK#
        LOCATE MAP_H# + 2, 1
        PRINT "Arrows=Move  ESC=Quit  Pos:"; px$; ","; py$; "   ";

        ' 6) Wait for keypress
        key$ = 0
        WHILE key$ = 0
            key$ = INKEY
            SLEEP 16
        WEND

        ' 7) Movement + collision
        nx$ = px$
        ny$ = py$
        IF key$ = KEY_UP#    THEN ny$ = py$ - 1
        IF key$ = KEY_DOWN#  THEN ny$ = py$ + 1
        IF key$ = KEY_LEFT#  THEN nx$ = px$ - 1
        IF key$ = KEY_RIGHT# THEN nx$ = px$ + 1
        IF key$ = KEY_ESC#   THEN running$ = FALSE

        IF MID(m$(ny$), nx$ + 1, 1) = "." THEN
            px$ = nx$
            py$ = ny$
        END IF

    WEND

    COLOR LGRAY#, BLACK#
    CLS
END

' -----------------------------------------------
' Cast all rays — mark cells visible in vis$()
' -----------------------------------------------
[sub:CastAllRays]

    FOR ray$ = 0 TO NUM_RAYS# - 1
        angle$ = (ray$ / NUM_RAYS#) * TAU#
        dx$    = COS(angle$) * STEP_SIZE#
        dy$    = SIN(angle$) * STEP_SIZE#
        rx$    = px$ + 0.5
        ry$    = py$ + 0.5
        hit$   = 0

        FOR s$ = 1 TO MAX_STEPS#
            IF hit$ = 0 THEN
                rx$ = rx$ + dx$
                ry$ = ry$ + dy$
                cx$ = INT(rx$)
                cy$ = INT(ry$)

                IF cx$ >= 0 AND cx$ < MAP_W# AND cy$ >= 0 AND cy$ < MAP_H# THEN
                    vis$(cy$, cx$) = 1
                    IF MID(m$(cy$), cx$ + 1, 1) = "#" THEN hit$ = 1
                ELSE
                    hit$ = 1
                END IF
            END IF
        NEXT
    NEXT
RETURN

' -----------------------------------------------
' Draw map: visible cells lit, others black
' mx$/my$ used to avoid clobbering dx$/dy$
' -----------------------------------------------
[sub:DrawFOV]
    FOR my$ = 0 TO MAP_H# - 1
        FOR mx$ = 0 TO MAP_W# - 1
            LOCATE my$ + 1, mx$ + 1
            ch$ = MID(m$(my$), mx$ + 1, 1)
            IF vis$(my$, mx$) = 1 THEN
                IF ch$ = "#" THEN
                    COLOR LGRAY#, BLACK#
                ELSE
                    COLOR YELLOW#, BLACK#
                END IF
            ELSE
                COLOR BLACK#, BLACK#
            END IF
            PRINT ch$;
        NEXT
    NEXT
RETURN

' -----------------------------------------------
' Load map into array
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
