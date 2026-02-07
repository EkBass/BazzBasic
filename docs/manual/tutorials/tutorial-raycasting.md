# Tutorial: 2D raycasting

Simple 2D raycasting program example

## The Code

```vb
' ============================================
' 2D Field-of-View (FOV) — 90-Ray Casting
' BazzBasic version: https://ekbass.github.io/BazzBasic/
' Reads walls from map array, SCREENLOCK for
' flicker-free rendering
' ============================================

LET NUM_RAYS# = 90
LET STEP_SIZE# = 0.2
LET MAX_STEPS# = 40
LET PI2# = 6.28318530

' Map definition
DIM m$
GOSUB [sub:readMap]

LET MAP_H# = 21
LET MAP_W# = 31
LET px$ = 3
LET py$ = 3

DIM vis$
CLS

' === Main Loop ===
LET running$ = TRUE
WHILE running$

    ' 1) Reset visibility
    FOR vy$ = 0 TO MAP_H# - 1
        FOR vx$ = 0 TO MAP_W# - 1
            vis$(vy$, vx$) = 0
        NEXT
    NEXT
    vis$(py$, px$) = 1

    ' 2) Cast rays — read walls from array, no screen needed
    GOSUB [sub:CastAllRays]

    ' 3) Draw everything in one go
    SCREENLOCK ON
    GOSUB [sub:DrawFOV]

    ' 4) Player
    COLOR 10, 0
    LOCATE py$ + 1, px$ + 1
    PRINT "@";

    ' 5) Status bar
    COLOR 8, 0
    LOCATE MAP_H# + 2, 1
    PRINT "Arrows=Move  ESC=Quit  Pos:"; px$; ","; py$; "   ";
    SCREENLOCK OFF

    ' 6) Wait for a keypress
    LET key$ = 0
    WHILE key$ = 0
        key$ = INKEY
        SLEEP 16
    WEND

    ' 7) Movement + collision
    LET nx$ = px$
    LET ny$ = py$
    IF key$ = KEY_UP# THEN ny$ = py$ - 1
    IF key$ = KEY_DOWN# THEN ny$ = py$ + 1
    IF key$ = KEY_LEFT# THEN nx$ = px$ - 1
    IF key$ = KEY_RIGHT# THEN nx$ = px$ + 1
    IF key$ = KEY_ESC# THEN running$ = FALSE

    IF MID(m$(ny$), nx$ + 1, 1) = "." THEN
        px$ = nx$
        py$ = ny$
    ENDIF

WEND

COLOR 7, 0
CLS
END

' -----------------------------------------------
' Cast rays — check walls from map array directly
' -----------------------------------------------
[sub:CastAllRays]
    FOR ray$ = 0 TO NUM_RAYS# - 1
        LET angle$ = (ray$ / NUM_RAYS#) * PI2#
        LET dx$ = COS(angle$) * STEP_SIZE#
        LET dy$ = SIN(angle$) * STEP_SIZE#
        LET rx$ = px$ + 0.5
        LET ry$ = py$ + 0.5
        LET hit$ = 0

        FOR s$ = 1 TO MAX_STEPS#
            IF hit$ = 0 THEN
                rx$ = rx$ + dx$
                ry$ = ry$ + dy$
                LET cx$ = INT(rx$)
                LET cy$ = INT(ry$)

                IF cx$ >= 0 AND cx$ < MAP_W# AND cy$ >= 0 AND cy$ < MAP_H# THEN
                    vis$(cy$, cx$) = 1
                    IF MID(m$(cy$), cx$ + 1, 1) = "#" THEN hit$ = 1
                ELSE
                    hit$ = 1
                ENDIF
            ENDIF
        NEXT
    NEXT
RETURN

' -----------------------------------------------
' Draw map: visible=lit, not visible=black
' -----------------------------------------------
[sub:DrawFOV]
    FOR dy$ = 0 TO MAP_H# - 1
        FOR dx$ = 0 TO MAP_W# - 1
            LOCATE dy$ + 1, dx$ + 1
            LET ch$ = MID(m$(dy$), dx$ + 1, 1)
            IF vis$(dy$, dx$) = 1 THEN
                IF ch$ = "#" THEN
                    COLOR 7, 0
                ELSE
                    COLOR 14, 0
                ENDIF
            ELSE
                COLOR 0, 0
            ENDIF
            PRINT ch$;
        NEXT
    NEXT
RETURN

' -----------------------------------------------
' Read map into array
' -----------------------------------------------
[sub:readMap]
	m$(0) 	= "###############################"
	m$(1) 	= "#...........#..#........#.....#"
	m$(2) 	= "####..#..####..#######..#..#..#"
	m$(3) 	= "#.....#........#...........#..#"
	m$(4) 	= "#######..#..#..#..####..#######"
	m$(5) 	= "#........#..#.....#..#........#"
	m$(6) 	= "#######..#..####..#..####..####"
	m$(7) 	= "#.....#..#..#.....#.....#.....#"
	m$(8) 	= "####..##########..#..#######..#"
	m$(9) 	= "#...........#.....#..#..#..#..#"
	m$(10)	= "####..####..#..####..#..#..#..#"
	m$(11)	= "#.....#.....#..............#..#"
	m$(12) 	= "#..#######..#..#..##########..#"
	m$(13) 	= "#.....#.....#..#........#..#..#"
	m$(14) 	= "#######..##########..####..#..#"
	m$(15) 	= "#...........#.....#..#..#.....#"
	m$(16) 	= "#..##########..#######..####..#"
	m$(17) 	= "#..............#..............#"
	m$(18) 	= "##########..#..####..####..#..#"
	m$(19) 	= "#...........#...........#..#..#"
	m$(20) 	= "###############################"
RETURN
```