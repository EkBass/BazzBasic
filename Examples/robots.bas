' ========================================================
' ROBOTS — BazzBasic Edition
' Based on the 1978 classic by Lance Micklus
' ========================================================
' Navigate X through the arena using arrow keys.
' Robots (O) pursue you relentlessly each turn.
' Lure them into fences or each other to destroy them.
' Survive until every robot is gone — or be ZAPPED!
' ========================================================

' ---- FUNCTIONS ----

' Integer sign: returns -1, 0 or +1 for robot heading
DEF FN Sign$(n$)
    IF n$ > 0 THEN RETURN 1
    IF n$ < 0 THEN RETURN -1
    RETURN 0
END DEF

' ---- INITS ----
' All variables must be declared here, outside loops and subs.
' BazzBasic checks variable existence on every access;
' pre-declaring avoids that overhead inside tight loops.

[inits]
    LET COLS#       = 58   ' Inner grid width  (0 .. COLS#-1)
    LET ROWS#       = 20   ' Inner grid height (0 .. ROWS#-1)
    LET MAX_FENCES# = 15
    LET MAX_ROBOTS# = 50

    LET BLACK#  = 0
    LET CYAN#   = 3
    LET DGRAY#  = 8
    LET LGREEN# = 10
    LET LRED#   = 12
    LET YELLOW# = 14
    LET WHITE#  = 15

    DIM grid$         ' 2D grid: grid$(row, col) holds " ", "X", "O", "-", "|"
    DIM robotX$       ' Robot X positions (1-indexed, 1..robotCount$)
    DIM robotY$       ' Robot Y positions
    DIM robotAlive$   ' TRUE while robot is still active

    LET fenceCount$   = 5
    LET robotCount$   = 20
    LET liveRobots$   = 0
    LET playerX$      = 0
    LET playerY$      = 0
    LET gameOver$     = FALSE
    LET playerDead$   = FALSE
    LET quitApp$      = FALSE
    LET menuDone$     = FALSE
    LET placed$       = FALSE
    LET validInput$   = FALSE
    LET keyPress$     = 0
    LET option$       = ""
    LET row$          = ""
    LET cell$         = ""
    LET deltaX$       = 0
    LET deltaY$       = 0
    LET nextX$        = 0
    LET nextY$        = 0
    LET fenceNum$     = 0
    LET fenceX$       = 0
    LET fenceY$       = 0
    LET fenceX1$      = 0
    LET fenceY1$      = 0
    LET fenceLen$     = 0
    LET robotDX$      = 0
    LET robotDY$      = 0
    LET robotNextX$   = 0
    LET robotNextY$   = 0
    SCREEN 0, 640, 480, "ROBOTS"
' ---- MAIN ----

[main]
    WHILE NOT quitApp$
        GOSUB [sub:showMenu]
        IF NOT quitApp$ THEN GOSUB [sub:playGame]
    WEND
END

' =====================================================
' SUBROUTINES
' =====================================================

[sub:showMenu]
    menuDone$ = FALSE
    WHILE NOT menuDone$
        CLS
        COLOR YELLOW#, BLACK#
        PRINT "\n  *** ROBOTS ***"
        COLOR WHITE#, BLACK#
        PRINT "  Based on the classic by Lance Micklus (1978)\n"
        COLOR CYAN#, BLACK#
        PRINT "  FENCES : "; fenceCount$
        PRINT "  ROBOTS : "; robotCount$
        PRINT ""
        COLOR WHITE#, BLACK#
        PRINT "  [F]  Change fences  (1-"; MAX_FENCES#; ")"
        PRINT "  [R]  Change robots  (1-"; MAX_ROBOTS#; ")"
        PRINT "  [P]  Play!"
        PRINT "  [Q]  Quit\n"
        LINE INPUT "  OPTION: ", option$
        option$ = UCASE(LEFT(option$, 1))
        IF option$ = "F" THEN GOSUB [sub:setFences]
        IF option$ = "R" THEN GOSUB [sub:setRobots]
        IF option$ = "Q" THEN quitApp$ = TRUE : menuDone$ = TRUE
        IF option$ = "P" THEN menuDone$ = TRUE
    WEND
RETURN

[sub:setFences]
    validInput$ = FALSE
    WHILE NOT validInput$
        INPUT "  Fences (1-15): ", fenceCount$
        IF fenceCount$ >= 1 AND fenceCount$ <= MAX_FENCES# THEN
            validInput$ = TRUE
        ELSE
            PRINT "  Enter a number between 1 and 15."
        END IF
    WEND
