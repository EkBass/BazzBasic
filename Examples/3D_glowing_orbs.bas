' Glowing orb's
' Stupid neat 3D closing balls effect

' BazzBasic version 1.3
' https://ekbass.github.io/BazzBasic/

[inits]
    LET SCREEN_W# = 1280
    LET SCREEN_H# = 1024
    SCREEN 0, SCREEN_W#, SCREEN_H#, "Glowing Orbs"

    LET x$  = 0
    LET y$  = 0
    LET r$  = 0
    LET s$  = 0
    LET m$  = 0
    LET col$ = 0

[main]
    WHILE INKEY <> KEY_ESC#
        x$ = RND(SCREEN_W#)
        y$ = RND(SCREEN_H#)
        r$ = RND(48) + 32
        s$ = r$ / 15

        SCREENLOCK ON
        FOR m$ = 1 TO 15
            col$ = RGB(16 * m$, 14 * m$, 12 * m$)
            CIRCLE (x$, y$), r$, col$, 1
            r$ = r$ - s$
        NEXT
        SCREENLOCK OFF

        SLEEP 16
    WEND
END