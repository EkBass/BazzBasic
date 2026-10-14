' ============================================
' GRAPHICS SNIPPET 3: The Shape System
' LOADSHAPE, MOVESHAPE, ROTATESHAPE, SCALESHAPE, DRAWSHAPE,
' SHOWSHAPE / HIDESHAPE, REMOVESHAPE - and a debounced key
' toggle (press-and-release, not press-and-hold-fires-60x).
' Self-contained - shapes are procedural, no image file needed.
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    SCREEN 0, 640, 480, "Shapes & Transforms"

    ' LOADSHAPE returns a stable handle - store it in a constant,
    ' never a $ variable, per the "why constants, not variables" rule.
    LET SQUARE# = LOADSHAPE("RECTANGLE", 60, 60, RGB(220, 60, 60))
    LET BALL#   = LOADSHAPE("CIRCLE",    50, 50, RGB(90, 210, 110))
    LET ARROW#  = LOADSHAPE("TRIANGLE",  40, 60, RGB(70, 140, 230))

    MOVESHAPE SQUARE#, 160, 240
    MOVESHAPE BALL#,   320, 240
    MOVESHAPE ARROW#,  480, 240

    LET spinAngle$   = 0
    LET pulseScale$  = 1
    LET pulseDir$    = 0.02
    LET arrowVisible$ = TRUE

[main]
    WHILE INKEY <> KEY_ESC#
        ' rotation is absolute, not cumulative - so to spin
        ' continuously, keep incrementing our own angle variable
        spinAngle$ = spinAngle$ + 3
        IF spinAngle$ >= 360 THEN
            spinAngle$ = 0
        END IF
        ROTATESHAPE SQUARE#, spinAngle$
        ROTATESHAPE ARROW#, spinAngle$ * -1   ' spins the other way

        ' scale bounces back and forth between 0.5x and 1.6x
        pulseScale$ = pulseScale$ + pulseDir$
        IF pulseScale$ >= 1.6 OR pulseScale$ <= 0.5 THEN
            pulseDir$ = pulseDir$ * -1
        END IF
        SCALESHAPE BALL#, pulseScale$

        ' SPACE toggles the triangle's visibility. KEYDOWN fires every
        ' frame the key is held, so without the WHILE...WEND debounce
        ' below this would flip on/off dozens of times per keypress.
        IF KEYDOWN(KEY_SPACE#) THEN
            arrowVisible$ = NOT arrowVisible$
            IF arrowVisible$ = TRUE THEN
                SHOWSHAPE ARROW#
            ELSE
                HIDESHAPE ARROW#
            END IF
            WHILE KEYDOWN(KEY_SPACE#)
            WEND
        END IF

        SCREENLOCK ON
            LINE (0, 0)-(640, 480), 0, BF
            DRAWSHAPE SQUARE#
            DRAWSHAPE BALL#
            DRAWSHAPE ARROW#
            DRAWSTRING "Rectangle spins, circle pulses, triangle spins the other way.", 20, 20, RGB(255, 255, 255)
            DRAWSTRING "SPACE = show/hide triangle    ESC = quit", 20, 44, RGB(180, 180, 180)
        SCREENLOCK OFF

        SLEEP 16
    WEND

    ' always free shapes when done
    REMOVESHAPE SQUARE#
    REMOVESHAPE BALL#
    REMOVESHAPE ARROW#
END
