' ============================================
' https://rosettacode.org/wiki/Chaos_game
' BazzBasic: https://github.com/EkBass/BazzBasic
' Chaos game: random halfway jumps toward triangle corners draw a Sierpinski triangle
' ============================================

[inits]
    LET W# = 640
    LET H# = 480
    LET POINTS# = 30000
    LET BATCH# = 500          ' points drawn per frame, so the triangle builds up visibly

    ' Triangle corners and a color for each
    DIM vx$, vy$, col$
    vx$(0) = 320 : vy$(0) = 20  : col$(0) = RGB(255, 80, 80)
    vx$(1) = 20  : vy$(1) = 460 : col$(1) = RGB(80, 255, 80)
    vx$(2) = 620 : vy$(2) = 460 : col$(2) = RGB(80, 160, 255)

    LET WHITE# = RGB(255, 255, 255)
    LET x$ = RND(W#)
    LET y$ = RND(H#)
    LET v$ = 0
    LET wkv$ = 0

    SCREEN 0, W#, H#, "Chaos game"

[main]
    SCREENLOCK ON
    LINE (0, 0)-(W#, H#), 0, BF
    SCREENLOCK OFF

    FOR b$ = 1 TO POINTS# / BATCH#
        SCREENLOCK ON
        FOR i$ = 1 TO BATCH#
            v$ = RND(3)                     ' pick a random corner 0..2
            x$ = (x$ + vx$(v$)) / 2         ' jump halfway toward it
            y$ = (y$ + vy$(v$)) / 2
            PSET (INT(x$), INT(y$)), col$(v$)
        NEXT
        SCREENLOCK OFF
    NEXT

    SCREENLOCK ON
    DRAWSTRING "Press any key to exit", 10, 10, WHITE#
    SCREENLOCK OFF
    wkv$ = WAITKEY()
END

' Output:
' A 640x480 window in which a Sierpinski triangle gradually appears,
' each point colored by the corner it last jumped toward.