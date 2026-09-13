' ============================================
' Cannon
' Fire a cannonball toward the mouse cursor and pop the
' targets drifting in from the right before one slips past.
' Ported from Python (turtle + the "freegames" package's cannon.py)
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
'
' Differences from the original Python version (documented on purpose,
' per project convention - deviations from source behavior are always
' called out rather than silently baked in):
'
'   1. MISSING CANNON (why you asked for this port in the first place):
'      the original never actually drew a cannon - only a red dot for
'      the ball and blue dots for targets. This port adds a small
'      wheel+turret+barrel shape at the launch corner, and the barrel
'      rotates to track the mouse cursor at all times as an aiming aid,
'      even before you click.
'
'   2. SCORE (Exercise #1 from the original file's own comment block:
'      "Keep score by counting target hits.") is implemented - see
'      score$ below. Exercises #2 ("vary gravity") and #3 ("apply
'      gravity to targets") are intentionally left undone here,
'      matching the source file's own scope - nothing stops you from
'      tackling those next.
'
'   3. GAME OVER FEEDBACK: in the Python original, once any target
'      slips past the left edge uncaught, the code simply stops
'      re-arming its own animation timer - the window freezes with no
'      message. That is a silent dead-end, not a real "game over".
'      This port instead shows a clear GAME OVER screen with the
'      final score.
'
'   4. "DEAD BALL" HIT-CHECK BUG FIXED: in the original, hit-testing
'      target vs ball runs every tick regardless of whether the ball
'      is currently in flight. Because the ball's resting position
'      between shots is never reset until the next tap, a target that
'      happens to wander near wherever the ball last landed could be
'      scored as a "hit" with no ball ever fired at it. Here, hits are
'      only checked while ballActive$ = TRUE, so idle targets can
'      never be falsely scored.
'
'   5. PHYSICS SCALED TO A BIGGER CANVAS: the original turtle world is
'      roughly 400 units wide (-200 to 200). This port uses a 640x640
'      graphics window instead, for a more comfortable size on a modern
'      screen. Gravity, target speed, hit radius and spawn margins are
'      all multiplied by SCALE# (= WIDTH# / 400) so the game *feels*
'      the same as the original, just drawn bigger - see SCALE# below.
'      The launch-speed divisor is deliberately left unscaled: the
'      mouse position it is measured against already ranges over the
'      full, bigger window, so the resulting launch speed scales up on
'      its own without touching that constant.
'
'   6. GROWING/SHRINKING TARGET LIST: targets are added and removed
'      constantly. Rather than reusing ROWCOUNT(targetsX$()) as the
'      "next index" to append at (which risks colliding with an
'      existing key once earlier targets have been DELKEY'd out,
'      since numeric array keys are not confirmed to be re-packed by
'      DELKEY), this port keeps its own ever-increasing
'      nextTargetId$ counter as the array key. That is correct
'      regardless of how DELKEY handles the resulting gaps internally.
'
'   7. AIM_BOOST# (added after real-world testing, not in the original
'      at all): the launch-speed formula in note #5 reproduces the
'      Python original exactly, but rise distance scales with the
'      *square* of launch speed, so reaching the top of the screen
'      needed an almost pixel-perfect click at the very top edge.
'      AIM_BOOST# gives the shot extra headroom so a realistic click
'      near the top actually reaches the top - see the constant
'      itself for the numbers.
'
' Controls: move the mouse to aim, left-click to fire, ESC to quit.
' ============================================

