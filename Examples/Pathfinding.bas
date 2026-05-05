' ============================================
' A* Pathfinding on a Random Grid
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Design notes
' ------------
' A* state is held in flat single-key associative arrays. The cell (x, y)
' becomes the string key "x,y". This sidesteps HASKEY's single-key
' restriction and keeps every lookup uniform.
'
'   wall$("x,y")      = 1  if cell is a wall (absent if walkable)
'   gScore$("x,y")    = cost from start to this cell
'   fScore$("x,y")    = gScore + Manhattan heuristic to goal
'   openSet$("x,y")   = 1  if cell is on the frontier
'   closedSet$("x,y") = 1  if cell has been expanded
'   parent$("x,y")    = "px,py"  (predecessor key) — drives backtracking
'
' Heuristic: Manhattan distance, exact for 4-directional movement.
' Open-set selection: linear scan O(N). Fine for 30x30. A real engine
' would use a binary heap; BazzBasic doesn't ship one.
' ============================================

[inits]
    ' --- Grid ---
    LET COLS#        = 30
    LET ROWS#        = 30
    LET CELL_W#      = 640 / COLS#
    LET CELL_H#      = 480 / ROWS#
    LET WALL_PCT#    = 28          ' approx. wall density (%)

    ' --- Colours ---
    LET COL_BG#      = RGB(45, 197, 244)
    LET COL_WALL#    = RGB(0, 0, 0)
    LET COL_OPEN#    = RGB(255, 255, 255)
    LET COL_CLOSED#  = RGB(180, 180, 180)
    LET COL_PATH#    = RGB(252, 238, 33)
    LET COL_START#   = RGB(0, 200, 0)
    LET COL_GOAL#    = RGB(220, 0, 0)

    ' --- Start / goal ---
    LET START_X#     = 0
    LET START_Y#     = 0
    LET GOAL_X#      = COLS# - 1
    LET GOAL_Y#      = ROWS# - 1
    LET START_KEY#   = START_X# + "," + START_Y#
    LET GOAL_KEY#    = GOAL_X#  + "," + GOAL_Y#

    ' --- A* state ---
    DIM wall$
    DIM gScore$
    DIM fScore$
    DIM openSet$
    DIM closedSet$
    DIM parent$

    ' --- Neighbour offsets (4-directional) ---
    DIM dx$
    DIM dy$
    dx$(0) =  0 : dy$(0) = -1     ' up
    dx$(1) =  0 : dy$(1) =  1     ' down
    dx$(2) = -1 : dy$(2) =  0     ' left
    dx$(3) =  1 : dy$(3) =  0     ' right

    ' --- Working scalars (declared once, reassigned freely) ---
    LET i$         = 0
    LET j$         = 0
    LET n$         = 0
    LET cx$        = 0
    LET cy$        = 0
    LET nx$        = 0
    LET ny$        = 0
    LET tempG$     = 0
    LET minF$      = 0
    LET commaPos$  = 0
    LET key$       = ""
    LET nKey$      = ""
    LET winnerKey$ = ""
    LET pathKey$   = ""
    LET parentKey$ = ""
    LET px$        = 0
    LET py$        = 0
    LET wx1$       = 0
    LET wy1$       = 0
    LET wx2$       = 0
    LET wy2$       = 0
    LET sx1$       = 0
    LET sy1$       = 0
    LET sx2$       = 0
    LET sy2$       = 0
    LET cxDot$     = 0
    LET cyDot$     = 0
    LET done$      = FALSE
    LET noPath$    = FALSE
    LET dummy$     = 0

    ' --- Build random walls; keep start and goal walkable ---
    FOR i$ = 0 TO COLS# - 1
        FOR j$ = 0 TO ROWS# - 1
            IF RND(100) < WALL_PCT# THEN
                wall$(i$ + "," + j$) = 1
            END IF
        NEXT
    NEXT
    IF HASKEY(wall$(START_KEY#)) THEN DELKEY wall$(START_KEY#)
    IF HASKEY(wall$(GOAL_KEY#))  THEN DELKEY wall$(GOAL_KEY#)

    ' --- Seed the open set with the start node ---
    gScore$(START_KEY#) = 0
    fScore$(START_KEY#) = ABS(START_X# - GOAL_X#) + ABS(START_Y# - GOAL_Y#)
    openSet$(START_KEY#) = 1

    SCREEN 0, 640, 480, "BazzBasic A* Pathfinder"

[main]
    WHILE done$ = FALSE AND noPath$ = FALSE
        GOSUB [sub:pick_lowest_f]

        IF winnerKey$ = "" THEN
            noPath$ = TRUE
        ELSE
            ' Decode "x,y" into cx$, cy$ without reusing a SPLIT array
            commaPos$ = INSTR(winnerKey$, ",")
            cx$ = VAL(LEFT(winnerKey$, commaPos$ - 1))
            cy$ = VAL(MID(winnerKey$,  commaPos$ + 1))

            IF winnerKey$ = GOAL_KEY# THEN
                done$ = TRUE
            ELSE
                DELKEY openSet$(winnerKey$)
                closedSet$(winnerKey$) = 1
                GOSUB [sub:expand_neighbours]
            END IF
        END IF

        GOSUB [sub:draw_frame]
        SLEEP 10
    WEND

    GOSUB [sub:draw_frame]                 ' final frame with full path
    LOCATE 1, 1
    COLOR 15, 0
    IF noPath$ = TRUE THEN
        PRINT "No path exists from start to goal."
    ELSE
        PRINT "Path found. Press any key to exit."
    END IF
    dummy$ = WAITKEY()
END

' --------------------------------------------
' Pick the open-set node with the lowest fScore.
' Linear scan — O(grid). Sets winnerKey$ ("" if open set empty).
' --------------------------------------------
[sub:pick_lowest_f]
    winnerKey$ = ""
    minF$ = 999999
    FOR i$ = 0 TO COLS# - 1
        FOR j$ = 0 TO ROWS# - 1
            key$ = i$ + "," + j$
            IF HASKEY(openSet$(key$)) THEN
                IF fScore$(key$) < minF$ THEN
                    minF$ = fScore$(key$)
                    winnerKey$ = key$
                END IF
            END IF
        NEXT
    NEXT
RETURN

' --------------------------------------------
' Expand the four orthogonal neighbours of (cx$, cy$).
' Updates gScore, fScore, parent, and openSet on improvements.
' --------------------------------------------
[sub:expand_neighbours]
    FOR n$ = 0 TO 3
        nx$ = cx$ + dx$(n$)
        ny$ = cy$ + dy$(n$)
        IF nx$ >= 0 AND nx$ < COLS# AND ny$ >= 0 AND ny$ < ROWS# THEN
            nKey$ = nx$ + "," + ny$
            IF HASKEY(wall$(nKey$)) = 0 AND HASKEY(closedSet$(nKey$)) = 0 THEN
                tempG$ = gScore$(winnerKey$) + 1

                IF HASKEY(openSet$(nKey$)) = 0 THEN
                    ' First time discovering this neighbour
                    openSet$(nKey$) = 1
                    gScore$(nKey$)  = tempG$
                    fScore$(nKey$)  = tempG$ + ABS(nx$ - GOAL_X#) + ABS(ny$ - GOAL_Y#)
                    parent$(nKey$)  = winnerKey$
                ELSE
                    ' Already on frontier — accept only if cheaper
                    IF tempG$ < gScore$(nKey$) THEN
                        gScore$(nKey$) = tempG$
                        fScore$(nKey$) = tempG$ + ABS(nx$ - GOAL_X#) + ABS(ny$ - GOAL_Y#)
                        parent$(nKey$) = winnerKey$
                    END IF
                END IF
            END IF
        END IF
    NEXT
RETURN

' --------------------------------------------
' One animation frame: background, walls, closed cells,
' open frontier, partial/full path, start and goal markers.
' --------------------------------------------
[sub:draw_frame]
    SCREENLOCK ON
    LINE (0, 0)-(640, 480), COL_BG#, BF

    ' Walls
    FOR i$ = 0 TO COLS# - 1
        FOR j$ = 0 TO ROWS# - 1
            IF HASKEY(wall$(i$ + "," + j$)) THEN
                wx1$ = i$ * CELL_W#
                wy1$ = j$ * CELL_H#
                wx2$ = wx1$ + CELL_W# - 1
                wy2$ = wy1$ + CELL_H# - 1
                LINE (wx1$, wy1$)-(wx2$, wy2$), COL_WALL#, BF
            END IF
        NEXT
    NEXT

    ' Closed set (cells already expanded)
    FOR i$ = 0 TO COLS# - 1
        FOR j$ = 0 TO ROWS# - 1
            IF HASKEY(closedSet$(i$ + "," + j$)) THEN
                cxDot$ = i$ * CELL_W# + CELL_W# / 2
                cyDot$ = j$ * CELL_H# + CELL_H# / 2
                CIRCLE (cxDot$, cyDot$), 2, COL_CLOSED#, 1
            END IF
        NEXT
    NEXT

    ' Open set (frontier)
    FOR i$ = 0 TO COLS# - 1
        FOR j$ = 0 TO ROWS# - 1
            IF HASKEY(openSet$(i$ + "," + j$)) THEN
                cxDot$ = i$ * CELL_W# + CELL_W# / 2
                cyDot$ = j$ * CELL_H# + CELL_H# / 2
                CIRCLE (cxDot$, cyDot$), 3, COL_OPEN#, 1
            END IF
        NEXT
    NEXT

    ' Path: backtrack from the most-recently-expanded node along parent$.
    ' During search this animates the best-known route to that node;
    ' on the final frame it is the full start->goal path.
    IF winnerKey$ <> "" THEN
        pathKey$ = winnerKey$
        px$ = cx$
        py$ = cy$
        WHILE HASKEY(parent$(pathKey$))
            parentKey$ = parent$(pathKey$)
            commaPos$  = INSTR(parentKey$, ",")
            nx$ = VAL(LEFT(parentKey$, commaPos$ - 1))
            ny$ = VAL(MID(parentKey$,  commaPos$ + 1))
            sx1$ = px$ * CELL_W# + CELL_W# / 2
            sy1$ = py$ * CELL_H# + CELL_H# / 2
            sx2$ = nx$ * CELL_W# + CELL_W# / 2
            sy2$ = ny$ * CELL_H# + CELL_H# / 2
            LINE (sx1$, sy1$)-(sx2$, sy2$), COL_PATH#
            px$ = nx$
            py$ = ny$
            pathKey$ = parentKey$
        WEND
    END IF

    ' Start and goal markers (drawn last so they sit on top)
    cxDot$ = START_X# * CELL_W# + CELL_W# / 2
    cyDot$ = START_Y# * CELL_H# + CELL_H# / 2
    CIRCLE (cxDot$, cyDot$), 5, COL_START#, 1

    cxDot$ = GOAL_X# * CELL_W# + CELL_W# / 2
    cyDot$ = GOAL_Y# * CELL_H# + CELL_H# / 2
    CIRCLE (cxDot$, cyDot$), 5, COL_GOAL#, 1

    SCREENLOCK OFF
RETURN
