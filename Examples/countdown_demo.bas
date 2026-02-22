REM ============================================
REM LOADSHEET demo: countdown 9 -> 0
REM sheet_numbers.png: 640x256, 128x128 sprites
REM Sprite 1=0, 2=1, 3=2 ... 10=9
REM ============================================

SCREEN 640, 480, "Countdown!"

DIM sprites$
LOADSHEET sprites$, 128, 128, "sheet_numbers.png"

REM Center position for a 128x128 sprite on 640x480 screen
LET x# = 256
LET y# = 176

REM Count down from 9 to 0
REM Sprite index = number + 1  (sprite 10 = digit 9, sprite 1 = digit 0)
FOR i$ = 9 TO 0 STEP -1
    CLS
    LET spriteIndex$
    LET spriteIndex$ = i$ + 1
    MOVESHAPE sprites$(spriteIndex$), x#, y#
    DRAWSHAPE sprites$(spriteIndex$)
    SLEEP 500
NEXT

END
