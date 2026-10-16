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



---

## Gamepad

BazzBasic reads game controllers (Xbox, PlayStation, Switch Pro and most compatible pads) through SDL2. USB and Bluetooth both work. *Added in v1.5.*

- Works in **console and graphics mode**. No `SCREEN` needed.
- Pads are numbered from **0**. Up to 8 pads. A pad gets its number when it connects and keeps it while connected, so player 2 does not become player 1 if player 1's pad drops.
- A pad that is not connected reads as "nothing pressed": `PADBUTTON` returns FALSE, `PADAXIS` returns 0 and `PADNAME` returns `""`. No error, so a game keeps running if a pad is unplugged.
- Pads can be plugged in or switched on while the program runs. They are found within about a quarter of a second.

| Function | Returns |
|----------|---------|
| `GAMEPADS()` | Number of connected pads |
| `PADBUTTON(pad, button)` | TRUE while the button is held |
| `PADAXIS(pad, axis)` | Sticks -1.0 … 1.0, triggers 0.0 … 1.0 |
| `PADNAME(pad)` | Controller name, e.g. `"PS4 Controller"` |
| `PADRUMBLE pad, strength, ms` | (statement) Vibrate, strength 0.0 … 1.0 |

### GAMEPADS

**DISCLAIMER:**  
BazzBasic version 1.5 has been tested with only one PS4-compatible Bluetooth controller. Therefore, for the time being, I cannot guarantee that GamePad support will work with all different types of controllers.



Returns how many pads are connected. Parentheses are optional.
```vb
IF GAMEPADS() = 0 THEN PRINT "Connect a gamepad"
PRINT "Pads: "; GAMEPADS()
IF GAMEPADS() > 0 THEN PRINT "Pad 0: "; PADNAME(0)
```

### PADBUTTON
Returns TRUE while the button is held down, like `KEYDOWN` for the keyboard.

Button constants use the Xbox layout. On PlayStation pads: `PAD_A#` = Cross, `PAD_B#` = Circle, `PAD_X#` = Square, `PAD_Y#` = Triangle, `PAD_BACK#` = Share, `PAD_START#` = Options.

| Constant | Button |
|----------|--------|
| `PAD_A#`, `PAD_B#`, `PAD_X#`, `PAD_Y#` | Face buttons |
| `PAD_UP#`, `PAD_DOWN#`, `PAD_LEFT#`, `PAD_RIGHT#` | D-pad |
| `PAD_LB#`, `PAD_RB#` | Upper shoulder buttons (L1 / R1) |
| `PAD_LSTICK#`, `PAD_RSTICK#` | Pressing a stick down (L3 / R3) |
| `PAD_BACK#`, `PAD_START#`, `PAD_GUIDE#` | Back/Share, Start/Options, Xbox/PS button |
| `PAD_MISC#` | Extra button (Xbox Series Share, PS5 mic, Switch Capture) |
| `PAD_TOUCHPAD#` | PlayStation touchpad click |

Buttons 16–19 are the back paddles on pads that have them (Xbox Elite). A button number outside 0–20 is an error.

> The lower shoulder buttons (L2 / R2) are **triggers**, not buttons. Read them with `PADAXIS(pad, PAD_LT#)` and `PADAXIS(pad, PAD_RT#)`. Do not use `PADBUTTON(0, PAD_LT#)`: the constants are just numbers, so it reads a different button (Back) without an error. To treat a trigger as a button, use `PADAXIS(0, PAD_RT#) > 0.5`.

`PADBUTTON` is TRUE on every loop pass while the button is held. To react once per press, remember the previous state:
```vb
LET jumpWas$ = FALSE
LET jumpNow$ = FALSE
WHILE TRUE
    jumpNow$ = PADBUTTON(0, PAD_A#)
    IF jumpNow$ AND NOT jumpWas$ THEN PRINT "Jump!"   ' only on the press
    jumpWas$ = jumpNow$
    SLEEP 16
WEND
```

### PADAXIS
Returns the position of a stick or trigger.

| Constant | Axis | Range |
|----------|------|-------|
| `PAD_LX#`, `PAD_LY#` | Left stick | -1.0 … 1.0 |
| `PAD_RX#`, `PAD_RY#` | Right stick | -1.0 … 1.0 |
| `PAD_LT#`, `PAD_RT#` | Triggers (L2 / R2) | 0.0 … 1.0 |

- X: negative = left, positive = right. Y: negative = **up**, positive = down, the same direction as screen coordinates.
- A small dead zone is built in: a stick that rests slightly off-centre still reads exactly 0, so things do not drift by themselves.
- An axis number outside 0–5 is an error.

```vb
' Analog movement: small push = slow, full push = fast
x$ = x$ + PADAXIS(0, PAD_LX#) * SPEED#
y$ = y$ + PADAXIS(0, PAD_LY#) * SPEED#

' Use a stick like a D-pad
IF PADAXIS(0, PAD_LX#) < -0.5 THEN PRINT "Left"
```

### PADNAME
Returns the controller's name, or `""` if the pad is not connected.
```vb
PRINT PADNAME(0)    ' Output e.g.: PS4 Controller
```

Many third-party pads report themselves as a PS4 or Xbox controller. That is normal and the buttons still map correctly.

### PADRUMBLE
Vibrates the pad. `strength` is 0.0 … 1.0, `ms` is the duration in milliseconds. The program does not wait for it. Pads without vibration ignore it. Parentheses are optional.
```vb
PADRUMBLE 0, 0.5, 200       ' half power for 0.2 seconds
PADRUMBLE(0, 1, 500)        ' same thing with parentheses
```

### Example: pad and keyboard together
```vb
SCREEN 0, 640, 480, "Gamepad demo"
LET x$ = 320
LET y$ = 240
LET dx$, dy$
WHILE INKEY <> KEY_ESC# AND NOT PADBUTTON(0, PAD_BACK#)
    dx$ = PADAXIS(0, PAD_LX#)
    dy$ = PADAXIS(0, PAD_LY#)
    IF PADBUTTON(0, PAD_LEFT#)  OR KEYDOWN(KEY_LEFT#)  THEN dx$ = -1
    IF PADBUTTON(0, PAD_RIGHT#) OR KEYDOWN(KEY_RIGHT#) THEN dx$ = 1
    IF PADBUTTON(0, PAD_UP#)    OR KEYDOWN(KEY_UP#)    THEN dy$ = -1
    IF PADBUTTON(0, PAD_DOWN#)  OR KEYDOWN(KEY_DOWN#)  THEN dy$ = 1
    x$ = CLAMP(x$ + dx$ * 5, 10, 629)
    y$ = CLAMP(y$ + dy$ * 5, 10, 469)

    SCREENLOCK ON
    LINE (0,0)-(639,479), 0, BF
    CIRCLE (x$, y$), 10, RGB(0, 255, 0), 1
    SCREENLOCK OFF
    SLEEP 16
WEND
END
```

More examples: `Examples/GamePad/`.

### Troubleshooting
- **`GAMEPADS()` returns 0:** check that Windows sees the pad (Settings → Bluetooth & devices). A Bluetooth pad must be paired and switched on. Try a USB cable to rule out Bluetooth.
- **A stick or button does nothing:** many third-party pads have a MODE or ANALOG button that turns the right stick into a D-pad or switches the sticks off. Run `Examples/GamePad/gamepad_test.bas` to see exactly what the program receives.
- **Tools such as DS4Windows or Steam Input** can hide or re-map the real pad. Close them if buttons come out wrong.
