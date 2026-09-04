' ============================================
' MINEFIELD
' Original concept: "Minefield" from Tim Hartnell's
' Spectravideo Games book. Mechanics reproduced from the
' game description; no original book text is copied.
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    ' --- Field layout (console rows/cols, 1-based via LOCATE) ---
    LET HEADER_ROW#           = 1
    LET ROW_FENCE_TOP#        = 2
    LET ROW_FIELD_TOP#        = 3
    LET ROW_FIELD_BOTTOM#     = 20
    LET ROW_FENCE_BOTTOM#     = 21
    LET COL_FENCE_LEFT#       = 1
    LET COL_FIELD_LEFT#       = 2
    LET COL_FIELD_RIGHT#      = 29
    LET COL_FENCE_RIGHT#      = 30
    ' Mines stop two rows above the start row, so the man
    ' always gets a couple of safe steps before the danger begins.
    LET MINE_ZONE_ROW_BOTTOM# = ROW_FIELD_BOTTOM# - 2

    ' --- Gameplay tuning ---
    LET MINE_COUNT#           = 65
    LET STEP_SCORE#           = 10
    LET CROSS_BONUS#          = 250
    LET CRASH_PENALTY#        = 100
    LET STEP_DELAY_PER_LEVEL# = 45
    LET MIN_STEP_DELAY#       = 120
    LET POLL_CHUNK_MS#        = 20
    LET MIN_LEVEL#            = 1
    LET MAX_LEVEL#            = 30

    ' --- Screen characters ---
    LET FENCE_CHAR#  = "#"
    LET MINE_CHAR#   = "*"
    LET PLAYER_CHAR# = "+"

    ' --- Working variables, all declared once up front ---
    LET levelInput$    = 0
    LET level$         = 0
    LET score$         = 0
    LET manRow$        = 0
    LET manCol$        = 0
    LET key$           = 0
    LET moveDelta$     = 0
    LET wantQuit$      = 0
    LET stepDelayMs$   = 0
    LET numPollChunks$ = 0
    LET aheadChar$     = 0
    LET crossBonus$    = 0
    LET again$         = 0
    LET dummy$         = 0
    LET mineRow$       = 0
    LET mineCol$       = 0

[main]
    CLS
    COLOR 14, 0
    LOCATE 3, 8
    PRINT "M I N E F I E L D"
    COLOR 7, 0
    LOCATE 5, 4
    PRINT "Cross the minefield to reach your comrades at the front."
    LOCATE 6, 4
    PRINT "You advance automatically - steer left and right to dodge"
    LOCATE 7, 4
    PRINT "the mines. Every field you clear gets a little faster."
    LOCATE 9, 4
    PRINT "Controls:  1 or LEFT arrow  = step left"
    LOCATE 10, 4
    PRINT "           0 or RIGHT arrow = step right"
    LOCATE 11, 4
    PRINT "           ESC              = quit"

