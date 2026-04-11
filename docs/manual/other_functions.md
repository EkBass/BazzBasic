## Color Functions

### RGB(r, g, b)
Creates a color value from red, green, and blue components (0-255 each).

```vb
LET red$ = RGB(255, 0, 0)
LET green$ = RGB(0, 255, 0)
LET blue$ = RGB(0, 0, 255)
LET white$ = RGB(255, 255, 255)
LET black$ = RGB(0, 0, 0)
LET purple$ = RGB(128, 0, 128)

PSET 100, 100, RGB(255, 128, 0)          ' Orange pixel
LINE (0, 0)-(100, 100), RGB(0, 255, 0)   ' Green line
CIRCLE 200, 200, 50, RGB(255, 0, 0)      ' Red circle
```

**Tip:** Store frequently used colors in constants for better performance:
```vb
LET COLOR_PLAYER# = RGB(0, 128, 255)
LET COLOR_ENEMY# = RGB(255, 64, 64)
LET COLOR_BG# = RGB(32, 32, 48)
```

## Time Functions

### TIME(format$)
Returns current date/time as a formatted string. Uses .NET DateTime format strings.
```vb
PRINT TIME()                ' Default: "16:30:45"
PRINT TIME("HH:mm:ss")      ' "16:30:45"
PRINT TIME("dd.MM.yyyy")    ' "09.01.2026"
PRINT TIME("yyyy-MM-dd")    ' "2026-01-09"
PRINT TIME("dddd")          ' "Friday"
PRINT TIME("MMMM")          ' "January"
PRINT TIME("dd MMMM yyyy")  ' "09 January 2026"
PRINT TIME("HH:mm")         ' "16:30"
```

**Common format codes:**
| Code | Description | Example |
|------|-------------|---------|
| HH | Hour (00-23) | 16 |
| mm | Minutes | 30 |
| ss | Seconds | 45 |
| dd | Day | 09 |
| MM | Month (number) | 01 |
| MMM | Month (short) | Jan |
| MMMM | Month (full) | January |
| yy | Year (2 digits) | 26 |
| yyyy | Year (4 digits) | 2026 |
| ddd | Weekday (short) | Fri |
| dddd | Weekday (full) | Friday |

### TICKS
Returns milliseconds elapsed since program started. Useful for timing, animations, and game loops.
```vb
LET start$ = TICKS

FOR i$ = 1 TO 10000
    LET x$ = x$ + 1
NEXT

LET elapsed$ = TICKS - start$
PRINT "Time taken: "; elapsed$; " ms"
```

**Game loop timing example:**
```vb
SCREEN 12
LET lastFrame$ = TICKS
LET frameTime# = 16  ' ~60 FPS

[gameloop]
    LET now$ = TICKS
    IF now$ - lastFrame$ >= frameTime# THEN
        ' Update game logic here
        lastFrame$ = now$
    END IF

    IF INKEY = KEY_ESC# THEN END
    GOTO [gameloop]
```

## Console Functions

### GETCONSOLE(row, col, type)
Reads a character or color from a specific position on the console screen.
Console only — not available in graphics mode.

**Parameters:**
- `row` — row (1-based)
- `col` — column (1-based)
- `type` — 0 = character (as ASCII code), 1 = foreground color, 2 = background color

```vb
CLS
COLOR 11, 1
PRINT "abcdefghi"
PRINT "ABCDEFGHI"
COLOR 1, 9
PRINT "987654321"
COLOR 15, 0

PRINT "Row 2, col 5 char is: " + CHR(GETCONSOLE(2, 5, 0))  ' Output: E
PRINT "Row 1, col 2 foreground color: " + GETCONSOLE(1, 2, 1)  ' Output: 11
PRINT "Row 1, col 3 background color: " + GETCONSOLE(1, 3, 2)  ' Output: 1
```

## Command Line Arguments

### ARGCOUNT
Return the amount of arguments passed to program.

```vb
' BazzBasic.exe test.bas arg1 arg2
PRINT ARGCOUNT ' 2
```

### ARGS()
Returns certain argument, if passed.

```vb
' BazzBasic.exe test.bas arg1 arg2
PRINT ARGS(0)
PRINT ARGS(1)
' Output:
' arg1
' arg2
```

#### Important

- Always check with ARGCOUNT first, is there arguments passed
- ARGCOUNT gives the amount of arguments but ARGS() places first argument in ARGS(0), not in ARGS(1).