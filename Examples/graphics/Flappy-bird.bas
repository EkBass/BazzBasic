' ============================================
' Flappy — flap-to-survive mini game
' Ported from the Python/turtle "flappy" example
' (freegames library, Grant Jenks) to BazzBasic
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Original mechanics (1:1 ported):
'   - the bird falls constantly under gravity
'   - clicking gives the bird a single upward flap
'   - black balls scroll in from the right edge
'   - touching a ball, or leaving the play field, ends the game
' Additions beyond the original script:
'   - a running score (the original left this as an exercise)
'   - SPACE bar as an extra flap control, alongside the mouse click
'   - a thin border marking the play field boundary
'   - an explicit "GAME OVER" screen instead of just freezing
' Fix (v2): ball array indices are now tracked with our own
' monotonic counter (nextBallId$ / maxBallId$) instead of relying
' on ROWCOUNT() after DELKEY - see chat explanation for why.
' ============================================

DEF FN HitTest$(x1$, y1$, x2$, y2$, r$)
    IF DISTANCE(x1$, y1$, x2$, y2$) < r$ THEN RETURN 1
    RETURN 0
END DEF

[inits]
    ' --- window ---
    LET WIDTH#  = 420
    LET HEIGHT# = 420
    SCREEN 0, WIDTH#, HEIGHT#, "Flappy - BazzBasic"

    ' --- tuning constants, matched to the original Python values ---
    LET MARGIN#      = 10   ' play field is 10px smaller than the window on every side
    LET GRAVITY#      = 5   ' bird.y -= 5 every tick
    LET FLAP_POWER#   = 30  ' up = vector(0, 30)
    LET BALL_SPEED#   = 3   ' ball.x -= 3 every tick
    LET BALL_RADIUS#  = 10  ' dot(20, 'black')  -> diameter 20
    LET BIRD_RADIUS#  = 5   ' dot(10, ...)      -> diameter 10
    LET HIT_DIST#     = 15  ' abs(ball - bird) < 15
    LET TICK_MS#      = 50  ' ontimer(move, 50)
    LET SPAWN_CHANCE# = 10  ' randrange(10) == 0

    ' --- colors ---
    LET BG_COL#         = RGB(255, 255, 255)
    LET BIRD_ALIVE_COL# = RGB(0, 150, 0)
    LET BIRD_DEAD_COL#  = RGB(220, 0, 0)
    LET BALL_COL#       = RGB(0, 0, 0)
    LET BORDER_COL#     = RGB(210, 210, 210)
    LET TEXT_COL#       = RGB(40, 40, 40)

    ' --- game state ---
    LET birdX$    = WIDTH# / 4
    LET birdY$    = HEIGHT# / 2
    LET alive$    = TRUE
    LET running$  = TRUE
    LET score$    = 0
    LET lastTick$ = TICKS

    ' click/keypress are HELD states in BazzBasic - track the previous
    ' frame's value so a flap fires once per press, not once per frame
    LET mLeft$     = 0
    LET spaceDown$ = 0
    LET prevClick$ = 0
    LET prevSpace$ = 0

    DIM ballsX$
    DIM ballsY$
    LET nextBallId$ = 0   ' next array index to use - never reused
    LET maxBallId$  = -1  ' highest index assigned so far (loop upper bound)

