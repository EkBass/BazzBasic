## Input Functions

### INKEY
Returns current key press (non-blocking). Returns 0 if no key pressed.
```vb
[loop]
    LET k$ = INKEY
    IF k$ = 0 THEN GOTO [loop]
    IF k$ = KEY_ESC# THEN END
    PRINT "Key code: "; k$
    GOTO [loop]
```

Special keys return values > 256:
- Arrow keys: KEY_UP#, KEY_DOWN#, KEY_LEFT#, KEY_RIGHT#
- Function keys: KEY_F1# through KEY_F12#

### KEYDOWN
Read key states via key constants  
**Note:** KEYDOWN availale only when graphics screen used. Not via console
```vb
REM KEYDOWN Test
SCREEN 12

LET x$ = 320
LET y$ = 240

WHILE INKEY <> KEY_ESC#
    SCREENLOCK ON
    LINE (0,0)-(640,480), 0, BF
    
    IF KEYDOWN(KEY_W#) THEN y$ = y$ - 2
    IF KEYDOWN(KEY_S#) THEN y$ = y$ + 2
    IF KEYDOWN(KEY_A#) THEN x$ = x$ - 2
    IF KEYDOWN(KEY_D#) THEN x$ = x$ + 2
    
    IF KEYDOWN(KEY_LSHIFT#) THEN
        CIRCLE (x$, y$), 20, RGB(255, 0, 0), 1
    ELSE
        CIRCLE (x$, y$), 10, RGB(0, 255, 0), 1
    END IF
    
    LOCATE 1, 1
    COLOR 15, 0
    PRINT "WASD=Move  SHIFT=Big  ESC=Quit"
    LOCATE 2, 1
    PRINT "X:"; x$; " Y:"; y$; "   "
    
    SCREENLOCK OFF
    SLEEP 16
WEND
END
```

### WAITKEY
Halts execution until one of the specified keys is pressed. Returns the key value.

```vb
' Wait for ENTER only
PRINT "Press ENTER to continue"
WAITKEY(KEY_ENTER#)

' Wait for any of several keys, capture result
PRINT "Press A, B or ESC"
LET k$ = WAITKEY(KEY_A#, KEY_B#, KEY_ESC#)
PRINT "You pressed: "; k$

' Wait for any key
PRINT "Press any key..."
LET k$ = WAITKEY()
PRINT "Key value: "; k$
```

| Feature | INKEY | KEYDOWN | WAITKEY |
|---------|-------|---------|---------|
| Blocking | No | No | Yes |
| Returns | Key value or 0 | TRUE/FALSE | Key value |
| Use case | Game loops | Held keys | Menus, pauses |

### MOUSEX, MOUSEY
**Note: Only available when graphics screen is open.**

Returns mouse cursor position.
```vb
SCREEN 12
[loop]
    LOCATE 1, 1
    PRINT "X:"; MOUSEX; " Y:"; MOUSEY; "   "
    GOTO [loop]
```

### MOUSELEFT, MOUSERIGHT, MOUSEMIDDLE
**Note: Only available when graphics screen is open.**

Returns 1 if the specified mouse button is currently pressed, 0 otherwise.
```vb
IF MOUSELEFT   THEN PRINT "Left clicked"
IF MOUSERIGHT  THEN PRINT "Right clicked"
IF MOUSEMIDDLE THEN PRINT "Middle clicked"
```