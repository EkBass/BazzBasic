' =====================================
' Lane Racer — Part I
' A simple lane-change driving example
' for BazzBasic.
'
' Controls:
'   RIGHT  — accelerate
'   LEFT   — brake
'   UP     — move up (speed-dependent)
'   DOWN   — move down (speed-dependent)
'   ESC    — quit
'
' Assets:
'   assets/background.png  800x600 — road UI with "Speed" label and key hints
'   assets/plr_car.png     200x92  — player car sprite (top-left positioned)
'                          source: https://looneybits.itch.io/2d-urban-cars
'
' https://ekbass.github.io/BazzBasic/
' =====================================

' ---- SCREEN & IMAGES ----
[inits]
    LET SCREEN_WIDTH#  = 800
    LET SCREEN_HEIGHT# = 600
    SCREEN 0, SCREEN_WIDTH#, SCREEN_HEIGHT#, "Lane Racer"

    LET BACKGROUND_IMAGE# = LOADIMAGE("assets/background.png")
    LET PLR_CAR#          = LOADIMAGE("assets/plr_car.png")
    LET PLR_CAR_W#        = 200
    LET PLR_CAR_H#        = 92
    LET PLR_CAR_X#        = 10    ' fixed horizontal position — car stays on the left

' ---- TRACK GEOMETRY ----
    LET TRACK_WIDTH#  = 800
    LET TRACK_HEIGHT# = 300
    LET TRACK_TOP_Y#  = (SCREEN_HEIGHT# - TRACK_HEIGHT#) / 2    ' centers road vertically
    LET TRACK_COLOR#  = RGB(128, 128, 128)

    ' Road bounds are defined by car top-left corner, not center.
    ' LOADIMAGE handles are positioned by top-left, not center (unlike LOADSHAPE).
    LET ROAD_TOP#    = TRACK_TOP_Y#
    LET ROAD_BOTTOM# = TRACK_TOP_Y# + TRACK_HEIGHT# - PLR_CAR_H#

    ' Shoulder: narrow zone past road edge where car is slowed but not crashed.
    ' Beyond shoulder: crash triggers.
    LET SHOULDER#          = 30
    LET CRASH_TOP#         = ROAD_TOP#    - SHOULDER#
    LET CRASH_BOTTOM#      = ROAD_BOTTOM# + SHOULDER#
    LET SHOULDER_SPEED_CAP# = 20    ' max speed while on shoulder

' ---- CENTER LINE DASHES ----
    LET WHITE_LINE_WIDTH#   = 50
    LET WHITE_LINE_HEIGHT#  = 10
    LET WHITE_LINE_SPACING# = 120
    LET WHITE_LINE_COLOR#   = RGB(255, 255, 255)
    LET WHITE_LINE_Y#       = (SCREEN_HEIGHT# / 2) - (WHITE_LINE_HEIGHT# / 2)

    ' One visual tile = dash + gap. Scroll resets by one cycle to stay seamless.
    LET DASH_CYCLE# = WHITE_LINE_WIDTH# + WHITE_LINE_SPACING#
    LET DASH_COUNT# = INT(SCREEN_WIDTH# / DASH_CYCLE#) + 2    ' +2 fills both edges during scroll

' ---- CAR SPEED ----
    LET CAR_MAX_SPEED# = 100
    LET CAR_MIN_SPEED# = 0

    ' Exponential approach: each frame adds a fraction of the remaining gap to max speed.
    ' The closer to max, the smaller the step — natural diminishing acceleration.
    LET ACCEL_FACTOR# = 0.002
    LET BRAKE_FACTOR# = ACCEL_FACTOR# * 3    ' brakes bite harder than engine pull

    LET carSpeed$ = 0
    LET carLoc$   = TRACK_TOP_Y# + (TRACK_HEIGHT# - PLR_CAR_H#) / 2    ' centered on road at start

' ---- RUNTIME STATE ----
    LET line_x$ = 0    ' current scroll offset of center dashes; decrements by speed each frame
    LET dash_x$ = 0    ' reused each frame in drawLines loop

' ---- HUD: SPEED BAR ----
    ' Drawn as two overlapping LINE BF rectangles (background + fill).
    ' Avoids LOCATE/PRINT which bypasses SCREENLOCK and causes blinking at 60fps.
    LET HUD_BAR_X#     = 170
    LET HUD_BAR_Y#     = 70
    LET HUD_BAR_W#     = 200
    LET HUD_BAR_H#     = 16
    LET HUD_BAR_COLOR#  = RGB(255, 80, 0)
    LET HUD_BACK_COLOR# = RGB(60, 60, 60)
    LET hudBarFill$     = 0

