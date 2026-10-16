' ============================================
' Modular Multiplication Circle
' BazzBasic: https://github.com/EkBass/BazzBasic
'
' Draws a circle of m evenly-spaced points and
' connects point n to point (n * p) mod m. The
' resulting cardioid / nephroid patterns depend
' on the pair (m, p).
'
' Controls:
'   SPACE - next pattern immediately
'   ESC   - quit
'
' Port of a PC-BASIC program by Kurt Moerman,
' shared in the BASIC Programming Language
' Facebook Group:
'   https://www.facebook.com/share/p/14Wg9zYMpCq/
' ============================================

[inits]
    ' --- Screen & geometry ---
    LET SCREEN_W# = 640
    LET SCREEN_H# = 480
    LET CX#       = 320
    LET CY#       = 240
    LET R#        = 220

    ' --- Timing ---
    LET HOLD_MS#  = 4000                ' how long each pattern stays on screen
    LET POLL_MS#  = 16                  ' keyboard poll interval (~60 checks/s)

    ' --- Colours ---
    LET LINE_CLR# = RGB(255, 255, 0)    ' yellow
    LET BG_CLR#   = RGB(0, 0, 0)        ' black
    LET TXT_CLR#  = RGB(255, 255, 255)  ' white
    LET HINT_CLR# = RGB(150, 150, 150)  ' grey

    SCREEN 0, SCREEN_W#, SCREEN_H#, "Modular Multiplication Circle"
    FastTrig(TRUE)

    ' --- State ---
    LET m$         = 0
    LET p$         = 0
    LET k$         = 0
    LET alpha$     = 0
    LET key$       = 0
    LET waitStart$ = 0
    LET waiting$   = FALSE
    LET running$   = TRUE
    DIM x$
    DIM y$

[main]
    WHILE running$
        GOSUB [sub:newPattern]
        GOSUB [sub:draw]
        GOSUB [sub:wait]
    WEND

    FastTrig(FALSE)
END

' ------------------------------------------------------------
' Pick a random (m, p) and pre-compute the m points.
' alpha is in degrees; +90 rotates the starting point to the top.
' ------------------------------------------------------------
[sub:newPattern]
    m$ = RND(300) + 1
    p$ = RND(77)  + 1

    FOR n$ = 0 TO m$ - 1
        alpha$ = 360 * n$ / m$ + 90
        x$(n$) = CX# - R# * FastCos(alpha$)
        y$(n$) = CY# - R# * FastSin(alpha$)
    NEXT
RETURN

' ------------------------------------------------------------
' Build the full frame off-screen, then present it in one flip.
' ------------------------------------------------------------
[sub:draw]
    SCREENLOCK ON
        LINE (0, 0)-(SCREEN_W#, SCREEN_H#), BG_CLR#, BF

        ' Connect point (n * p) mod m to point n
        FOR n$ = 0 TO m$ - 1
            k$ = MOD(n$ * p$, m$)
            LINE (x$(k$), y$(k$))-(x$(n$), y$(n$)), LINE_CLR#
        NEXT

        DRAWSTRING "Modular Multiplication Circle",  10, 10, TXT_CLR#
        DRAWSTRING FSTRING("m = {{-m$-}}"),          10, 30, TXT_CLR#
        DRAWSTRING FSTRING("p = {{-p$-}}"),          10, 50, TXT_CLR#
        DRAWSTRING "SPACE = next   ESC = quit",      10, SCREEN_H# - 26, HINT_CLR#
    SCREENLOCK OFF
RETURN

' ------------------------------------------------------------
' Hold the current pattern for HOLD_MS#, but keep reading the
' keyboard every POLL_MS# so the program stays responsive.
'   ESC   -> stop waiting and end the main loop
'   SPACE -> stop waiting, show the next pattern
' ------------------------------------------------------------
[sub:wait]
    waitStart$ = TICKS
    waiting$   = TRUE

    WHILE waiting$
        key$ = INKEY
        IF key$ = KEY_ESC# THEN
            running$ = FALSE
            waiting$ = FALSE
        ELSEIF key$ = KEY_SPACE# THEN
            waiting$ = FALSE
        ELSEIF TICKS - waitStart$ >= HOLD_MS# THEN
            waiting$ = FALSE
        END IF
        SLEEP POLL_MS#
    WEND
RETURN

' Output:
'   A graphical window that keeps cycling through random
'   (m, p) pairs. Each frame shows m chords across a circle
'   of m points, held for ~4 s. SPACE skips to the next
'   pattern, a single tap of ESC quits within ~16 ms.