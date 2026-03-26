# Statements A-Z
Action commands that perform operations. For flow control (IF, FOR, WHILE, GOTO, GOSUB) see [Control Flow](control-flow.md).

## CLS
Clear the screen.
```vb
CLS
```

## COLOR
Set text foreground and background colors (0-15 palette).
```vb
COLOR 14, 1    ' Yellow text on blue background
PRINT "Colorful!"
```

See also: [Graphics Commands](graphics.md)

## INPUT and LINE INPUT
BazzBasic provides two commands for reading user input from the console.

### INPUT
Reads user input, splits on whitespace or comma.
```vb
INPUT "prompt", variable$
INPUT "prompt", var1$, var2$, var3$
INPUT variable$              ' Uses "? " as default prompt
```

```vb
LET firstName$, lastName$
INPUT "Enter your name: ", firstName$, lastName$
' User types: Kristian Virtanen
PRINT firstName$ + " " + lastName$
' Output: Kristian Virtanen
```

### LINE INPUT
Reads the entire line including spaces.
```vb
LINE INPUT "Enter your name: ", name$
' User types: Kristian Virtanen
PRINT name$
' Output: Kristian Virtanen
```

### Comparison
| Feature | INPUT | LINE INPUT |
|---------|-------|------------|
| Reads spaces | No (splits) | Yes |
| Multiple variables | Yes | No |
| Default prompt | "? " | None |

## LOCATE
Move cursor to specified position (1-based row and column).
```vb
LOCATE 10, 20
PRINT "Positioned text"
```

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
PRINT "He said, \"Hello\""  ' Output: He said, "Hello"
PRINT "Line1\nLine2"
```

## SHELL
Sends a command to the system command interpreter.  
Optional *timeout* parameter in milliseconds (default: 5000).

```vb
LET a$ = SHELL("dir *.txt")
PRINT a$

' Custom timeout (2 seconds)
LET a$ = SHELL("dir *.txt", 2000)
PRINT a$
```

## SLEEP
Pause execution for specified milliseconds.
```vb
PRINT "Wait..."
SLEEP 2000
PRINT "Done!"
```

## See Also
- [Control Flow](control-flow.md) — IF, FOR, WHILE, GOTO, GOSUB
- [Variables & Constants](variables-and-constants.md) — LET
- [Arrays & JSON](arrays_and_json.md) — DIM
- [Comments](comments.md) — REM and '