' ---- MAIN LOOP ----
[main]
    WHILE INKEY <> KEY_ESC#
        GOSUB [sub:update]
        GOSUB [sub:draw]
        SLEEP 16    ' ~60 FPS
    WEND
END

' ---- UPDATE: input, physics, scroll ----
[sub:update]
    ' Acceleration — exponential approach toward CAR_MAX_SPEED#
    IF KEYDOWN(KEY_RIGHT#) THEN
        carSpeed$ = carSpeed$ + (CAR_MAX_SPEED# - carSpeed$) * ACCEL_FACTOR#
        carSpeed$ = CLAMP(carSpeed$, CAR_MIN_SPEED#, CAR_MAX_SPEED#)
    END IF

    ' Braking — exponential decay toward zero
    IF KEYDOWN(KEY_LEFT#) THEN
        carSpeed$ = carSpeed$ - carSpeed$ * BRAKE_FACTOR#
        carSpeed$ = CLAMP(carSpeed$, CAR_MIN_SPEED#, CAR_MAX_SPEED#)
        IF carSpeed$ < 0.1 THEN carSpeed$ = 0    ' snap to full stop at near-zero
    END IF

    ' Lane movement scaled by speed — stationary car cannot steer
    IF KEYDOWN(KEY_UP#)   THEN carLoc$ = carLoc$ - 3 * (carSpeed$ / CAR_MAX_SPEED#)
    IF KEYDOWN(KEY_DOWN#) THEN carLoc$ = carLoc$ + 3 * (carSpeed$ / CAR_MAX_SPEED#)

    ' Shoulder zone — cap speed when car drifts off road
    IF carLoc$ < ROAD_TOP# OR carLoc$ > ROAD_BOTTOM# THEN
        carSpeed$ = CLAMP(carSpeed$, CAR_MIN_SPEED#, SHOULDER_SPEED_CAP#)
    END IF

    ' Crash zone — full stop and push back inside boundary
    IF carLoc$ < CRASH_TOP# OR carLoc$ > CRASH_BOTTOM# THEN
        GOSUB [sub:crash]
    END IF

    ' Advance scroll offset; wrap by one full cycle to stay seamless
    line_x$ = line_x$ - carSpeed$
    IF line_x$ < -DASH_CYCLE# THEN line_x$ = line_x$ + DASH_CYCLE#
RETURN

' ---- DRAW: compose full frame inside SCREENLOCK ----
[sub:draw]
    SCREENLOCK ON
        DRAWSHAPE BACKGROUND_IMAGE#                                                         ' static UI layer
        LINE (0, TRACK_TOP_Y#)-(TRACK_WIDTH#, TRACK_TOP_Y# + TRACK_HEIGHT#), TRACK_COLOR#, BF  ' grey road
        GOSUB [sub:drawLines]      ' scrolling center dashes
        GOSUB [sub:drawHud]        ' speed bar
        GOSUB [sub:drawPlayerCar]  ' player car — drawn last, appears on top
    SCREENLOCK OFF
RETURN

' ---- DRAW: scrolling center dashes ----
[sub:drawLines]
    FOR i$ = 0 TO DASH_COUNT#
        dash_x$ = (i$ * DASH_CYCLE#) + line_x$
        LINE (dash_x$, WHITE_LINE_Y#)-(dash_x$ + WHITE_LINE_WIDTH#, WHITE_LINE_Y# + WHITE_LINE_HEIGHT#), WHITE_LINE_COLOR#, BF
    NEXT
RETURN

' ---- DRAW: speed bar HUD ----
[sub:drawHud]
    hudBarFill$ = INT((carSpeed$ / CAR_MAX_SPEED#) * HUD_BAR_W#)
    LINE (HUD_BAR_X#, HUD_BAR_Y#)-(HUD_BAR_X# + HUD_BAR_W#, HUD_BAR_Y# + HUD_BAR_H#), HUD_BACK_COLOR#, BF
    IF hudBarFill$ > 0 THEN
        LINE (HUD_BAR_X#, HUD_BAR_Y#)-(HUD_BAR_X# + hudBarFill$, HUD_BAR_Y# + HUD_BAR_H#), HUD_BAR_COLOR#, BF
    END IF
RETURN

' ---- DRAW: player car ----
[sub:drawPlayerCar]
    MOVESHAPE PLR_CAR#, PLR_CAR_X#, carLoc$
    DRAWSHAPE PLR_CAR#
RETURN

' ---- CRASH: stop car and push back inside crash boundary ----
[sub:crash]
    carSpeed$ = 0
    carLoc$ = CLAMP(carLoc$, CRASH_TOP# + 1, CRASH_BOTTOM# - 1)
RETURN