[askLevel]
    LOCATE 13, 4
    INPUT "Choose a level, 1 = fastest/hardest, 30 = slowest/easiest: ", levelInput$
    level$ = VAL(levelInput$)
    IF NOT BETWEEN(level$, MIN_LEVEL#, MAX_LEVEL#) THEN
        LOCATE 14, 4
        PRINT "Please enter a whole number between 1 and 30.          "
        GOTO [askLevel]
    END IF

    CLS
    LOCATE 10, 4
    PRINT "Press any key to enter the minefield..."
    dummy$ = WAITKEY()

    score$ = 0

[newField]
    CLS
    GOSUB [sub:drawFence]
    GOSUB [sub:scatterMines]
    GOSUB [sub:placeMan]
    GOSUB [sub:drawHud]

    LOCATE ROW_FENCE_BOTTOM# + 1, COL_FENCE_LEFT#
    COLOR 8, 0
    PRINT "1/LEFT = left    0/RIGHT = right    ESC = quit"
    COLOR 7, 0

[playLoop]
    WHILE manRow$ >= ROW_FIELD_TOP#
        score$ = score$ + STEP_SCORE#

        LOCATE manRow$, manCol$
        COLOR 10, 0
        PRINT PLAYER_CHAR#;
        COLOR 7, 0

        moveDelta$ = 0
        wantQuit$ = 0

        ' Speed is driven by the difficulty level: lower level = faster.
        stepDelayMs$ = level$ * STEP_DELAY_PER_LEVEL#
        IF stepDelayMs$ < MIN_STEP_DELAY# THEN
            stepDelayMs$ = MIN_STEP_DELAY#
        END IF

        ' Break the step delay into small chunks so we can sample
        ' the keyboard repeatedly instead of only once per row.
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

        ' Only one GOTO out of the loop nesting here (out of WHILE,
        ' after the FOR has already finished on its own) - see notes.
        IF wantQuit$ = 1 THEN GOTO [quitEarly]

        manCol$ = manCol$ + moveDelta$
        IF manCol$ < COL_FIELD_LEFT# THEN
            manCol$ = COL_FIELD_LEFT#
        END IF
        IF manCol$ > COL_FIELD_RIGHT# THEN
            manCol$ = COL_FIELD_RIGHT#
        END IF

        manRow$ = manRow$ - 1

        IF manRow$ >= ROW_FIELD_TOP# THEN
            aheadChar$ = GETCONSOLE(manRow$, manCol$, 0)
            IF aheadChar$ = ASC(MINE_CHAR#) THEN GOTO [crashed]
        END IF

        GOSUB [sub:drawHud]
    WEND

[crossed]
    crossBonus$ = CROSS_BONUS# + (MAX_LEVEL# - level$) * 10
    score$ = score$ + crossBonus$

    CLS
    COLOR 10, 0
    LOCATE 10, 6
    PRINT "WELL DONE! You reached the front line."
    LOCATE 11, 6
    PRINT "Score so far: "; score$
    COLOR 7, 0
    LOCATE 13, 6
    PRINT "Get ready... it's about to get faster."

    level$ = level$ - INT(level$ / 3)
    IF level$ < MIN_LEVEL# THEN
        level$ = MIN_LEVEL#
    END IF

    SLEEP 1500
    GOTO [newField]

[crashed]
    GOSUB [sub:explosion]

    score$ = score$ - CRASH_PENALTY#
    IF score$ < 0 THEN
        score$ = 0
    END IF

    CLS
    COLOR 12, 0
    LOCATE 10, 6
    PRINT "BOOM! You hit a mine."
    LOCATE 11, 6
    PRINT "Final score: "; score$
    COLOR 7, 0
    LOCATE 13, 6
    PRINT "Play again? (Y/N)"

    again$ = WAITKEY(KEY_Y#, KEY_N#)
    IF again$ = KEY_Y# THEN GOTO [main]

    CLS
    LOCATE 10, 6
    PRINT "Thanks for playing MINEFIELD!"
    END

[quitEarly]
    CLS
    LOCATE 10, 6
    PRINT "You stopped at score: "; score$
    END

' ================= SUBROUTINES =================

[sub:drawFence]
    COLOR 8, 0
    FOR fenceCol$ = COL_FENCE_LEFT# TO COL_FENCE_RIGHT#
        LOCATE ROW_FENCE_TOP#, fenceCol$
        PRINT FENCE_CHAR#;
        LOCATE ROW_FENCE_BOTTOM#, fenceCol$
        PRINT FENCE_CHAR#;
    NEXT fenceCol$

    FOR fenceRow$ = ROW_FENCE_TOP# TO ROW_FENCE_BOTTOM#
        LOCATE fenceRow$, COL_FENCE_LEFT#
        PRINT FENCE_CHAR#;
        LOCATE fenceRow$, COL_FENCE_RIGHT#
        PRINT FENCE_CHAR#;
    NEXT fenceRow$
    COLOR 7, 0
RETURN

[sub:scatterMines]
    COLOR 4, 0
    FOR mineIdx$ = 1 TO MINE_COUNT#
        mineRow$ = ROW_FIELD_TOP# + RND(MINE_ZONE_ROW_BOTTOM# - ROW_FIELD_TOP# + 1)
        mineCol$ = COL_FIELD_LEFT# + RND(COL_FIELD_RIGHT# - COL_FIELD_LEFT# + 1)
        LOCATE mineRow$, mineCol$
        PRINT MINE_CHAR#;
    NEXT mineIdx$
    COLOR 7, 0
RETURN

[sub:placeMan]
    manRow$ = ROW_FIELD_BOTTOM#
    manCol$ = COL_FIELD_LEFT# + RND(COL_FIELD_RIGHT# - COL_FIELD_LEFT# + 1)

    ' Guarantee a fair start: clear any mine that landed on the
    ' man's starting square before he steps onto it.
    LOCATE manRow$, manCol$
    COLOR 0, 0
    PRINT " ";
    LOCATE manRow$, manCol$
    COLOR 10, 0
    PRINT PLAYER_CHAR#;
    COLOR 7, 0
RETURN

[sub:drawHud]
    LOCATE HEADER_ROW#, COL_FIELD_LEFT#
    COLOR 15, 0
    PRINT "LEVEL "; level$; "   SCORE "; score$; "          ";
    COLOR 7, 0
RETURN

[sub:explosion]
    FOR explodeIdx$ = 1 TO 4
        LOCATE manRow$, manCol$
        COLOR 14, 4
        PRINT "*";
        SLEEP 90
        LOCATE manRow$, manCol$
        COLOR 4, 0
        PRINT "X";
        SLEEP 90
    NEXT explodeIdx$
    COLOR 7, 0
RETURN
