' ============================================
' Modular Multiplication Circle
' BazzBasic: https://github.com/EkBass/BazzBasic
'
' Draws a circle of m evenly-spaced points and
' connects point n to point (n * p) mod m. The
' resulting cardioid / nephroid patterns depend
' on the pair (m, p).
'
' Port of a PC-BASIC program by Kurt Moerman,
' shared in the BASIC Programming Language
' Facebook Group:
'   https://www.facebook.com/share/p/14Wg9zYMpCq/
' ============================================

[inits]
    LET SCREEN_W# = 640
    LET SCREEN_H# = 480
    LET CX#       = 320
    LET CY#       = 240
    LET R#        = 220
    LET LINE_CLR# = RGB(255, 255, 0)    ' yellow
    LET BG_CLR#   = RGB(0, 0, 0)        ' black
    LET TXT_CLR#  = RGB(255, 255, 255)  ' white

    SCREEN 0, SCREEN_W#, SCREEN_H#, "Modular Multiplication Circle"
    FastTrig(TRUE)

    LET m$     = 0
    LET p$     = 0
    LET k$     = 0
    LET alpha$ = 0
    DIM x$
    DIM y$

[main]
    WHILE NOT KEYDOWN(KEY_ESC#)
        ' Pick a random number of points and multiplier
        m$ = RND(300) + 1
        p$ = RND(77)  + 1

        ' Pre-compute the coordinates of the m points on the circle.
        ' alpha is in degrees; +90 rotates the starting point to the top.
        FOR n$ = 0 TO m$ - 1
            alpha$ = 360 * n$ / m$ + 90
            x$(n$) = CX# - R# * FastCos(alpha$)
            y$(n$) = CY# - R# * FastSin(alpha$)
        NEXT

        ' Build the full frame off-screen, then present it in one flip.
        SCREENLOCK ON
            ' Clear with a filled box (faster than CLS)
            LINE (0, 0)-(SCREEN_W#, SCREEN_H#), BG_CLR#, BF

            ' Draw a line from point (n * p) mod m to point n.
            FOR n$ = 0 TO m$ - 1
                k$ = MOD(n$ * p$, m$)
                LINE (x$(k$), y$(k$))-(x$(n$), y$(n$)), LINE_CLR#
            NEXT

            ' Caption
            DRAWSTRING "Modular Multiplication Circle", 10, 10, TXT_CLR#
            DRAWSTRING "m = " + STR(m$),                10, 30, TXT_CLR#
            DRAWSTRING "p = " + STR(p$),                10, 50, TXT_CLR#
        SCREENLOCK OFF

        SLEEP 4000
    WEND
END

' Output:
'   A graphical window that keeps cycling through random
'   (m, p) pairs. Each frame shows m chords across a circle
'   of m points, held for ~4 s. Hold ESC to quit.
