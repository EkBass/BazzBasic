' ============================================
' Gamepad Button Tester (console mode)
' Lists every PAD_* button constant and lights up its row
' while the button is held down. Also shows the six axes,
' because L2/R2 are axes in BazzBasic, not buttons.
' Requires BazzBasic 1.5 or newer.
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    ' --- settings ---
    LET PREFERRED_PAD# = -1     ' -1 = first connected pad, 0..7 = force this slot
    LET MAX_PADS#      = 8      ' BazzBasic supports pads 0..7

    ' --- layout (console rows/cols are 1-based) ---
    LET BTN_ROW#   = 5          ' first button row
    LET BTN_COL#   = 2
    LET BTN_W#     = 52         ' fixed width of one button row (incl. "[X] ")
    LET AXIS_ROW#  = 5
    LET AXIS_COL#  = 58
    LET AXIS_COUNT# = 6
    LET FOOT_ROW#  = 27
    LET LINE_W#    = 100

    ' --- colors (palette 0-15) ---
    LET OFF_FG# = 8             ' dark gray   = not pressed
    LET OFF_BG# = 0
    LET ON_FG#  = 0             ' black on light green = pressed
    LET ON_BG#  = 10
    LET TXT_FG# = 7
    LET HI_FG#  = 15

    ' --- button table ---
    DIM btnName$, btnId$, btnInfo$, btnLabel$, btnWas$
    LET btnCount$ = 0
    LET bName$ = ""
    LET bId$   = 0
    LET bInfo$ = ""
    LET txt$   = ""             ' used by [sub:addButton], so declare it before the GOSUBs

    bName$ = "PAD_A#"        : bId$ = PAD_A#        : bInfo$ = "A / Cross"              : GOSUB [sub:addButton]
    bName$ = "PAD_B#"        : bId$ = PAD_B#        : bInfo$ = "B / Circle"             : GOSUB [sub:addButton]
    bName$ = "PAD_X#"        : bId$ = PAD_X#        : bInfo$ = "X / Square"             : GOSUB [sub:addButton]
    bName$ = "PAD_Y#"        : bId$ = PAD_Y#        : bInfo$ = "Y / Triangle"           : GOSUB [sub:addButton]
    bName$ = "PAD_UP#"       : bId$ = PAD_UP#       : bInfo$ = "D-pad up"               : GOSUB [sub:addButton]
    bName$ = "PAD_DOWN#"     : bId$ = PAD_DOWN#     : bInfo$ = "D-pad down"             : GOSUB [sub:addButton]
    bName$ = "PAD_LEFT#"     : bId$ = PAD_LEFT#     : bInfo$ = "D-pad left"             : GOSUB [sub:addButton]
    bName$ = "PAD_RIGHT#"    : bId$ = PAD_RIGHT#    : bInfo$ = "D-pad right"            : GOSUB [sub:addButton]
    bName$ = "PAD_LB#"       : bId$ = PAD_LB#       : bInfo$ = "LB / L1"                : GOSUB [sub:addButton]
    bName$ = "PAD_RB#"       : bId$ = PAD_RB#       : bInfo$ = "RB / R1"                : GOSUB [sub:addButton]
    bName$ = "PAD_LSTICK#"   : bId$ = PAD_LSTICK#   : bInfo$ = "Left stick click / L3"  : GOSUB [sub:addButton]
    bName$ = "PAD_RSTICK#"   : bId$ = PAD_RSTICK#   : bInfo$ = "Right stick click / R3" : GOSUB [sub:addButton]
    bName$ = "PAD_BACK#"     : bId$ = PAD_BACK#     : bInfo$ = "Back / View / Share"    : GOSUB [sub:addButton]
    bName$ = "PAD_START#"    : bId$ = PAD_START#    : bInfo$ = "Start / Menu / Options" : GOSUB [sub:addButton]
    bName$ = "PAD_GUIDE#"    : bId$ = PAD_GUIDE#    : bInfo$ = "Xbox / PS / Home"       : GOSUB [sub:addButton]
    bName$ = "PAD_MISC#"     : bId$ = PAD_MISC#     : bInfo$ = "Share / Mic / Capture"  : GOSUB [sub:addButton]
    bName$ = "PAD_TOUCHPAD#" : bId$ = PAD_TOUCHPAD# : bInfo$ = "PS touchpad click"      : GOSUB [sub:addButton]
    ' Elite paddles have no named constant - raw numbers 16..19 are valid
    bName$ = "(raw 16)"      : bId$ = 16            : bInfo$ = "Elite paddle 1"         : GOSUB [sub:addButton]
    bName$ = "(raw 17)"      : bId$ = 17            : bInfo$ = "Elite paddle 2"         : GOSUB [sub:addButton]
    bName$ = "(raw 18)"      : bId$ = 18            : bInfo$ = "Elite paddle 3"         : GOSUB [sub:addButton]
    bName$ = "(raw 19)"      : bId$ = 19            : bInfo$ = "Elite paddle 4"         : GOSUB [sub:addButton]

    ' --- axis table ---
    DIM axisName$, axisId$, axisWas$
    axisName$(0) = "PAD_LX#" : axisId$(0) = PAD_LX#
    axisName$(1) = "PAD_LY#" : axisId$(1) = PAD_LY#
    axisName$(2) = "PAD_RX#" : axisId$(2) = PAD_RX#
    axisName$(3) = "PAD_RY#" : axisId$(3) = PAD_RY#
    axisName$(4) = "PAD_LT#" : axisId$(4) = PAD_LT#
    axisName$(5) = "PAD_RT#" : axisId$(5) = PAD_RT#

    ' --- runtime state ---
    LET running$   = TRUE
    LET k$         = 0
    LET pad$       = 0
    LET padFound$  = FALSE
    LET padCount$  = 0
    LET padName$   = ""
    LET lastPad$   = -1         ' -1 forces the first header draw
    LET lastFound$ = -1
    LET lastCount$ = -1
    LET now$       = 0
    LET v$         = 0

