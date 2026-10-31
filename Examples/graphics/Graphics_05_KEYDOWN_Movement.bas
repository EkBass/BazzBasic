' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Graphics snippet 5: smooth, multi-key movement of a circle with KEYDOWN (arrow keys or WASD), where every held key is checked independently each frame so diagonals work; graphics mode only.
' CATEGORY: input
' TAGS: graphics tutorial, keydown, keyboard movement, wasd, arrow keys
' MINVERSION: 1.5
' ============================================
' Contrast with Minefield.bas / RoadRace.bas: those are console-mode
' games, so they had no KEYDOWN available and had to poll INKEY in
' small time-sliced chunks to stay responsive, catching at most one
' key per chunk. Here, every held key is checked independently every
' single frame, so opposite/adjacent keys can combine naturally -
' e.g. holding UP and LEFT together moves diagonally, which the
' console versions could not do at all.
'
' Self-contained - no external files needed.

[inits]
    SCREEN 0, 640, 480, "KEYDOWN Movement"

    LET SCREEN_W# = 640
    LET SCREEN_H# = 480
    LET RADIUS#   = 18
    LET SPEED#    = 4
    LET PLAYER_COLOR# = RGB(255, 210, 60)

    LET playerX$ = 320
    LET playerY$ = 240

[main]
    WHILE INKEY <> KEY_ESC#
        ' each of these is checked independently, every frame -
        ' that's what makes diagonals and instant response possible
        IF KEYDOWN(KEY_UP#) OR KEYDOWN(KEY_W#) THEN
            playerY$ = playerY$ - SPEED#
        END IF
        IF KEYDOWN(KEY_DOWN#) OR KEYDOWN(KEY_S#) THEN
            playerY$ = playerY$ + SPEED#
        END IF
        IF KEYDOWN(KEY_LEFT#) OR KEYDOWN(KEY_A#) THEN
            playerX$ = playerX$ - SPEED#
        END IF
        IF KEYDOWN(KEY_RIGHT#) OR KEYDOWN(KEY_D#) THEN
            playerX$ = playerX$ + SPEED#
        END IF

        IF playerX$ - RADIUS# < 0 THEN
            playerX$ = RADIUS#
        END IF
        IF playerX$ + RADIUS# > SCREEN_W# THEN
            playerX$ = SCREEN_W# - RADIUS#
        END IF
        IF playerY$ - RADIUS# < 0 THEN
            playerY$ = RADIUS#
        END IF
        IF playerY$ + RADIUS# > SCREEN_H# THEN
            playerY$ = SCREEN_H# - RADIUS#
        END IF

        SCREENLOCK ON
            LINE (0, 0)-(640, 480), 0, BF
            CIRCLE (playerX$, playerY$), RADIUS#, PLAYER_COLOR#, 1
            DRAWSTRING "Arrows or WASD move smoothly - try holding two at once.", 10, 10, RGB(255, 255, 255)
            DRAWSTRING "ESC to quit", 10, 34, RGB(180, 180, 180)
        SCREENLOCK OFF

        SLEEP 16
    WEND
END
