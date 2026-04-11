' ============================================
' LOADSHEET demo: countdown 9 -> 0
' sheet_numbers.png: 640x256, 128x128 sprites
' Sprite 1=0, 2=1, 3=2 ... 10=9
' ============================================

[inits]
    LET X# = 256    ' Center position for a 128x128 sprite on 640x480 screen
    LET Y# = 176

    DIM sprites$

    SCREEN 0, 640, 480, "Countdown!"
    LOADSHEET sprites$, 128, 128, "images/sheet_numbers.png"

    LET spriteIndex$ = 0

[main]
    ' Count down from 9 to 0
    ' Sprite index = number + 1  (sprite 10 = digit 9, sprite 1 = digit 0)
    FOR i$ = 9 TO 0 STEP -1
        CLS
        spriteIndex$ = i$ + 1
        MOVESHAPE sprites$(spriteIndex$), X#, Y#
        DRAWSHAPE sprites$(spriteIndex$)
        SLEEP 500
    NEXT
END
