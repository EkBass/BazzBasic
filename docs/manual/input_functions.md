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

Letters always return the uppercase code, whether Shift or Caps Lock is on or not: both "a" and "A" return `KEY_A#` (65).

Special keys return values of 256 or more:
- Arrow keys: KEY_UP#, KEY_DOWN#, KEY_LEFT#, KEY_RIGHT#
- Function keys: KEY_F1# through KEY_F12#
- Numpad keys (graphics screen): KEY_NUMPAD0# through KEY_NUMPAD9#, KEY_NUMPAD_PLUS#, KEY_NUMPAD_MINUS#, KEY_NUMPAD_MUL#, KEY_NUMPAD_DIV#, KEY_NUMPAD_DOT#

Numpad Enter returns `KEY_ENTER#`, the same as the main Enter key.

**INKEY reads one key at a time.** Each call takes the key out of the buffer, so a second `INKEY` in the same loop pass returns 0. Store the value once and compare the variable:
```vb
' WRONG - the second INKEY never sees the key
IF INKEY = KEY_A# THEN speed$ = speed$ + 1
IF INKEY = KEY_S# THEN speed$ = speed$ - 1

' RIGHT
LET k$ = INKEY
IF k$ = KEY_A# THEN speed$ = speed$ + 1
IF k$ = KEY_S# THEN speed$ = speed$ - 1
```

### KEYDOWN
Read key states via key constants  
**Note:** KEYDOWN is available only when the graphics screen is used. Not via console

Letter, digit and punctuation constants follow the key's label on the user's keyboard layout, the same way as INKEY: `KEYDOWN(KEY_A#)` is TRUE while the key that types "a" is held. Arrow keys, function keys, numpad and modifier keys are the same on every layout.
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
LET foo$ = WAITKEY(KEY_ENTER#)

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

### Keyboard layouts and portable controls

People run your program with different keyboard layouts (Finnish, US, German, French...). Some keys give the same value everywhere, some do not.

**Same on every layout** (safe for controls):
- Letters `KEY_A#`...`KEY_Z#` and digits `KEY_0#`...`KEY_9#` (they follow the key's label, so `KEY_A#` is always the key marked "A")
- Arrows, `KEY_SPACE#`, `KEY_ENTER#`, `KEY_ESC#`, `KEY_TAB#`, `KEY_BACKSPACE#`, Insert/Delete/Home/End/PgUp/PgDn
- Function keys `KEY_F1#`...`KEY_F12#`
- Numpad keys `KEY_NUMPAD0#`...`KEY_NUMPAD9#`, `KEY_NUMPAD_PLUS#`, `KEY_NUMPAD_MINUS#`, `KEY_NUMPAD_MUL#`, `KEY_NUMPAD_DIV#`, `KEY_NUMPAD_DOT#` (graphics screen)
- Modifier keys (`KEY_LSHIFT#`, `KEY_LCTRL#`, ...)

**Depends on the layout** (avoid for controls):
- Punctuation on the main keyboard: `+ - = , . / ; [ ] \` and the matching `KEY_*#` constants. In graphics mode INKEY and KEYDOWN see the key, not Shift or AltGr. On a US keyboard "+" is Shift plus the "=" key, so `INKEY` returns `ASC("=")`, never `ASC("+")`. On a Finnish keyboard "=" and "/" need Shift, so `KEY_EQUALS#` and `KEY_SLASH#` cannot be relied on.

> **Tip:** For speed, zoom or volume controls, use letters (for example A/S) or the numpad `+`/`-` keys instead of main-keyboard `+` and `-`.

```vb
' Speed control that works on every keyboard
LET k$ = INKEY
IF k$ = KEY_A# OR k$ = KEY_NUMPAD_PLUS# THEN speed$ = speed$ + 1
IF k$ = KEY_S# OR k$ = KEY_NUMPAD_MINUS# THEN speed$ = speed$ - 1
```

**Console mode differs:** without a graphics screen, INKEY and WAITKEY return the character that was actually typed (Shift and AltGr included), except for letters (always uppercase codes) and the special keys listed above. Numpad keys return the typed digit or operator, not the `KEY_NUMPAD*#` values. KEYDOWN is not available in console mode.

### CURPOS
Returns the current cursor position. Useful for reading where the cursor is after PRINT or LOCATE.

```vb
LOCATE 5, 10
PRINT "Hello"

PRINT CURPOS("row")   ' Output: 5
PRINT CURPOS("col")   ' Output: 15  (10 + 5 chars of "Hello")
```

| Parameter | Returns |
|-----------|---------|
| `"row"` | Current cursor row (1-based) |
| `"col"` | Current cursor column (1-based) |

---

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

### MOUSEHIDE & MOUSESHOW

In graphics screen, MOUSEHIDE hides the mouse cursor while MOUSESHOW will bring it back.

```vb
MOUSEHIDE ' hides mouse
SLEEP 5000
MOUSESHOW ' brings it back
```


