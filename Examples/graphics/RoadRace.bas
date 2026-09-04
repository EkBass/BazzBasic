' ============================================
' ROAD RACE
' Original concept: "Road Race" from Tim Hartnell's
' Spectravideo Games book. Mechanics reproduced from the
' game description; no original book text is copied.
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    ' --- Track layout (console rows/cols, 1-based via LOCATE) ---
    LET HEADER_ROW#       = 1
    LET ROW_TRACK_TOP#    = 2
    LET ROW_TRACK_BOTTOM# = 19
    LET VIEW_ROWS#        = ROW_TRACK_BOTTOM# - ROW_TRACK_TOP# + 1
    LET CAR_ROW#          = 17
    LET COL_FIELD_LEFT#   = 2
    LET COL_FIELD_RIGHT#  = 37

    ' --- Screen characters ---
    LET LEFT_EDGE_CHAR#  = "<"
    LET RIGHT_EDGE_CHAR# = ">"
    LET CAR_HOOD_CHAR#   = "^"
    LET CAR_WHEEL_CHAR#  = "V"

    ' --- Difficulty / level ---
    ' "level" does triple duty, same as the original: it is the gap
    ' in columns between the two rails (track width), it drives the
    ' frame delay (bigger level = slower car), and it shrinks as the
    ' race goes on - which is what makes the mountain get harder.
    LET MIN_LEVEL_INPUT# = 8
    LET MAX_LEVEL_INPUT# = 30
    LET MIN_TRACK_WIDTH# = 3

    LET STEP_DELAY_PER_UNIT# = 18
    LET MIN_STEP_DELAY#      = 90
    LET POLL_CHUNK_MS#       = 20

    ' Distance milestones where the road narrows / speeds up further
    LET MILESTONE_1# = 100
    LET MILESTONE_2# = 175
    LET MILESTONE_3# = 250
    LET MILESTONE_4# = 350

    LET GOOD_DRIVING_THRESHOLD# = 35
    LET KING_THRESHOLD#         = 60

    ' --- The road itself: one edge column per visible row ---
    DIM edgeCol$

    ' --- Working variables, all declared once up front ---
    LET levelInput$    = 0
    LET level$         = 0
    LET distance$      = 0
    LET carCol$        = 0
    LET key$           = 0
    LET moveDelta$     = 0
    LET wantQuit$      = 0
    LET stepDelayMs$   = 0
    LET numPollChunks$ = 0
    LET driftRoll$     = 0
    LET baseCol$       = 0
    LET carRowIndex$   = 0
    LET again$         = 0
    LET dummy$         = 0
    LET finalScore$    = 0

[main]
    CLS
    COLOR 14, 0
    LOCATE 3, 10
    PRINT "R O A D   R A C E"
    COLOR 7, 0
    LOCATE 5, 4
    PRINT "Keep your wheels on the road as it twists down the"
    LOCATE 6, 4
    PRINT "mountain. The car moves forward on its own - your job"
    LOCATE 7, 4
    PRINT "is to steer between the two rails without clipping one."
    LOCATE 9, 4
    PRINT "Controls:  1 or LEFT arrow  = steer left"
    LOCATE 10, 4
    PRINT "           0 or RIGHT arrow = steer right"
    LOCATE 11, 4
    PRINT "           ESC              = quit"
    LOCATE 12, 4
    PRINT "The level sets road width AND speed - low = narrow &"
    LOCATE 13, 4
    PRINT "fast, high = wide & gentle. Both shrink as you go."