[inits]
    ' --- Screen ---
    LET WIDTH#  = 640
    LET HEIGHT# = 640
    SCREEN 0, WIDTH#, HEIGHT#, "Cannon - BazzBasic (ported from Python)"

    ' --- Scale factor: see note #5 above ---
    LET SCALE# = WIDTH# / 400

    ' --- Tuned physics constants, scaled from the Python original ---
    LET GRAVITY#       = 0.35 * SCALE#   ' downward speed added to the ball every tick
    LET TARGET_SPEED#  = 0.5  * SCALE#   ' how fast targets drift left, per tick
    LET HIT_RADIUS#    = 13   * SCALE#   ' ball-to-target distance that counts as a hit
    LET LAUNCH_SCALE#  = 25              ' unscaled on purpose, see note #5
    LET AIM_BOOST#     = 4               ' confirmed via testing: without this, reaching the
                                          ' top of the screen needs an almost pixel-perfect
                                          ' click at the very top edge - rise scales with
                                          ' velocity squared, so realistic (not edge-perfect)
                                          ' clicks fall well short without the extra headroom
    LET TICK_MS#       = 50              ' game-logic step, matches the original's ontimer(move, 50)
    LET SPAWN_CHANCE#  = 40              ' 1-in-40 chance per tick a new target appears
    LET MARGIN#        = 50 * SCALE#     ' top/bottom no-spawn margin for targets

    ' --- Cannon position and shape (bottom-left corner, like the original's launch point) ---
    LET CANNON_X#      = 40
    LET CANNON_Y#      = HEIGHT# - 40
    LET TURRET_RADIUS# = 16
    LET WHEEL_RADIUS#  = 10
    LET BARREL_LEN#    = 40
    LET BARREL_HALF_W# = 3

    ' --- Sprite sizes, scaled the same way as the physics constants ---
    LET TARGET_RADIUS# = 10 * SCALE#
    LET BALL_RADIUS#   = 3  * SCALE#

    ' --- Colors ---
    LET BG_COL#       = RGB(16, 16, 34)
    LET GROUND_COL#   = RGB(40, 70, 35)
    LET CANNON_COL#   = RGB(90, 90, 100)
    LET WHEEL_COL#    = RGB(35, 35, 40)
    LET BALL_COL#     = RGB(230, 60, 60)
    LET TARGET_COL#   = RGB(70, 140, 235)
    LET TEXT_COL#     = RGB(240, 240, 240)
    LET GAMEOVER_COL# = RGB(255, 90, 90)

    ' --- Game state ---
    LET running$      = TRUE
    LET missed$       = FALSE
    LET score$        = 0
    LET lastMoveTime$ = TICKS

    ' --- Ball state (inactive = resting at the cannon, ready to fire) ---
    LET ballActive$  = FALSE
    LET ballX$       = 0
    LET ballY$       = 0
    LET ballSpeedX$  = 0
    LET ballSpeedY$  = 0

    ' --- Mouse click edge-detection (MOUSELEFT reports "held", not "clicked") ---
    LET prevL$ = 0
    LET curL$  = 0

    ' --- Cannon aiming visuals, recomputed every frame in [sub:draw] ---
    LET aimAngle$   = 0
    LET barrelEndX$ = 0
    LET barrelEndY$ = 0
    LET perpX$      = 0
    LET perpY$      = 0

    ' --- Targets: parallel dynamic arrays, keyed by an ever-increasing id (see note #6) ---
    DIM targetsX$
    DIM targetsY$
    LET nextTargetId$ = 0

[main]
    WHILE running$
        IF INKEY = KEY_ESC# THEN running$ = FALSE

        GOSUB [sub:handleInput]

        IF TICKS - lastMoveTime$ > TICK_MS# THEN
            GOSUB [sub:spawnTarget]
            GOSUB [sub:moveTargets]
            GOSUB [sub:moveBall]
            GOSUB [sub:checkHits]
            GOSUB [sub:checkMisses]
            lastMoveTime$ = TICKS
        END IF

        GOSUB [sub:draw]
        SLEEP 16 ' ~60 FPS for smooth mouse tracking; game logic runs on its own TICK_MS# clock above
    WEND

    IF missed$ THEN
        GOSUB [sub:drawGameOver]
        SLEEP 3000
    END IF
END ' keep END here so the program never falls through into the subs below

' ------------------------------------------------------------
' Input
' ------------------------------------------------------------

[sub:handleInput]
    curL$ = MOUSELEFT
    ' Rising edge (0 -> 1) only, and only while no ball is currently
    ' in flight - matches the original's "if not inside(ball): fire"
    IF curL$ = 1 AND prevL$ = 0 AND NOT ballActive$ THEN
        GOSUB [sub:fireBall]
    END IF
    prevL$ = curL$
RETURN

