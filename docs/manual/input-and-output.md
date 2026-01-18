# Input and Output

## Basic Output

Output text and values to the screen.

### PRINT

```basic
PRINT "Hello, World!"
PRINT 42
PRINT 3.14159
```

### Multiple Values

Use comma `,` to separate values:

```basic
LET name$ = "Alice"
LET score$ = 100
PRINT "Player:", name$, "Score:", score$
' Output: Player: Alice   Score:  100
```

Use semicolon `;` for no separator:

```basic
PRINT "X="; 10; " Y="; 20
' Output: X=10 Y=20
```

### Expressions

```basic
PRINT 2 + 2
PRINT "Result: "; 10 * 5
PRINT "Name: "; UCASE("alice")
```

### Empty Line

```basic
PRINT ""
' or just
PRINT
```

## Escaped characters

### Quot

```basic
PRINT "He said, \"Hello World\""
' Output: He said, "Hello World"
```

### New line

```basic
PRINT "Line 1\nLine 2"
' Output: Line 1
' Line 2
```


### Tab

```basic
PRINT "Tab\there"
' Output: Tab    here
```


### Backslash

```basic
PRINT "Path: C:\\Users\\Krisu"
' Output: Path: C:\Users\Krisu
```


### Invalid

```basic
PRINT "Invalid: \x keeps backslash"
' Output: Invalid: \x keeps backslash
```

## INPUT Statement

Read user input into a variable.
INPUT can declare variable just as LET

### Basic Input

```basic
INPUT "Enter your name: ", name$
PRINT "Hello, "; name$
```

### Input with multiple values
```basic
INPUT "Enter x, y: ", x$, y$
```

### Numeric Input

If the user enters a number, it's stored as a number:

```basic
INPUT "Enter your age: ", age$
PRINT "In 10 years you'll be "; age$ + 10
```

### Default Prompt

If no prompt is given, uses "? ":

```basic
INPUT answer$
' Shows: ?
```

## SLEEP

```basic
PRINT "Wait 2 seconds..."
SLEEP 2000
PRINT "Done!"
```

## Keyboard Input (INKEY)

Non-blocking keyboard check. Returns 0 if no key pressed.

### Basic Usage

```basic
LET k$
[loop]
    k$ = INKEY
    IF k$ <> 0 THEN
        PRINT "Key pressed: "; k$
    END IF
    GOTO [loop]
```


### Key Code Reference

**Regular keys:** ASCII value (A=65, a=97, Space=32, etc.)

**Special keys:** 256 + scan code

| Constant | Value | Key |
|----------|-------|-----|
| KEY_BACKSPACE# | 8 | Backspace |
| KEY_TAB# | 9 | Tab |
| KEY_ENTER# | 13 | Enter |
| KEY_ESC# | 27 | Escape |
| KEY_SPACE# | 32 | Space |
| KEY_UP# | 328 | Up Arrow |
| KEY_DOWN# | 336 | Down Arrow |
| KEY_LEFT# | 331 | Left Arrow |
| KEY_RIGHT# | 333 | Right Arrow |
| KEY_INSERT# | 338 | Insert |
| KEY_DELETE# | 339 | Delete |
| KEY_HOME# | 327 | Home |
| KEY_END# | 335 | End |
| KEY_PGUP# | 329 | Page Up |
| KEY_PGDN# | 337 | Page Down |
| KEY_F1# - KEY_F12# | 315-324, 389-390 | Function keys |

## See also
Following functionalities are explained at [Graphics-Documentation](Graphics-Documentation)

### CLS
Clear the screen

### LOCATE
Moves cursor on console

### COLOR
Changes font and background colors

### GETCONSOLE
Reads characters and colors from console