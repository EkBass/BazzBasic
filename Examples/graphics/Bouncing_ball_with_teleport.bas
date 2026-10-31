' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: A ball bounces off all four window edges at constant speed; pressing SPACE teleports it to a random spot with a random heading and increments a teleport counter.
' CATEGORY: simulation
' TAGS: bouncing ball, delta time, keyboard input
' MINVERSION: 1.5
' ============================================

[inits]
    ' --- Screen ---
    LET SCREEN_W# = 640
    LET SCREEN_H# = 480

    ' --- Ball ---
    LET BALL_R# = 12            ' radius in pixels
    LET SPEED#  = 300           ' pixels per second
    LET MAX_DT# = 0.05          ' longest allowed frame step (50 ms)

    ' Allowed range for the ball's CENTRE point.
    ' Pixels run 0..W-1, so the far edge is W - 1 - radius.
    LET MIN_X# = BALL_R#
    LET MAX_X# = SCREEN_W# - 1 - BALL_R#
    LET MIN_Y# = BALL_R#
    LET MAX_Y# = SCREEN_H# - 1 - BALL_R#

    ' --- Colours (computed once, not every frame) ---
    LET COL_BG#   = RGB(16, 16, 32)
    LET COL_BALL# = RGB(255, 200, 40)
    LET COL_TEXT# = RGB(200, 200, 200)

    ' --- State ---
    LET x$         = 0          ' ball centre
    LET y$         = 0
    LET vx$        = 0          ' velocity, px/s
    LET vy$        = 0
    LET angle$     = 0          ' bearing in radians
    LET key$       = 0
    LET teleports$ = 0
    LET hud$       = ""
    LET running$   = TRUE
    LET now$       = 0
    LET lastTick$  = 0
    LET dt$        = 0          ' frame time in seconds

[init:screen]
    SCREEN 0, SCREEN_W#, SCREEN_H#, "Bouncing Ball"
    GOSUB [sub:teleport]        ' random starting position and heading
    lastTick$ = TICKS

[main]
    WHILE running$
        ' --- Input: one key event per frame ---
        key$ = INKEY
        IF key$ = KEY_ESC# THEN running$ = FALSE
        IF key$ = KEY_SPACE# THEN
            GOSUB [sub:teleport]
            teleports$ += 1
        END IF

        ' --- Delta time, capped so a stalled frame can't fling the ball ---
        now$ = TICKS
        dt$ = MIN((now$ - lastTick$) / 1000, MAX_DT#)
        lastTick$ = now$

        GOSUB [sub:move]
        GOSUB [sub:draw]
        SLEEP 16
    WEND
END

' ============================================
' Subroutines
' ============================================

[sub:teleport]
    ' Random position inside the legal area: the whole ball stays on screen
    x$ = MIN_X# + RND(0) * (MAX_X# - MIN_X#)
    y$ = MIN_Y# + RND(0) * (MAX_Y# - MIN_Y#)
    ' Random bearing 0..2*PI. Speed stays constant, only direction changes
    angle$ = RND(0) * TAU#
    vx$ = COS(angle$) * SPEED#
    vy$ = SIN(angle$) * SPEED#
RETURN

[sub:move]
    x$ += vx$ * dt$
    y$ += vy$ * dt$

    ' Horizontal walls: mirror the overshoot back inside, point velocity away
    IF x$ < MIN_X# THEN
        x$ = MIN_X# + (MIN_X# - x$)
        vx$ = ABS(vx$)
    ELSEIF x$ > MAX_X# THEN
        x$ = MAX_X# - (x$ - MAX_X#)
        vx$ = -ABS(vx$)
    END IF

    ' Vertical walls: same logic
    IF y$ < MIN_Y# THEN
        y$ = MIN_Y# + (MIN_Y# - y$)
        vy$ = ABS(vy$)
    ELSEIF y$ > MAX_Y# THEN
        y$ = MAX_Y# - (y$ - MAX_Y#)
        vy$ = -ABS(vy$)
    END IF

    ' Safety net: the ball can never end up outside the legal area
    x$ = CLAMP(x$, MIN_X#, MAX_X#)
    y$ = CLAMP(y$, MIN_Y#, MAX_Y#)
RETURN

[sub:draw]
    hud$ = FSTRING("SPACE = teleport   ESC = quit   Teleports: {{-teleports$-}}")
    SCREENLOCK ON
        LINE (0, 0)-(SCREEN_W#, SCREEN_H#), COL_BG#, BF
        CIRCLE (CINT(x$), CINT(y$)), BALL_R#, COL_BALL#, 1
        DRAWSTRING hud$, 10, 10, COL_TEXT#
    SCREENLOCK OFF
RETURN

' Output:
' A 640x480 window with a yellow ball that bounces off all four edges.
' SPACE moves the ball to a random spot with a random heading and
' increases the "Teleports" counter in the top-left corner. ESC closes it.