[main]
    GOSUB [sub:drawStatic]

    WHILE running$
        k$ = INKEY
        IF k$ = KEY_ESC# THEN running$ = FALSE

        ' Which pad are we watching? Redraw everything if that changed.
        GOSUB [sub:pickPad]
        padCount$ = GAMEPADS()
        IF pad$ <> lastPad$ OR padFound$ <> lastFound$ OR padCount$ <> lastCount$ THEN
            GOSUB [sub:drawHeader]
            FOR j$ = 0 TO btnCount$ - 1 : btnWas$(j$) = -1 : NEXT j$
            FOR j$ = 0 TO AXIS_COUNT# - 1 : axisWas$(j$) = -999 : NEXT j$
            lastPad$   = pad$
            lastFound$ = padFound$
            lastCount$ = padCount$
        END IF

        ' Buttons: redraw a row only when its state changes
        FOR i$ = 0 TO btnCount$ - 1
            now$ = PADBUTTON(pad$, btnId$(i$))
            IF now$ <> btnWas$(i$) THEN
                GOSUB [sub:drawButton]
                IF now$ THEN GOSUB [sub:drawLast]   ' edge: released -> pressed
                btnWas$(i$) = now$
            END IF
        NEXT i$

        ' Axes: rounded to 2 decimals so tiny jitter doesn't redraw constantly
        FOR a$ = 0 TO AXIS_COUNT# - 1
            v$ = ROUND(PADAXIS(pad$, axisId$(a$)) * 100) / 100
            IF v$ <> axisWas$(a$) THEN
                GOSUB [sub:drawAxis]
                axisWas$(a$) = v$
            END IF
        NEXT a$

        LOCATE FOOT_ROW# + 2, 1     ' park the cursor out of the way
        SLEEP 16
    WEND

    COLOR TXT_FG#, 0
    LOCATE FOOT_ROW# + 2, 1
    PRINT "Bye!"
END

' Output (example, Xbox controller, A and LT held):
'  BazzBasic Gamepad Tester
'  Testing pad 0: Xbox Series X Controller   (connected pads: 1)
'  Hold a button to light its row. ESC quits.
'      CONSTANT        ID  BUTTON                   AXIS      VALUE
'  [X] PAD_A#          0   A / Cross                PAD_LX#       0
'  [ ] PAD_B#          1   B / Circle               PAD_LY#       0
'  ...                                              PAD_LT#    0.73
'  Last pressed: PAD_A# = 0   (A / Cross)