[main]
    WHILE running$
        IF INKEY = KEY_ESC# THEN running$ = FALSE

        ' --- input: flap on a fresh click or a fresh space press ---
        mLeft$     = MOUSELEFT
        spaceDown$ = KEYDOWN(KEY_SPACE#)

        IF alive$ THEN
            IF (mLeft$ = 1 AND prevClick$ = 0) OR (spaceDown$ = 1 AND prevSpace$ = 0) THEN
                birdY$ -= FLAP_POWER#
            END IF
        END IF

        prevClick$ = mLeft$
        prevSpace$ = spaceDown$

        ' --- fixed-step game logic, same 50ms cadence as the original ---
        IF alive$ AND (TICKS - lastTick$ >= TICK_MS#) THEN
            GOSUB [sub:update]
            lastTick$ = TICKS
        END IF

        GOSUB [sub:draw]

        IF NOT alive$ THEN
            GOSUB [sub:gameOver]
            running$ = FALSE
        END IF

        SLEEP 16
    WEND
END

[sub:update]
    ' gravity
    birdY$ += GRAVITY#

    ' move balls; a ball that scrolls past the left edge is dodged
    IF maxBallId$ >= 0 THEN
        FOR i$ = 0 TO maxBallId$
            IF HASKEY(ballsX$(i$)) THEN
                ballsX$(i$) -= BALL_SPEED#
                IF ballsX$(i$) < MARGIN# THEN
                    DELKEY ballsX$(i$) : DELKEY ballsY$(i$)
                    score$ += 1
                END IF
            END IF
        NEXT
    END IF

    ' occasionally spawn a new ball from the right edge
    IF RND(SPAWN_CHANCE#) = 0 THEN GOSUB [sub:spawnBall]

    ' died by leaving the play field
    IF NOT (INBETWEEN(birdX$, MARGIN#, WIDTH# - MARGIN#) AND INBETWEEN(birdY$, MARGIN#, HEIGHT# - MARGIN#)) THEN
        alive$ = FALSE
    END IF

    ' died by hitting a ball
    IF alive$ AND maxBallId$ >= 0 THEN
        FOR i$ = 0 TO maxBallId$
            IF HASKEY(ballsX$(i$)) THEN
                IF FN HitTest$(ballsX$(i$), ballsY$(i$), birdX$, birdY$, HIT_DIST#) THEN
                    alive$ = FALSE
                END IF
            END IF
        NEXT
    END IF
RETURN

[sub:spawnBall]
    ballsX$(nextBallId$) = WIDTH# - MARGIN#
    ballsY$(nextBallId$) = RND(HEIGHT# - (2 * MARGIN#)) + MARGIN#
    maxBallId$  = nextBallId$
    nextBallId$ += 1
RETURN

[sub:draw]
    SCREENLOCK ON
        LINE (0, 0)-(WIDTH#, HEIGHT#), BG_COL#, BF
        LINE (MARGIN#, MARGIN#)-(WIDTH# - MARGIN#, HEIGHT# - MARGIN#), BORDER_COL#, B

        IF maxBallId$ >= 0 THEN
            FOR i$ = 0 TO maxBallId$
                IF HASKEY(ballsX$(i$)) THEN
                    CIRCLE (ballsX$(i$), ballsY$(i$)), BALL_RADIUS#, BALL_COL#, 1
                END IF
            NEXT
        END IF

        IF alive$ THEN
            CIRCLE (birdX$, birdY$), BIRD_RADIUS#, BIRD_ALIVE_COL#, 1
        ELSE
            CIRCLE (birdX$, birdY$), BIRD_RADIUS#, BIRD_DEAD_COL#, 1
        END IF

        DRAWSTRING "Score: " + STR(score$), 14, 14, TEXT_COL#
        DRAWSTRING "Click / SPACE = flap   ESC = quit", 14, HEIGHT# - 28, TEXT_COL#
    SCREENLOCK OFF
RETURN

[sub:gameOver]
    SCREENLOCK ON
        DRAWSTRING "GAME OVER", 170, 180, BIRD_DEAD_COL#
        DRAWSTRING "Final score: " + STR(score$), 140, 204, TEXT_COL#
    SCREENLOCK OFF
    SLEEP 2500
RETURN

' Output:
' A 420x420 window opens. The bird (green dot) falls under gravity;
' clicking the window or pressing SPACE flaps it upward. Black balls
' scroll in from the right at random heights, correctly persisting
' until they reach the left margin regardless of how many have been
' spawned or removed before them. Dodging a ball scores a point;
' touching one, or drifting off the play field, ends the round.