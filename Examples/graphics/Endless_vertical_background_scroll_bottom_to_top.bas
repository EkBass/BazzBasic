' ============================================
' Endless vertical background scroll (bottom to top)
' BazzBasic: https://github.com/EkBass/BazzBasic
' Built by Claude with bazzbasic-ai.guide
' ============================================

[inits]
    LET SCREEN_W#      = 640
    LET SCREEN_H#      = 480
    LET IMG_H#         = 480         ' height of background.png
    LET SCROLL_SPEED#  = 60          ' pixels per SECOND (not per frame)
    LET MAX_DELTA#     = 100         ' ms; caps the jump after a stall (e.g. window drag)

    ' Image anchor correction. LOADIMAGE images are documented as top-left
    ' anchored, so both offsets are 0. If your build turns out to position
    ' images by their center, set ANCHOR_X# = 320 and ANCHOR_Y# = 240.
    LET ANCHOR_X#      = 0
    LET ANCHOR_Y#      = 0

    SCREEN 0, SCREEN_W#, SCREEN_H#, "Scrolling background"

    ' Two handles for the same file: one per copy on screen.
    LET BG_A# = LOADIMAGE(PRG_ROOT# + "background.png")
    LET BG_B# = LOADIMAGE(PRG_ROOT# + "background.png")

    LET scrollY$   = 0               ' exact position, fractional
    LET drawY$     = 0               ' whole-pixel position used for drawing
    LET now$       = 0
    LET delta$     = 0
    LET lastTick$  = TICKS

[main]
    WHILE INKEY <> KEY_ESC#
        GOSUB [sub:update]
        GOSUB [sub:draw]
        SLEEP 16
    WEND

    REMOVESHAPE BG_A#
    REMOVESHAPE BG_B#
END

' --------------------------------------------
[sub:update]
    now$      = TICKS
    delta$    = MIN(now$ - lastTick$, MAX_DELTA#)
    lastTick$ = now$

    ' Move up: speed (px/s) * elapsed time (s)
    scrollY$ = scrollY$ - SCROLL_SPEED# * delta$ / 1000

    ' Wrap. WHILE rather than IF, so it still works if a frame moved more than IMG_H#.
    WHILE scrollY$ <= -IMG_H#
        scrollY$ = scrollY$ + IMG_H#
    WEND

    ' Round once, and use the same value for both copies
    drawY$ = FLOOR(scrollY$)
RETURN

' --------------------------------------------
[sub:draw]
    SCREENLOCK ON
        MOVESHAPE BG_A#, ANCHOR_X#, drawY$ + ANCHOR_Y#
        DRAWSHAPE BG_A#

        MOVESHAPE BG_B#, ANCHOR_X#, drawY$ + IMG_H# + ANCHOR_Y#
        DRAWSHAPE BG_B#

        ' ...draw your game objects here, after the background...
    SCREENLOCK OFF
RETURN

' Output:
' A 640x480 window where background.png scrolls endlessly upward
' at 60 px/s with no visible gap. ESC quits.
