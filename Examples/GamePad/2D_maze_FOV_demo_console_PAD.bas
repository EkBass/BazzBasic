' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Console field-of-view demo that casts 90 rays from the player across a maze map stored in an array and lights only the visible cells while the player moves with a gamepad (D-pad or left stick) or the arrow keys.
' CATEGORY: algorithms
' TAGS: field of view, ray casting, maze, gamepad, arrow keys
' MINVERSION: 1.5
' ============================================
' Move with gamepad D-pad / left stick or arrow keys.
' Holding a direction repeats the step. BACK or ESC quits.

[inits]
    LET NUM_RAYS#  = 90
    LET STEP_SIZE# = 0.2
    LET MAX_STEPS# = 40
    LET MAP_H#     = 21
    LET MAP_W#     = 31
    LET REPEAT_MS# = 150    ' step delay while a pad direction is held
    LET STICK#     = 0.5    ' stick deflection that counts as a direction

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

    ' Gamepad: dir$ = "U", "D", "L", "R", "Q" (quit) or "" (nothing)
    LET dir$ = ""
    LET lastMove$ = 0

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
        PRINT "Pad/Arrows=Move  BACK/ESC=Quit  Pos:"; px$; ","; py$; "   ";

        ' 6) Wait for a keypress or a pad direction
        key$ = 0
        dir$ = ""
        WHILE key$ = 0 AND dir$ = ""
            key$ = INKEY
            GOSUB [sub:readPad]
            SLEEP 16
        WEND

        ' 7) Movement + collision
        nx$ = px$
        ny$ = py$
        IF key$ = KEY_UP#    OR dir$ = "U" THEN ny$ = py$ - 1
        IF key$ = KEY_DOWN#  OR dir$ = "D" THEN ny$ = py$ + 1
        IF key$ = KEY_LEFT#  OR dir$ = "L" THEN nx$ = px$ - 1
        IF key$ = KEY_RIGHT# OR dir$ = "R" THEN nx$ = px$ + 1
        IF key$ = KEY_ESC#   OR dir$ = "Q" THEN running$ = FALSE

        IF MID(m$(ny$), nx$ + 1, 1) = "." THEN
            px$ = nx$
            py$ = ny$
        END IF

    WEND

    COLOR LGRAY#, BLACK#
    CLS
END

' -----------------------------------------------
' Read gamepad into dir$
' A held direction repeats every REPEAT_MS#;
' returning to neutral allows the next step at once.
' -----------------------------------------------
[sub:readPad]
    dir$ = ""
    IF PADBUTTON(0, PAD_UP#)    OR PADAXIS(0, PAD_LY#) < -STICK# THEN dir$ = "U"
    IF PADBUTTON(0, PAD_DOWN#)  OR PADAXIS(0, PAD_LY#) >  STICK# THEN dir$ = "D"
    IF PADBUTTON(0, PAD_LEFT#)  OR PADAXIS(0, PAD_LX#) < -STICK# THEN dir$ = "L"
    IF PADBUTTON(0, PAD_RIGHT#) OR PADAXIS(0, PAD_LX#) >  STICK# THEN dir$ = "R"

    IF dir$ = "" THEN
        lastMove$ = 0
    ELSEIF TICKS - lastMove$ < REPEAT_MS# THEN
        dir$ = ""
    ELSE
        lastMove$ = TICKS
    END IF

    ' BACK quits at once, no repeat delay
    IF PADBUTTON(0, PAD_BACK#) THEN dir$ = "Q"
RETURN

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
