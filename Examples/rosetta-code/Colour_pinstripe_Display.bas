' ============================================
' https://rosettacode.org/wiki/Colour_pinstripe/Display
' BazzBasic: https://github.com/EkBass/BazzBasic
' Vertical colour pinstripes 1, 2, 3 and 4 pixels wide, one quarter of the screen each
' ============================================

[inits]
    LET W# = 640
    LET H# = 480
    LET BAND# = H# / 4          ' height of each quarter

    ' Black, red, green, blue, magenta, cyan, yellow, white
    DIM colors$
    colors$(0) = RGB(0, 0, 0)
    colors$(1) = RGB(255, 0, 0)
    colors$(2) = RGB(0, 255, 0)
    colors$(3) = RGB(0, 0, 255)
    colors$(4) = RGB(255, 0, 255)
    colors$(5) = RGB(0, 255, 255)
    colors$(6) = RGB(255, 255, 0)
    colors$(7) = RGB(255, 255, 255)
    LET NCOLORS# = 8

    LET col$ = 0
    LET y$ = 0
    LET wkv$ = 0

    SCREEN 0, W#, H#, "Colour pinstripe"

[main]
    SCREENLOCK ON
    FOR stripe$ = 1 TO 4                    ' stripe width in pixels
        y$ = (stripe$ - 1) * BAND#
        col$ = 0
        FOR x$ = 0 TO W# - 1 STEP stripe$
            LINE (x$, y$)-(x$ + stripe$ - 1, y$ + BAND# - 1), colors$(col$), BF
            col$ = MOD(col$ + 1, NCOLORS#)
        NEXT
    NEXT
    SCREENLOCK OFF

    wkv$ = WAITKEY()
END

' Output:
' A 640x480 window with four horizontal bands of vertical pinstripes,
' 1, 2, 3 and 4 pixels wide from top to bottom, cycling through
' black, red, green, blue, magenta, cyan, yellow and white.