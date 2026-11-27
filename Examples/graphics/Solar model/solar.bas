' solar.bas - Solar System (BazzBasic Studio, B8)
' Zoomable top-down model: Sun, planets, dwarfs, asteroids, TNOs, moons, stations, JWST,
' Halley, Parker and the Voyagers; body list panel (L).
' Run:      BazzBasic.exe solar.bas
' Selftest: BazzBasic.exe solar.bas selftest   (writes selftest\report.txt, selftest\phases.txt and 14 PNGs)

' ************************************
' * Functions first (DEF FN only)    *
' ************************************
INCLUDE "include/calendar.bas"

' **********
' * Gosubs *
' **********
GOSUB [inits:screen]
GOSUB [inits:globals]
GOSUB [inits:colors]

' ************
' * Includes *
' ************
INCLUDE "include/bodies.bas"
INCLUDE "include/sim.bas"
INCLUDE "include/view.bas"
INCLUDE "include/selftest.bas"

' Load + prepare before SCREEN, so load errors print to the console
GOSUB [bodies:load]
GOSUB [sim:prepare]
GOSUB [view:listPrepare]

mode$ = "run"
IF ARGCOUNT > 0 THEN
    IF ARGS(0) = "selftest" THEN
        mode$ = "selftest"
    END IF
END IF

IF mode$ = "selftest" THEN
    GOSUB [selftest:console]
    GOSUB [sub:setScreen]
    GOSUB [selftest:views]
ELSE
    GOSUB [sub:setScreen]
    wheel$ = MOUSEWHEEL
    lastTick$ = TICKS
    WHILE running$
        GOSUB [view:input]
        GOSUB [view:hover]
        nowTick$ = TICKS
        dtMs$ = CLAMP(nowTick$ - lastTick$, 0, 100)
        lastTick$ = nowTick$
        simT$ = simT$ + speedDps$(spIdx$) * dtMs$ / 1000
        GOSUB [sim:update]
        GOSUB [view:camera]
        GOSUB [view:draw]
    WEND
END IF

END


