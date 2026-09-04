' ============================================
' GRAPHICS SNIPPET 1: Drawing Primitives
' PSET, LINE (line / outline box / filled box), CIRCLE
' (outline / filled), PAINT (flood fill), RGB(), POINT()
' Self-contained - no external image/font/sound files needed.
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    SCREEN 0, 640, 480, "Drawing Primitives"

    LET WHITE#  = RGB(255, 255, 255)
    LET RED#    = RGB(220, 60, 60)
    LET GREEN#  = RGB(90, 210, 110)
    LET BLUE#   = RGB(70, 140, 230)
    LET YELLOW# = RGB(240, 210, 60)
    LET PINK#   = RGB(230, 90, 200)
    LET ORANGE# = RGB(255, 150, 40)

[main]
    SCREENLOCK ON
        ' clear to black - LINE ... BF, not CLS, in graphics mode
        LINE (0, 0)-(640, 480), 0, BF

        ' --- PSET: a handful of individual pixels, close together
        ' so a single pixel is actually visible on a 640x480 screen
        PSET (50, 50), WHITE#
        PSET (52, 50), WHITE#
        PSET (50, 52), WHITE#
        PSET (52, 52), WHITE#
        DRAWSTRING "PSET (4 pixels)", 70, 44, WHITE#

        ' --- LINE: plain line, outline box, filled box
        LINE (40, 100)-(180, 160), RED#
        DRAWSTRING "LINE (line)", 190, 124, WHITE#

        LINE (40, 190)-(180, 250), GREEN#, B
        DRAWSTRING "LINE ... B (outline box)", 190, 214, WHITE#

        LINE (40, 280)-(180, 340), BLUE#, BF
        DRAWSTRING "LINE ... BF (filled box)", 190, 304, WHITE#

        ' --- CIRCLE: outline and filled
        CIRCLE (320, 130), 45, YELLOW#
        DRAWSTRING "CIRCLE (outline)", 380, 124, WHITE#

        CIRCLE (320, 280), 45, PINK#, 1
        DRAWSTRING "CIRCLE ... , 1 (filled)", 380, 274, WHITE#

        ' --- PAINT: flood fill inside a border
        LINE (480, 90)-(600, 190), WHITE#, B
        PAINT (540, 140), ORANGE#, WHITE#
        DRAWSTRING "PAINT (flood fill)", 470, 200, WHITE#
    SCREENLOCK OFF

    ' --- POINT: read a pixel back off the screen
    ' Sample the centre of the filled orange box we just painted.
    LET sampledColor$ = POINT(540, 140)

    SCREENLOCK ON
        ' Docs don't specify the exact numeric encoding POINT() returns,
        ' so treat it as an opaque value for comparison/logging purposes
        ' rather than assuming it matches a raw RGB(r,g,b) call byte-for-byte.
        DRAWSTRING "POINT(540,140) read back: " + STR(sampledColor$), 40, 420, WHITE#
        DRAWSTRING "Press any key to quit", 40, 450, RGB(180, 180, 180)
    SCREENLOCK OFF

    LET dummy$ = WAITKEY()
END