[askLevel]
    LOCATE 15, 4
    INPUT "Choose a level, 8 = hardest, 30 = easiest: ", levelInput$
    level$ = VAL(levelInput$)
    IF NOT BETWEEN(level$, MIN_LEVEL_INPUT#, MAX_LEVEL_INPUT#) THEN
        LOCATE 16, 4
        PRINT "Please enter a whole number between 8 and 30.          "
        GOTO [askLevel]
    END IF

    CLS
    LOCATE 10, 4
    PRINT "Press any key to start the engine..."
    dummy$ = WAITKEY()

[newRace]
    CLS
    distance$ = 0
    carCol$ = COL_FIELD_LEFT# + INT((COL_FIELD_RIGHT# - COL_FIELD_LEFT#) / 2)
    baseCol$ = carCol$ - INT(level$ / 2)
    IF baseCol$ < COL_FIELD_LEFT# THEN
        baseCol$ = COL_FIELD_LEFT#
    END IF
    IF baseCol$ > COL_FIELD_RIGHT# - level$ THEN
        baseCol$ = COL_FIELD_RIGHT# - level$
    END IF

    ' start with a straight stretch of road, centred on the car
    FOR rowIdx$ = 0 TO VIEW_ROWS# - 1
        edgeCol$(rowIdx$) = baseCol$
    NEXT rowIdx$

    GOSUB [sub:drawHud]

[raceLoop]
    WHILE TRUE
        distance$ = distance$ + 1

        IF distance$ = MILESTONE_1# THEN
            level$ = level$ - 1
        END IF
        IF distance$ = MILESTONE_2# THEN
            level$ = level$ - 1
        END IF
        IF distance$ = MILESTONE_3# THEN
            level$ = level$ - 1
        END IF
        IF distance$ = MILESTONE_4# THEN
            level$ = level$ - 2
        END IF
        IF level$ < MIN_TRACK_WIDTH# THEN
            level$ = MIN_TRACK_WIDTH#
        END IF

        ' erase the currently-drawn road before recomputing it
        FOR rowIdx$ = 0 TO VIEW_ROWS# - 1
            LOCATE ROW_TRACK_TOP# + rowIdx$, COL_FIELD_LEFT#
            PRINT REPEAT(" ", COL_FIELD_RIGHT# - COL_FIELD_LEFT# + 1);
        NEXT rowIdx$

        ' extend the road by one new segment at the top - a gentle
        ' three-way random walk (left / straight / right)
        baseCol$ = edgeCol$(0)
        driftRoll$ = RND(3)
        IF driftRoll$ = 0 THEN
            baseCol$ = baseCol$ - 1
        END IF
        IF driftRoll$ = 2 THEN
            baseCol$ = baseCol$ + 1
        END IF
        IF baseCol$ < COL_FIELD_LEFT# THEN
            baseCol$ = COL_FIELD_LEFT#
        END IF
        IF baseCol$ > COL_FIELD_RIGHT# - level$ THEN
            baseCol$ = COL_FIELD_RIGHT# - level$
        END IF

        FOR shiftIdx$ = VIEW_ROWS# - 1 TO 1 STEP -1
            edgeCol$(shiftIdx$) = edgeCol$(shiftIdx$ - 1)
        NEXT shiftIdx$
        edgeCol$(0) = baseCol$

        ' draw the freshly-scrolled road
        COLOR 8, 0
        FOR rowIdx$ = 0 TO VIEW_ROWS# - 1
            LOCATE ROW_TRACK_TOP# + rowIdx$, edgeCol$(rowIdx$)
            PRINT LEFT_EDGE_CHAR#;
            LOCATE ROW_TRACK_TOP# + rowIdx$, edgeCol$(rowIdx$) + level$
            PRINT RIGHT_EDGE_CHAR#;
        NEXT rowIdx$
        COLOR 7, 0

        ' draw the car on top of the road
        COLOR 14, 0
        LOCATE CAR_ROW# - 1, carCol$
        PRINT CAR_HOOD_CHAR#;
        LOCATE CAR_ROW#, carCol$
        PRINT CAR_WHEEL_CHAR#;
        COLOR 7, 0

        GOSUB [sub:drawHud]

        moveDelta$ = 0
        wantQuit$ = 0

        stepDelayMs$ = level$ * STEP_DELAY_PER_UNIT#
        IF stepDelayMs$ < MIN_STEP_DELAY# THEN
            stepDelayMs$ = MIN_STEP_DELAY#
        END IF
        numPollChunks$ = INT(stepDelayMs$ / POLL_CHUNK_MS#)
        IF numPollChunks$ < 1 THEN
            numPollChunks$ = 1
        END IF

        FOR pollStep$ = 1 TO numPollChunks$
            key$ = INKEY
            IF key$ = KEY_ESC# THEN
                wantQuit$ = 1
            END IF
            IF key$ = KEY_1# OR key$ = KEY_LEFT# THEN
                moveDelta$ = -1
            END IF
            IF key$ = KEY_0# OR key$ = KEY_RIGHT# THEN
                moveDelta$ = 1
            END IF
            SLEEP POLL_CHUNK_MS#
        NEXT pollStep$

        IF wantQuit$ = 1 THEN GOTO [quitEarly]

        carCol$ = carCol$ + moveDelta$
        IF carCol$ < COL_FIELD_LEFT# THEN
            carCol$ = COL_FIELD_LEFT#
        END IF
        IF carCol$ > COL_FIELD_RIGHT# THEN
            carCol$ = COL_FIELD_RIGHT#
        END IF

        ' the car's screen row is fixed, but the edge value STORED
        ' at that row's array index changes every tick as the road
        ' scrolls through it - so this always checks "what's here now"
        carRowIndex$ = CAR_ROW# - ROW_TRACK_TOP#
        IF carCol$ <= edgeCol$(carRowIndex$) THEN GOTO [crashed]
        IF carCol$ >= edgeCol$(carRowIndex$) + level$ THEN GOTO [crashed]
    WEND

[crashed]
    finalScore$ = INT(distance$ / level$)

    CLS
    COLOR 12, 0
    LOCATE 10, 6
    PRINT "CRASH! You clipped the rail."
    LOCATE 11, 6
    PRINT "Distance: "; distance$; "   Score: "; finalScore$
    COLOR 7, 0

    IF finalScore$ > KING_THRESHOLD# THEN
        LOCATE 12, 6
        PRINT "King of the Mountain material!"
    ELSEIF finalScore$ > GOOD_DRIVING_THRESHOLD# THEN
        LOCATE 12, 6
        PRINT "Good driving!"
    ELSE
        LOCATE 12, 6
        PRINT "The mountain wins again. Give it another shot?"
    END IF

    LOCATE 14, 6
    PRINT "Play again? (Y/N)"

    again$ = WAITKEY(KEY_Y#, KEY_N#)
    IF again$ = KEY_Y# THEN GOTO [main]

    CLS
    LOCATE 10, 6
    PRINT "Thanks for playing ROAD RACE!"
    END

[quitEarly]
    finalScore$ = INT(distance$ / level$)
    CLS
    LOCATE 10, 6
    PRINT "You pulled over at distance "; distance$; "   Score: "; finalScore$
    END

' ================= SUBROUTINES =================

[sub:drawHud]
    LOCATE HEADER_ROW#, COL_FIELD_LEFT#
    COLOR 15, 0
    PRINT "LEVEL "; level$; "   DISTANCE "; distance$; "          ";
    COLOR 7, 0
RETURN
