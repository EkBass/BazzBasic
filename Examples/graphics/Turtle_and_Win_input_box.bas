' ============================================
' Turtle Graphics with a Windows input box
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Commands (typed into the Windows input box):
'   rotate left|right <degrees>    e.g. rotate left 5
'   move forward|backward <pixels> e.g. move forward 100
'   draw on|off                    pen down / pen up
'   color <0-15>                   16-color palette
'   size <1-128>                   line width in pixels
'   jump <x> <y>                   teleport, never draws
'   reset                          clear screen, turtle to middle
'   exit                           quit
' ============================================

' ---- FUNCTIONS -------------------------------------------------

' Wrap a value into [0, range). Works for negative values too,
' unlike MOD, which keeps the sign of the dividend.
DEF FN Wrap$(v$, range$)
    LET r$ = v$ - FLOOR(v$ / range$) * range$
    IF r$ >= range$ THEN r$ = 0          ' floating-point safety net
    RETURN r$
END DEF

' Keep only characters that a valid command can contain.
' This also makes the text safe to paste back into the
' PowerShell command line (no quotes, %, &, | etc.).
DEF FN Sanitize$(s$)
    LET out$ = ""
    LET c$ = ""
    FOR i$ = 1 TO LEN(s$)
        c$ = MID(s$, i$, 1)
        IF INSTR(ALLOWED_CHARS#, c$) > 0 THEN out$ += c$
    NEXT
    RETURN out$
END DEF

' TRUE if s$ is a number. Leading minus allowed,
' decimal point only when allowDecimal$ is TRUE.
DEF FN IsNumber$(s$, allowDecimal$)
    LET n$ = LEN(s$)
    LET dots$ = 0
    LET digits$ = 0
    LET c$ = ""
    IF n$ = 0 THEN RETURN FALSE
    FOR i$ = 1 TO n$
        c$ = MID(s$, i$, 1)
        IF c$ = "-" THEN
            IF i$ > 1 THEN RETURN FALSE
        ELSEIF c$ = "." THEN
            IF NOT allowDecimal$ THEN RETURN FALSE
            dots$ += 1
            IF dots$ > 1 THEN RETURN FALSE
        ELSEIF BETWEEN(ASC(c$), 48, 57) THEN
            digits$ += 1
        ELSE
            RETURN FALSE
        END IF
    NEXT
    RETURN digits$ > 0
END DEF

' ---- INITS -----------------------------------------------------
[inits]
    LET SCREEN_W# = 800
    LET SCREEN_H# = 600
    LET BG_COLOR# = 15                   ' white
    LET BAR_COLOR# = 7                   ' light gray status bar
    LET BAR_H# = 22
    LET TEXT_COLOR# = 0                  ' black
    LET TURTLE_FILE# = "assets/turtle.png"
    LET TURTLE_OFFSET# = 64              ' half of the 128x128 image, see notes
    LET BOX_TITLE# = "BazzBasic Turtle"
    ' Joiner that closes a PowerShell '...' string, adds a line break and
    ' opens the next string. Used to build a multi-line prompt expression.
    LET PS_NL# = "'+[Environment]::NewLine+'"

    ' One command per line in the input box. Keep these free of quotes
    ' and of < > | & % so the shell command line stays intact.
    DIM helpLines$
        helpLines$(0) = "rotate left / right  degrees"
        helpLines$(1) = "move forward / backward  pixels"
        helpLines$(2) = "draw on / off"
        helpLines$(3) = "color 0-15"
        helpLines$(4) = "size 1-128   (line width)"
        helpLines$(5) = "jump x y   (no drawing)"
        helpLines$(6) = "reset   (clear screen, turtle to middle)"
        helpLines$(7) = "exit"
    LET PUMP_MS# = 100                   ' how long to process window events
    LET DEBUG# = TRUE                    ' show what the parser received
    LET pumpStart$ = 0

    ' The help part never changes, so it is built only once.
    LET helpBlock$ = "Commands:"
    FOR i$ = 0 TO ROWCOUNT(helpLines$()) - 1
        helpBlock$ += PS_NL# + helpLines$(i$)
    NEXT
    LET ALLOWED_CHARS# = "abcdefghijklmnopqrstuvwxyz0123456789 .-"
    LET SHELL_TIMEOUT# = 600000          ' 10 min; the box blocks until answered
    LET MAX_MOVE# = 10000                ' sanity limit for one move
    ' A long move is split into chunks no longer than half the screen.
    ' That guarantees one copy shifted by -1/0/+1 screen is enough to
    ' draw the wrapped-around parts of every chunk (see drawSegmentWrapped).
    LET MAX_CHUNK# = MIN(SCREEN_W#, SCREEN_H#) / 2

    ' Turtle state
    LET turtleX$ = SCREEN_W# / 2
    LET turtleY$ = SCREEN_H# / 2
    LET heading$ = 0                     ' 0 = north, grows clockwise
    LET penDown$ = TRUE
    LET penColor$ = 0
    LET penSize$ = 1

    ' Drawn line segments, redrawn every time the scene is rendered
    DIM segs$
    LET segCount$ = 0

    ' Program / parser state
    LET running$ = TRUE
    LET statusMsg$ = "Ready."
    LET lastCommand$ = ""
    LET rawInput$ = ""
    LET cmdLine$ = ""
    LET word$ = ""
    LET partCount$ = 0
    DIM parts$
    LET shellCmd$ = ""
    LET promptText$ = ""
    LET pumpKey$ = 0
    LET argA$ = 0
    LET argB$ = 0

    ' Movement work variables
    LET moveDist$ = 0
    LET dirX$ = 0
    LET dirY$ = 0
    LET remaining$ = 0
    LET stepLen$ = 0
    LET newX$ = 0
    LET newY$ = 0

    ' Drawing work variables
    LET radius$ = 0
    LET ax$ = 0
    LET ay$ = 0
    LET bx$ = 0
    LET by$ = 0
    LET segColor$ = 0
    LET segSize$ = 0
    LET segLen$ = 0
    LET stampGap$ = 0
    LET stampCount$ = 0
    LET t$ = 0
    LET showX$ = 0
    LET showY$ = 0
    LET showHeading$ = 0
    LET penText$ = ""
    LET barText$ = ""

    IF NOT FILEEXISTS(TURTLE_FILE#) THEN
        PRINT "Missing image: "; TURTLE_FILE#
        END
    END IF

[init:screen]
    SCREEN 0, SCREEN_W#, SCREEN_H#, BOX_TITLE#
    LET TURTLE_IMG# = LOADIMAGE(TURTLE_FILE#)

' ---- MAIN ------------------------------------------------------
[main]
    WHILE running$
        GOSUB [sub:refreshWindow]
        GOSUB [sub:askCommand]
        GOSUB [sub:execute]
    WEND
    REMOVESHAPE TURTLE_IMG#
END

' ---- INPUT -----------------------------------------------------

' Opens a Windows input box through PowerShell and waits for it.
[sub:askCommand]
    ' pumpKey$ = INKEY                     ' let SDL2 process window events first
    ' Status first, an empty line, then the command list.
    ' Single quotes inside the status are doubled (PowerShell's own escape).
    promptText$ = REPLACE(statusMsg$, "'", "''") + PS_NL# + PS_NL# + helpBlock$
    ' Note the extra ( ) around the prompt: it is now an expression,
    ' not a single string literal.
    shellCmd$ = FSTRING("PowerShell -NoProfile -Command \"Add-Type -AssemblyName Microsoft.VisualBasic;[Microsoft.VisualBasic.Interaction]::InputBox(('{{-promptText$-}}'),'{{-BOX_TITLE#-}}','{{-lastCommand$-}}')\"")
    rawInput$ = SHELL(shellCmd$, SHELL_TIMEOUT#)
    ' PowerShell ends its output with a line break; strip it.
    rawInput$ = REPLACE(REPLACE(rawInput$, CHR(13), ""), CHR(10), "")
RETURN

' Cleans the text and hands it to the dispatcher.
[sub:execute]
    cmdLine$ = FN Sanitize$(LCASE(TRIM(rawInput$)))
    WHILE INSTR(cmdLine$, "  ") > 0      ' collapse repeated spaces
        cmdLine$ = REPLACE(cmdLine$, "  ", " ")
    WEND
    cmdLine$ = TRIM(cmdLine$)
    IF cmdLine$ = "" THEN
        statusMsg$ = "Empty command (Cancel gives this too). Type exit to quit."
    ELSE
        GOSUB [sub:dispatch]
        IF DEBUG# THEN
            statusMsg$ = FSTRING("{{-statusMsg$-}}   [parsed: {{-cmdLine$-}} / {{-partCount$-}} parts]")
        END IF
    END IF
RETURN

[sub:dispatch]
    partCount$ = SPLIT(parts$, cmdLine$, " ")
    word$ = parts$(0)
    lastCommand$ = cmdLine$              ' offered again as default text
    IF word$ = "exit" THEN
        running$ = FALSE
    ELSEIF word$ = "reset" THEN
        GOSUB [sub:cmdReset]
    ELSEIF word$ = "rotate" THEN
        GOSUB [sub:cmdRotate]
    ELSEIF word$ = "move" THEN
        GOSUB [sub:cmdMove]
    ELSEIF word$ = "draw" THEN
        GOSUB [sub:cmdDraw]
    ELSEIF word$ = "color" THEN
        GOSUB [sub:cmdColor]
    ELSEIF word$ = "size" THEN
        GOSUB [sub:cmdSize]
    ELSEIF word$ = "jump" THEN
        GOSUB [sub:cmdJump]
    ELSE
        statusMsg$ = "Unknown command: " + word$
    END IF
RETURN

' ---- COMMANDS --------------------------------------------------

[sub:cmdReset]
    IF partCount$ <> 1 THEN
        statusMsg$ = "Usage: reset"
    ELSE
        segCount$ = 0                    ' old entries are simply overwritten later
        turtleX$ = SCREEN_W# / 2
        turtleY$ = SCREEN_H# / 2
        heading$ = 0
        statusMsg$ = "Screen cleared, turtle back in the middle."
    END IF
RETURN

' Process events, draw, process events again. The first pump lets
' Windows clear the "Not responding" state that builds up while the
' input box is open. The second makes sure the new frame really
' reaches the screen before SHELL blocks the program again.
[sub:refreshWindow]
    GOSUB [sub:pumpEvents]
    GOSUB [sub:drawScene]
    GOSUB [sub:pumpEvents]
RETURN

' INKEY sits in the loop condition, where it pumps SDL2 events.
' INKEY returns a key code or 0, so ">= 0" is always true; the
' time check is what actually ends the loop.
[sub:pumpEvents]
    pumpStart$ = TICKS
    WHILE INKEY >= 0 AND TICKS - pumpStart$ < PUMP_MS#
        SLEEP 10
    WEND
RETURN

[sub:cmdRotate]
    IF partCount$ <> 3 THEN
        statusMsg$ = "Usage: rotate left/right degrees"
    ELSEIF NOT FN IsNumber$(parts$(2), TRUE) THEN
        statusMsg$ = "Angle must be a number."
    ELSEIF parts$(1) = "right" THEN
        heading$ = FN Wrap$(heading$ + VAL(parts$(2)), 360)
        statusMsg$ = "Rotated right."
    ELSEIF parts$(1) = "left" THEN
        heading$ = FN Wrap$(heading$ - VAL(parts$(2)), 360)
        statusMsg$ = "Rotated left."
    ELSE
        statusMsg$ = "Usage: rotate left/right degrees"
    END IF
RETURN

[sub:cmdMove]
    IF partCount$ <> 3 THEN
        statusMsg$ = "Usage: move forward/backward pixels"
    ELSEIF NOT FN IsNumber$(parts$(2), TRUE) THEN
        statusMsg$ = "Distance must be a number."
    ELSEIF ABS(VAL(parts$(2))) > MAX_MOVE# THEN
        statusMsg$ = FSTRING("Distance limited to {{-MAX_MOVE#-}} pixels.")
    ELSEIF parts$(1) = "forward" THEN
        moveDist$ = VAL(parts$(2))
        GOSUB [sub:moveTurtle]
        statusMsg$ = "Moved forward."
    ELSEIF parts$(1) = "backward" THEN
        moveDist$ = 0 - VAL(parts$(2))
        GOSUB [sub:moveTurtle]
        statusMsg$ = "Moved backward."
    ELSE
        statusMsg$ = "Usage: move forward/backward pixels"
    END IF
RETURN

[sub:cmdDraw]
    IF partCount$ <> 2 THEN
        statusMsg$ = "Usage: draw on/off"
    ELSEIF parts$(1) = "on" THEN
        penDown$ = TRUE
        statusMsg$ = "Pen down, drawing."
    ELSEIF parts$(1) = "off" OR parts$(1) = "of" THEN
        penDown$ = FALSE
        statusMsg$ = "Pen up, not drawing."
    ELSE
        statusMsg$ = "Usage: draw on/off"
    END IF
RETURN

[sub:cmdColor]
    IF partCount$ <> 2 THEN
        statusMsg$ = "Usage: color 0-15"
    ELSEIF NOT FN IsNumber$(parts$(1), FALSE) THEN
        statusMsg$ = "Color must be a whole number 0-15."
    ELSEIF NOT BETWEEN(VAL(parts$(1)), 0, 15) THEN
        statusMsg$ = "Color must be a whole number 0-15."
    ELSE
        penColor$ = VAL(parts$(1))
        statusMsg$ = "Color changed."
    END IF
RETURN

[sub:cmdSize]
    IF partCount$ <> 2 THEN
        statusMsg$ = "Usage: size 1-128"
    ELSEIF NOT FN IsNumber$(parts$(1), FALSE) THEN
        statusMsg$ = "Size must be a whole number 1-128."
    ELSEIF NOT BETWEEN(VAL(parts$(1)), 1, 128) THEN
        statusMsg$ = "Size must be a whole number 1-128."
    ELSE
        penSize$ = VAL(parts$(1))
        statusMsg$ = "Line size changed."
    END IF
RETURN

[sub:cmdJump]
    IF partCount$ <> 3 THEN
        statusMsg$ = "Usage: jump x y"
    ELSEIF NOT FN IsNumber$(parts$(1), FALSE) OR NOT FN IsNumber$(parts$(2), FALSE) THEN
        statusMsg$ = "Coordinates must be whole numbers."
    ELSE
        argA$ = VAL(parts$(1))
        argB$ = VAL(parts$(2))
        IF BETWEEN(argA$, 0, SCREEN_W# - 1) AND BETWEEN(argB$, 0, SCREEN_H# - 1) THEN
            turtleX$ = argA$
            turtleY$ = argB$
            statusMsg$ = "Jumped."
        ELSE
            statusMsg$ = "Off screen, no jump."
        END IF
    END IF
RETURN

' ---- MOVEMENT --------------------------------------------------

' Moves moveDist$ pixels along heading$ (negative = backward),
' wrapping at the screen edges and recording drawn segments.
[sub:moveTurtle]
    ' Heading 0 points up. Screen Y grows downward, hence -COS.
    dirX$ = SIN(RAD(heading$))
    dirY$ = 0 - COS(RAD(heading$))
    IF moveDist$ < 0 THEN
        dirX$ *= -1
        dirY$ *= -1
    END IF
    remaining$ = ABS(moveDist$)
    WHILE remaining$ > 0
        stepLen$ = MIN(remaining$, MAX_CHUNK#)
        newX$ = turtleX$ + dirX$ * stepLen$
        newY$ = turtleY$ + dirY$ * stepLen$
        IF penDown$ THEN
            GOSUB [sub:addSegment]
        END IF
        turtleX$ = FN Wrap$(newX$, SCREEN_W#)
        turtleY$ = FN Wrap$(newY$, SCREEN_H#)
        remaining$ -= stepLen$
    WEND
RETURN

' Start point is always on screen, end point may be outside it.
[sub:addSegment]
    segs$(segCount$, "x1") = turtleX$
    segs$(segCount$, "y1") = turtleY$
    segs$(segCount$, "x2") = newX$
    segs$(segCount$, "y2") = newY$
    segs$(segCount$, "color") = penColor$
    segs$(segCount$, "size") = penSize$
    segCount$ += 1
RETURN

' ---- DRAWING ---------------------------------------------------

[sub:drawScene]
    SCREENLOCK ON
    LINE (0, 0)-(SCREEN_W#, SCREEN_H#), BG_COLOR#, BF
    IF segCount$ > 0 THEN
        FOR i$ = 0 TO segCount$ - 1
            GOSUB [sub:drawSegmentWrapped]
        NEXT
    END IF
    ROTATESHAPE TURTLE_IMG#, heading$
    MOVESHAPE TURTLE_IMG#, CINT(turtleX$) - TURTLE_OFFSET#, CINT(turtleY$) - TURTLE_OFFSET#
    DRAWSHAPE TURTLE_IMG#
    GOSUB [sub:drawStatusBar]
    SCREENLOCK OFF
RETURN

' Draws segment i$ plus its copies shifted one screen in every
' direction. Copies that cannot touch the screen are skipped.
' This is what makes lines wrap around the edges like the turtle.
[sub:drawSegmentWrapped]
    segColor$ = segs$(i$, "color")
    segSize$ = segs$(i$, "size")
    radius$ = segSize$ / 2
    FOR offX$ = -1 TO 1
        FOR offY$ = -1 TO 1
            ax$ = segs$(i$, "x1") + offX$ * SCREEN_W#
            ay$ = segs$(i$, "y1") + offY$ * SCREEN_H#
            bx$ = segs$(i$, "x2") + offX$ * SCREEN_W#
            by$ = segs$(i$, "y2") + offY$ * SCREEN_H#
            IF MAX(ax$, bx$) + radius$ >= 0 AND MIN(ax$, bx$) - radius$ < SCREEN_W# AND
               MAX(ay$, by$) + radius$ >= 0 AND MIN(ay$, by$) - radius$ < SCREEN_H# THEN
                GOSUB [sub:drawThickLine]
            END IF
        NEXT
    NEXT
RETURN

' LINE has no width parameter, so wide lines are built by stamping
' filled circles along the segment (this also gives round line caps).
[sub:drawThickLine]
    IF segSize$ <= 1 THEN
        LINE (CINT(ax$), CINT(ay$))-(CINT(bx$), CINT(by$)), segColor$
    ELSE
        segLen$ = DISTANCE(ax$, ay$, bx$, by$)
        stampGap$ = MAX(1, radius$ / 2)
        stampCount$ = MAX(1, CEIL(segLen$ / stampGap$))
        FOR k$ = 0 TO stampCount$
            t$ = k$ / stampCount$
            CIRCLE (CINT(LERP(ax$, bx$, t$)), CINT(LERP(ay$, by$, t$))), CINT(radius$), segColor$, 1
        NEXT
    END IF
RETURN

[sub:drawStatusBar]
    LINE (0, SCREEN_H# - BAR_H#)-(SCREEN_W#, SCREEN_H#), BAR_COLOR#, BF
    showX$ = CINT(turtleX$)
    showY$ = CINT(turtleY$)
    showHeading$ = CINT(heading$)
    IF penDown$ THEN
        penText$ = "on"
    ELSE
        penText$ = "off"
    END IF
    barText$ = FSTRING("x {{-showX$-}}   y {{-showY$-}}   heading {{-showHeading$-}}   draw {{-penText$-}}   color {{-penColor$-}}   size {{-penSize$-}}")
    DRAWSTRING barText$, 6, SCREEN_H# - BAR_H# + 3, TEXT_COLOR#
    ' Pen color swatch with a black frame
    LINE (SCREEN_W# - 40, SCREEN_H# - BAR_H# + 4)-(SCREEN_W# - 8, SCREEN_H# - 4), penColor$, BF
    LINE (SCREEN_W# - 40, SCREEN_H# - BAR_H# + 4)-(SCREEN_W# - 8, SCREEN_H# - 4), 0, B
RETURN

' Example session:
'   move forward 100     -> black line straight up from the middle
'   rotate right 90
'   color 4
'   size 10
'   move forward 600     -> thick red line exits right, comes back from left
'   draw off
'   jump 100 100         -> teleports, no line
'   jump 900 100         -> "Off screen, no jump."
'   exit