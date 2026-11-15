' ============================================
' https://rosettacode.org/wiki/Julia_set
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    ' View settings: 81 pixels = 1.0 on the complex plane
    LET SCALE#    = 1 / 81
    LET ZERO_X#   = 160          ' screen x of the origin
    LET ZERO_Y#   = 100          ' screen y of the origin
    LET MAX_ITER# = 32

    ' The constant c = CR + CI*i that defines this Julia set
    LET CR# = -0.798
    LET CI# = 0.1618

    ' Working variables (declared once, reassigned in the loops)
    LET zReal$   = 0
    LET zImag$   = 0
    LET newReal$ = 0
    LET key$     = 0

[init:screen]
    SCREEN 13                    ' 320 x 200, same as QBasic

[main]
    VSYNC(FALSE)                 ' don't wait for the monitor after every column
    FOR x$ = 0 TO 2 * ZERO_X# - 1
        SCREENLOCK ON
        FOR y$ = 0 TO 2 * ZERO_Y# - 1
            ' Map the pixel to a point z on the complex plane
            zReal$ = (x$ - ZERO_X#) * SCALE#
            zImag$ = (ZERO_Y# - y$) * SCALE#

            ' Iterate z = z^2 + c until it escapes (|z|^2 > 4)
            FOR iter$ = 1 TO MAX_ITER#
                newReal$ = CR# + zReal$ * zReal$ - zImag$ * zImag$
                zImag$   = CI# + 2 * zReal$ * zImag$
                zReal$   = newReal$
                IF zReal$ * zReal$ + zImag$ * zImag$ > 4 THEN
                    PSET (x$, y$), 1 + (iter$ % 16)
                    EXIT FOR
                END IF
            NEXT
        NEXT
        SCREENLOCK OFF           ' show the finished column
    NEXT
    VSYNC(TRUE)

    LET key$ = WAITKEY()         ' keep the window open until a key is pressed
END