[sub:fireBall]
    ' Launch from just off the cannon's corner, toward wherever the
    ' mouse was clicked, scaled down by LAUNCH_SCALE# - same formula
    ' as the Python original's speed.x = (x + 200) / 25
    ballX$       = CANNON_X# + 1
    ballY$       = CANNON_Y# - 1
    ballSpeedX$ = (MOUSEX - CANNON_X#) / LAUNCH_SCALE# * AIM_BOOST#
    ballSpeedY$ = (MOUSEY - CANNON_Y#) / LAUNCH_SCALE# * AIM_BOOST#
    ballActive$ = TRUE
RETURN

' ------------------------------------------------------------
' Movement
' ------------------------------------------------------------

[sub:moveBall]
    IF ballActive$ THEN
        ballSpeedY$ += GRAVITY#
        ballX$ += ballSpeedX$
        ballY$ += ballSpeedY$
        IF ballX$ < 0 OR ballX$ > WIDTH# OR ballY$ < 0 OR ballY$ > HEIGHT# THEN
            ballActive$ = FALSE ' left the screen - ready to fire again
        END IF
    END IF
RETURN

[sub:spawnTarget]
    IF RND(SPAWN_CHANCE#) = 0 THEN
        targetsX$(nextTargetId$) = WIDTH#
        targetsY$(nextTargetId$) = RND(HEIGHT# - 2 * MARGIN#) + MARGIN#
        nextTargetId$ += 1
    END IF
RETURN

[sub:moveTargets]
    FOR i$ = 0 TO nextTargetId$ - 1
        IF HASKEY(targetsX$(i$)) THEN
            targetsX$(i$) -= TARGET_SPEED#
        END IF
    NEXT
RETURN

' ------------------------------------------------------------
' Collisions
' ------------------------------------------------------------

[sub:checkHits]
    FOR i$ = 0 TO nextTargetId$ - 1
        IF HASKEY(targetsX$(i$)) AND ballActive$ THEN
            IF DISTANCE(ballX$, ballY$, targetsX$(i$), targetsY$(i$)) < HIT_RADIUS# THEN
                DELKEY targetsX$(i$) : DELKEY targetsY$(i$)
                score$ += 1
                ' Ball keeps flying after a hit - it is not consumed,
                ' matching the original, which never removes the ball
                ' when a target vanishes.
            END IF
        END IF
    NEXT
RETURN

[sub:checkMisses]
    ' Targets never move vertically after spawning, so only the left
    ' edge (x < 0) needs checking here - a target can only escape that way.
    FOR i$ = 0 TO nextTargetId$ - 1
        IF HASKEY(targetsX$(i$)) THEN
            IF targetsX$(i$) < 0 THEN
                missed$    = TRUE
                running$ = FALSE
            END IF
        END IF
    NEXT
RETURN

' ------------------------------------------------------------
' Rendering
' ------------------------------------------------------------

[sub:draw]
    SCREENLOCK ON
    LINE (0, 0)-(WIDTH#, HEIGHT#), BG_COL#, BF
    LINE (0, HEIGHT# - 6)-(WIDTH#, HEIGHT#), GROUND_COL#, BF

    ' --- targets ---
    FOR i$ = 0 TO nextTargetId$ - 1
        IF HASKEY(targetsX$(i$)) THEN
            CIRCLE (targetsX$(i$), targetsY$(i$)), TARGET_RADIUS#, TARGET_COL#, 1
        END IF
    NEXT

    ' --- ball, only while in flight ---
    IF ballActive$ THEN
        CIRCLE (ballX$, ballY$), BALL_RADIUS#, BALL_COL#, 1
    END IF

    ' --- cannon: the piece the original screenshot was missing ---
    aimAngle$   = ATAN2(MOUSEY - CANNON_Y#, MOUSEX - CANNON_X#)
    barrelEndX$ = CANNON_X# + COS(aimAngle$) * BARREL_LEN#
    barrelEndY$ = CANNON_Y# + SIN(aimAngle$) * BARREL_LEN#
    perpX$      = -SIN(aimAngle$) * BARREL_HALF_W#
    perpY$      =  COS(aimAngle$) * BARREL_HALF_W#

    CIRCLE (CANNON_X#, CANNON_Y# + 8), WHEEL_RADIUS#, WHEEL_COL#, 1

    ' Barrel drawn as three parallel lines (LINE has no width param) so
    ' it reads as a solid bar at any aim angle, not just horizontally.
    LINE (CANNON_X# + perpX$, CANNON_Y# + perpY$)-(barrelEndX$ + perpX$, barrelEndY$ + perpY$), CANNON_COL#
    LINE (CANNON_X#, CANNON_Y#)-(barrelEndX$, barrelEndY$), CANNON_COL#
    LINE (CANNON_X# - perpX$, CANNON_Y# - perpY$)-(barrelEndX$ - perpX$, barrelEndY$ - perpY$), CANNON_COL#

    CIRCLE (CANNON_X#, CANNON_Y#), TURRET_RADIUS#, CANNON_COL#, 1

    ' --- HUD ---
    DRAWSTRING "Score: " + STR(score$), 12, 10, TEXT_COL#
    DRAWSTRING "Click to fire - ESC to quit", 12, 30, TEXT_COL#
    SCREENLOCK OFF
RETURN

[sub:drawGameOver]
    SCREENLOCK ON
    LINE (0, 0)-(WIDTH#, HEIGHT#), BG_COL#, BF
    DRAWSTRING "GAME OVER", WIDTH# / 2 - 60, HEIGHT# / 2 - 20, GAMEOVER_COL#
    DRAWSTRING "A target got away - final score: " + STR(score$), WIDTH# / 2 - 170, HEIGHT# / 2 + 10, TEXT_COL#
    SCREENLOCK OFF
RETURN