' --------------------------------------------
[sub:addButton]
    ' Uses bName$, bId$, bInfo$. Builds a fixed-width label once,
    ' so drawing a row later is a single PRINT.
    btnName$(btnCount$) = bName$
    btnId$(btnCount$)   = bId$
    btnInfo$(btnCount$) = bInfo$
    txt$ = LEFT(bName$ + REPEAT(" ", 16), 16) + LEFT(STR(bId$) + REPEAT(" ", 4), 4) + bInfo$
    btnLabel$(btnCount$) = LEFT(txt$ + REPEAT(" ", BTN_W#), BTN_W# - 4)
    btnWas$(btnCount$) = -1
    btnCount$ += 1
RETURN

' --------------------------------------------
[sub:pickPad]
    ' Pad slots are stable: pad 0 may be gone while pad 1 is connected,
    ' so look for the first slot that actually has a name.
    padFound$ = FALSE
    pad$ = 0
    IF PREFERRED_PAD# >= 0 THEN
        pad$ = PREFERRED_PAD#
        IF PADNAME(pad$) <> "" THEN padFound$ = TRUE
    ELSE
        FOR p$ = 0 TO MAX_PADS# - 1
            IF padFound$ = FALSE THEN
                IF PADNAME(p$) <> "" THEN
                    pad$ = p$
                    padFound$ = TRUE
                END IF
            END IF
        NEXT p$
    END IF
RETURN

' --------------------------------------------
[sub:drawStatic]
    COLOR TXT_FG#, 0
    CLS
    LOCATE 1, BTN_COL#
    COLOR HI_FG#, 0
    PRINT "BazzBasic Gamepad Tester";
    COLOR TXT_FG#, 0
    LOCATE 3, BTN_COL#
    PRINT "Hold a button to light its row. ESC quits.";
    LOCATE 4, BTN_COL#
    PRINT "    CONSTANT        ID  BUTTON";
    LOCATE 4, AXIS_COL#
    PRINT "AXIS      VALUE";
    LOCATE AXIS_ROW# + AXIS_COUNT# + 1, AXIS_COL#
    PRINT "L2/R2 are triggers = axes.";
    LOCATE AXIS_ROW# + AXIS_COUNT# + 2, AXIS_COL#
    PRINT "Read them with PADAXIS(pad,";
    LOCATE AXIS_ROW# + AXIS_COUNT# + 3, AXIS_COL#
    PRINT "PAD_LT#/PAD_RT#), never PADBUTTON.";
RETURN

' --------------------------------------------
[sub:drawHeader]
    IF padFound$ THEN
        padName$ = PADNAME(pad$)
        txt$ = FSTRING("Testing pad {{-pad$-}}: {{-padName$-}}   (connected pads: {{-padCount$-}})")
    ELSE
        txt$ = "No gamepad connected - plug one in, hot-plug is supported."
    END IF
    LOCATE 2, BTN_COL#
    COLOR HI_FG#, 0
    PRINT LEFT(txt$ + REPEAT(" ", LINE_W#), LINE_W#);
    COLOR TXT_FG#, 0
RETURN

' --------------------------------------------
[sub:drawButton]
    ' Uses i$ (row index) and now$ (TRUE/FALSE) from the caller
    LOCATE BTN_ROW# + i$, BTN_COL#
    IF now$ THEN
        COLOR ON_FG#, ON_BG#
        PRINT "[X] " + btnLabel$(i$);
    ELSE
        COLOR OFF_FG#, OFF_BG#
        PRINT "[ ] " + btnLabel$(i$);
    END IF
    COLOR TXT_FG#, 0
RETURN

' --------------------------------------------
[sub:drawLast]
    txt$ = "Last pressed: " + btnName$(i$) + " = " + btnId$(i$) + "   (" + btnInfo$(i$) + ")"
    LOCATE FOOT_ROW#, BTN_COL#
    COLOR HI_FG#, 0
    PRINT LEFT(txt$ + REPEAT(" ", LINE_W#), LINE_W#);
    COLOR TXT_FG#, 0
RETURN

' --------------------------------------------
[sub:drawAxis]
    ' Uses a$ (axis index) and v$ (rounded value) from the caller
    txt$ = LEFT(axisName$(a$) + REPEAT(" ", 10), 10) + RIGHT(REPEAT(" ", 6) + STR(v$), 6)
    LOCATE AXIS_ROW# + a$, AXIS_COL#
    IF ABS(v$) >= 0.5 THEN
        COLOR ON_FG#, ON_BG#
    ELSE
        COLOR OFF_FG#, OFF_BG#
    END IF
    PRINT txt$;
    COLOR TXT_FG#, 0
RETURN
