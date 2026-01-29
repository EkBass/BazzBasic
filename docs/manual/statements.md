# Statements A-Z

This is a reference of all BazzBasic statements (commands that perform actions).

---

## CLS

Clear the screen.

```vb
CLS
```

See also: [Graphics Commands](graphics.md)

---

## COLOR

Set text foreground and background colors.

```vb
COLOR foreground, background
```

```vb
COLOR 14, 1    ' Yellow text on blue background
PRINT "Colorful!"
```

See also: [Graphics Commands](graphics.md)

---

## END

Terminates program execution.

```vb
PRINT "Starting..."
END
PRINT "This never prints"
```

---

## GOSUB / RETURN

Call a subroutine and return.

```vb
GOSUB [mysub]
PRINT "Back from subroutine"
END

[mysub]
PRINT "In subroutine"
RETURN
```

---

## GOTO

Jump to a label.

```vb
GOTO [skip]
PRINT "This is skipped"
[skip]
PRINT "Jumped here"
```

---

## INPUT

Read user input into a variable.

```vb
INPUT "Enter your name: ", name$
INPUT "Enter x, y: ", x$, y$
INPUT answer$    ' Uses "? " as default prompt
```

---

## LET

Declare and assign a variable.

```vb
LET x$ = 10
LET name$ = "Alice"
LET PI# = 3.14159    ' Constant (immutable)
```

Note: `LET` keyword is optional after declaration:
```vb
LET x$ = 10
x$ = 20    ' OK after initial declaration
```

---

## LOCATE

Move cursor to specified position.

```vb
LOCATE row, column
```

```vb
LOCATE 10, 20
PRINT "Positioned text"
```

See also: [Graphics Commands](graphics.md)

---

## PRINT

Output text and values to the screen.

```vb
PRINT "Hello, World!"
PRINT 42
PRINT "Value: "; x$
PRINT "A", "B", "C"    ' Tab-separated
PRINT "X="; 10;        ' No newline at end
```

### Escape Characters

| Escape | Result |
|--------|--------|
| `\"` | Quote |
| `\n` | New line |
| `\t` | Tab |
| `\\` | Backslash |

```vb
PRINT "He said, \"Hello\""
PRINT "Line1\nLine2"
```

---

## REM

Comment (ignored by interpreter).

```vb
REM This is a comment
' This is also a comment
```

---

## SLEEP

Pause execution for specified milliseconds.

```vb
PRINT "Wait..."
SLEEP 2000    ' Wait 2 seconds
PRINT "Done!"
```

---

## See Also

- [Control Flow](control-flow.md) - IF, FOR, WHILE, etc.
- [Functions A-Z](functions.md) - Built-in functions
- [Graphics Commands](graphics.md) - SCREEN, LINE, CIRCLE, etc.
- [Sound Commands](sounds.md) - LOADSOUND, PLAYSOUND, etc.
- [File I/O](file-io.md) - OPEN, CLOSE, READ, WRITE