RETURN

[sub:setRobots]
    validInput$ = FALSE
    WHILE NOT validInput$
        INPUT "  Robots (1-50): ", robotCount$
        IF robotCount$ >= 1 AND robotCount$ <= MAX_ROBOTS# THEN
            validInput$ = TRUE
        ELSE
            PRINT "  Enter a number between 1 and 50."
        END IF
    WEND
RETURN

[sub:playGame]
    gameOver$   = FALSE
    playerDead$ = FALSE
    GOSUB [sub:initGrid]
    GOSUB [sub:drawAll]
    WHILE NOT gameOver$
        GOSUB [sub:playerTurn]
        IF NOT gameOver$ THEN GOSUB [sub:robotsTurn]
        GOSUB [sub:drawAll]
    WEND
    PRINT ""
    IF playerDead$ THEN
        COLOR LRED#, BLACK#
        PRINT "  *** ZAPPED! You have been destroyed. ***"
    ELSE
        COLOR LGREEN#, BLACK#
        PRINT "  *** YOU WIN! All robots smashed! ***"
    END IF
    COLOR WHITE#, BLACK#
    PRINT "\n  Press any key to return to menu..."
    WAITKEY()
RETURN

' --------------------------------------------------
' Build the grid: clear, scatter fences, place pieces
' --------------------------------------------------
[sub:initGrid]
    ' Fill every inner cell with a space
    FOR i$ = 0 TO ROWS# - 1
        FOR j$ = 0 TO COLS# - 1
            grid$(i$, j$) = " "
        NEXT
    NEXT

    ' Place each fence segment (uses i$ internally — fenceNum$ keeps outer index safe)
    FOR fenceNum$ = 1 TO fenceCount$
        IF RND(2) = 0 THEN
            GOSUB [sub:fenceHoriz]
        ELSE
            GOSUB [sub:fenceVert]
        END IF
    NEXT

    ' Player: pick a random empty inner cell (margin of 1 keeps away from border)
    placed$ = FALSE
    WHILE NOT placed$
        playerX$ = 1 + RND(COLS# - 2)
        playerY$ = 1 + RND(ROWS# - 2)
        IF grid$(playerY$, playerX$) = " " THEN
            grid$(playerY$, playerX$) = "X"
            placed$ = TRUE
        END IF
    WEND

    ' Robots: same random-empty-cell approach, tracked in parallel arrays
    liveRobots$ = robotCount$
    FOR i$ = 1 TO robotCount$
        placed$ = FALSE
        WHILE NOT placed$
            nextX$ = 1 + RND(COLS# - 2)
            nextY$ = 1 + RND(ROWS# - 2)
            IF grid$(nextY$, nextX$) = " " THEN
                grid$(nextY$, nextX$) = "O"
                robotX$(i$)     = nextX$
                robotY$(i$)     = nextY$
                robotAlive$(i$) = TRUE
                placed$         = TRUE
            END IF
        WEND
    NEXT
RETURN

' Horizontal fence: a run of "-" characters
[sub:fenceHoriz]
    fenceY$   = 1 + RND(ROWS# - 2)
    fenceX1$  = 1 + RND(COLS# - 12)
    fenceLen$ = 4 + RND(10)
    FOR i$ = fenceX1$ TO fenceX1$ + fenceLen$ - 1
        IF i$ >= 1 AND i$ <= COLS# - 2 THEN
            IF grid$(fenceY$, i$) = " " THEN grid$(fenceY$, i$) = "-"
        END IF
    NEXT
RETURN

' Vertical fence: a column of "|" characters
[sub:fenceVert]
    fenceX$   = 1 + RND(COLS# - 2)
    fenceY1$  = 1 + RND(ROWS# - 6)
    fenceLen$ = 2 + RND(5)
    FOR i$ = fenceY1$ TO fenceY1$ + fenceLen$ - 1
        IF i$ >= 1 AND i$ <= ROWS# - 2 THEN
            IF grid$(i$, fenceX$) = " " THEN grid$(i$, fenceX$) = "|"
        END IF
    NEXT
RETURN

' --------------------------------------------------
' Redraw the entire arena from the grid array
' --------------------------------------------------
[sub:drawAll]
    CLS
    COLOR DGRAY#, BLACK#
    PRINT "+" + REPEAT("-", COLS#) + "+"
    FOR i$ = 0 TO ROWS# - 1
        row$ = "|"
        FOR j$ = 0 TO COLS# - 1
            row$ = row$ + grid$(i$, j$)
        NEXT
        PRINT row$ + "|"
    NEXT
    PRINT "+" + REPEAT("-", COLS#) + "+"
    COLOR CYAN#, BLACK#
    PRINT "  Robots: "; liveRobots$; "   Arrows = move   ESC = quit"
    COLOR WHITE#, BLACK#
RETURN

' --------------------------------------------------
' Player turn: read one key and act on it
' --------------------------------------------------
[sub:playerTurn]
    keyPress$ = WAITKEY()   ' Blocks until a key arrives — true turn-based feel
    deltaX$   = 0
    deltaY$   = 0
    IF keyPress$ = KEY_UP#    THEN deltaY$ = -1
    IF keyPress$ = KEY_DOWN#  THEN deltaY$ =  1
    IF keyPress$ = KEY_LEFT#  THEN deltaX$ = -1
    IF keyPress$ = KEY_RIGHT# THEN deltaX$ =  1
    IF keyPress$ = KEY_ESC# THEN
        gameOver$ = TRUE
        RETURN
    END IF
    ' Non-movement key pressed — skip this turn without moving
    IF deltaX$ = 0 AND deltaY$ = 0 THEN RETURN

    nextX$ = playerX$ + deltaX$
    nextY$ = playerY$ + deltaY$

    ' Stepping into the border is fatal (there is no safe wall)
    IF nextX$ < 0 OR nextX$ >= COLS# OR nextY$ < 0 OR nextY$ >= ROWS# THEN
        playerDead$ = TRUE
        gameOver$   = TRUE
        RETURN
    END IF

    cell$ = grid$(nextY$, nextX$)
    IF cell$ = "O" OR cell$ = "-" OR cell$ = "|" THEN
        playerDead$ = TRUE
        gameOver$   = TRUE
        RETURN
    END IF

    ' Safe move — update the grid and player coords
    grid$(playerY$, playerX$) = " "
    playerX$                  = nextX$
    playerY$                  = nextY$
    grid$(playerY$, playerX$) = "X"
RETURN

' --------------------------------------------------
' Robots turn: every live robot steps one cell toward
' the player (Chebyshev/king-move: diagonal is valid)
' --------------------------------------------------
[sub:robotsTurn]
    FOR i$ = 1 TO robotCount$
        IF robotAlive$(i$) THEN
            ' Compute one-step heading toward player
            robotDX$    = FN Sign$(playerX$ - robotX$(i$))
            robotDY$    = FN Sign$(playerY$ - robotY$(i$))
            robotNextX$ = robotX$(i$) + robotDX$
            robotNextY$ = robotY$(i$) + robotDY$

            ' Clamp to grid — the border acts as a hard wall for robots too
            IF robotNextX$ < 0      THEN robotNextX$ = 0
            IF robotNextX$ >= COLS# THEN robotNextX$ = COLS# - 1
            IF robotNextY$ < 0      THEN robotNextY$ = 0
            IF robotNextY$ >= ROWS# THEN robotNextY$ = ROWS# - 1

            cell$ = grid$(robotNextY$, robotNextX$)

            ' Vacate current cell before resolving the destination
            grid$(robotY$(i$), robotX$(i$)) = " "

            IF cell$ = "X" THEN
                ' Robot reaches the player
                playerDead$ = TRUE
                gameOver$   = TRUE
                RETURN

            ELSEIF cell$ = "-" OR cell$ = "|" THEN
                ' Fence destroys this robot
                robotAlive$(i$) = FALSE
                liveRobots$     = liveRobots$ - 1

            ELSEIF cell$ = "O" THEN
                ' Collision: find the robot that occupies the target cell and
                ' destroy it too — robots that collide annihilate each other
                FOR j$ = 1 TO robotCount$
                    IF j$ <> i$ AND robotAlive$(j$) THEN
                        IF robotX$(j$) = robotNextX$ AND robotY$(j$) = robotNextY$ THEN
                            robotAlive$(j$) = FALSE
                            liveRobots$     = liveRobots$ - 1
                        END IF
                    END IF
                NEXT
                grid$(robotNextY$, robotNextX$) = " "
                robotAlive$(i$)                  = FALSE
                liveRobots$                      = liveRobots$ - 1

            ELSE
                ' Free cell — robot advances
                robotX$(i$)                     = robotNextX$
                robotY$(i$)                     = robotNextY$
                grid$(robotNextY$, robotNextX$) = "O"
            END IF
        END IF
    NEXT
    IF liveRobots$ <= 0 THEN gameOver$ = TRUE
RETURN