' ********************
' * Subs start here  *
' ********************
[sub:setScreen]
    SCREEN 0, SCREEN_W#, SCREEN_H#, TITLE#
    ' text and circle warm-up (first calls are slow), then a clean screen
    SCREENLOCK ON
    FOR wu$ = 1 TO 10 : DRAWSTRING HELP#, HUD_X#, HELP_Y#, C_HUD# : NEXT
    CIRCLE (CX#, CY#), 3, C_HUD#, 1
    CIRCLE (CX#, CY#), 30, C_HUD#
    LINE (0, 0)-(100, 100), C_HUD#
    LINE (0, 0)-(1919, 1079), 0, BF
    SCREENLOCK OFF
RETURN ' [/sub:setScreen]


[inits:screen]
    LET SCREEN_W# = 1920
    LET SCREEN_H# = 1080
    LET TITLE# = "Solar System"
    LET CX# = 960
    LET CY# = 540
    LET MAX_X# = SCREEN_W# - 1
    LET MAX_Y# = SCREEN_H# - 1
    LET HALF_DIAG# = 1104
    LET ZMAX# = 74
    LET ZOOM_MAX# = 300 / 6371
    LET KM_PER_AU# = AU# / 1000
    LET START_DAY# = FN DaysFromCivil$(2026, 1, 1)
    LET START_NOTCH# = 29
    LET CLOCK_EPS# = 0.001
    ' tunables (B7 revision note 2; R_CIRCLE# and R_LOCK#: revision note 4)
    LET R_DISC_SAFE# = 1500
    LET R_CIRCLE# = 250
    LET R_LOCK# = 1000
    LET SPAN_BAND# = 2
    LET ORBIT_SEG_MAX# = 256
    LET SAFE_PX# = 8192
    LET SAG_PX# = 1
    LET LABEL_MAX# = 5
    LET CHAR_W# = 10
    LET SAFE_LO# = 0 - SAFE_PX#
    LET DRAG_PX# = 5
    LET LABEL_MAX_R# = 400
    LET ST_FRAMES# = 120
    LET HUD_X# = 10
    LET HUD_Y# = 10
    LET HELP_Y# = 1056
    LET HELP# = "Wheel zoom | Drag pan | Click lock | C unlock | L list | F/S or Num+/Num- speed | Space pause | Esc quit"
    ' B8: picking, orbits, JWST halo, body list panel (retained, b8-algo A10)
    LET PICK_PX# = 20
    LET CIRC_ERR_PX# = 0.5
    LET JWST_HALO_KM# = 500000
    LET LIST_W# = 320
    LET LIST_X# = SCREEN_W# - LIST_W#
    LET LIST_CX# = LIST_X# / 2
    LET LIST_Y0# = 34
    LET ROW_H# = 20
    LET LIST_ROWS# = 50
    LET LIST_FIT_PX# = 450
    LET LIST_DISC_R# = 100
    LET LIST_REPAINT# = 4
    LET LABEL_MAX_LIST# = 5
RETURN ' [/inits:screen]


[inits:globals]
    LET mode$ = "run"
    LET running$ = TRUE
    LET wheel$ = 0
    LET lastTick$ = 0
    LET nowTick$ = 0
    LET dtMs$ = 0
    ' camera (world km, y up), zoom notch, lock (-1 = none)
    LET camX$ = 0
    LET camY$ = 0
    LET zIdx$ = START_NOTCH#
    LET zoom$ = 0
    LET lockIdx$ = -1
    ' camera centre x and right edge of the model area (list open: LIST_CX#, LIST_X# - 1)
    LET camCX$ = CX#
    LET drawMaxX$ = MAX_X#
    ' body list: 0 off, 1 Major, 2 Other
    LET listMode$ = 0
    ' time speeds in simulated days per second (Julian year); start = 1 d/s
    LET spIdx$ = 2
    LET spSaved$ = 2
    DIM speedDps$, speedTxt$
    speedDps$(0) = 0 : speedTxt$(0) = "paused"
    speedDps$(1) = 1 / 24 : speedTxt$(1) = "1 h/s"
    speedDps$(2) = 1 : speedTxt$(2) = "1 d/s"
    speedDps$(3) = 7 : speedTxt$(3) = "1 wk/s"
    speedDps$(4) = 30.4375 : speedTxt$(4) = "1 mo/s"
    speedDps$(5) = 365.25 : speedTxt$(5) = "1 yr/s"
    speedDps$(6) = 3652.5 : speedTxt$(6) = "10 yr/s"
    speedDps$(7) = 36525 : speedTxt$(7) = "100 yr/s"
    DIM pal$
RETURN ' [/inits:globals]


[inits:colors]
    pal$("SUN") = RGB(255, 221, 64)
    pal$("MERCURY") = RGB(160, 160, 160)
    pal$("VENUS") = RGB(238, 224, 160)
    pal$("EARTH") = RGB(64, 128, 255)
    pal$("MOON") = RGB(205, 205, 205)
    pal$("MARS") = RGB(225, 95, 45)
    pal$("JUPITER") = RGB(214, 170, 120)
    pal$("SATURN") = RGB(230, 205, 140)
    pal$("URANUS") = RGB(160, 225, 225)
    pal$("NEPTUNE") = RGB(50, 80, 220)
    pal$("ISS") = RGB(255, 255, 255)
    pal$("DWARF_A") = RGB(150, 130, 110)
    pal$("DWARF_B") = RGB(130, 115, 100)
    pal$("DWARF_C") = RGB(170, 150, 130)
    pal$("ASTEROID") = RGB(128, 128, 128)
    pal$("MOON_GREY") = RGB(170, 170, 170)
    pal$("MOON_BEIGE") = RGB(190, 175, 150)
    pal$("CHARON") = RGB(150, 135, 120)
    pal$("HUBBLE") = RGB(200, 200, 210)
    pal$("JWST") = RGB(230, 190, 70)
    pal$("COMET") = RGB(200, 240, 255)
    pal$("PROBE") = RGB(255, 210, 160)
    pal$("VOYAGER") = RGB(210, 210, 255)
    LET C_ORBIT# = RGB(45, 55, 80)
    LET C_ORBIT_MOON# = RGB(55, 55, 62)
    LET C_RING# = RGB(200, 180, 130)
    LET C_LABEL# = RGB(170, 170, 190)
    LET C_HUD# = RGB(220, 220, 220)
    LET C_LOCK# = RGB(255, 255, 255)
    LET C_VLINE# = RGB(50, 50, 75)
    LET C_HOVER# = RGB(255, 240, 120)
    LET C_LIST# = RGB(220, 220, 220)
    LET C_LIST_HEAD# = RGB(200, 180, 60)
    LET C_ROW_LOCK# = RGB(45, 55, 100)
    LET C_ROW_HOV# = RGB(35, 35, 50)
RETURN ' [/inits:colors]
