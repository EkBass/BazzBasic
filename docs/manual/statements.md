# Statements A-Z
This is a reference of all BazzBasic statements (commands that perform actions).

## CLS
Clear the screen.
```vb
CLS
```

See also: [Graphics Commands](graphics.md)

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

## END
Terminates program execution.
```vb
PRINT "Starting..."
END
PRINT "This never prints"
```

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

## GOTO
Jump to a label.
```vb
GOTO [skip]
PRINT "This is skipped"
[skip]
PRINT "Jumped here"
```

## INPUT and LINE INPUT
BazzBasic provides two commands for reading user input from the console.

### INPUT
Reads user input and splits it by whitespace or comma. Ideal for reading multiple values or single words.
```vb
INPUT "prompt", variable$
INPUT "prompt", var1$, var2$, var3$
INPUT variable$              ' Uses "? " as default prompt
```

**Example:**
```vb
LET name$ 
INPUT "Enter your name: ", name$
' User types: Kristian Virtanen
PRINT name$
' Output: Kristian
```

When reading multiple variables, input is split automatically:
```vb
LET firstName$, lastName$
INPUT "Enter your name: ", firstName$, lastName$
' User types: Kristian Virtanen
PRINT firstName$ + " " + lastName$
' Output: Kristian Virtanen
```

### LINE INPUT
Reads the entire line of input including spaces. Use this when you need to capture full sentences or text with spaces.
```vb
LINE INPUT "prompt", variable$
LINE INPUT variable$
```

```vb
LET name$ = ""
LINE INPUT "Enter your name: ", name$
' User types: Kristian Virtanen
PRINT name$
' Output: Kristian Virtanen
```

### Comparison
| Feature | INPUT | LINE INPUT |
|---------|-------|------------|
| Reads spaces | No (splits on space) | Yes |
| Multiple variables | Yes | No |
| Default prompt | "? " | None |

**When to use which:**
- Use `INPUT` for single words, numbers, or multiple comma-separated values
- Use `LINE INPUT` for full names, addresses, sentences, or any text containing spaces

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

You can also initialize variable with out predefined value
```vb
LET a$, b$
a$ = "Foo"
b$ = "Bar"
```

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
PRINT "He said, \"Hello\"" ' Output: He said, "Hello"
```

```vb
PRINT "Line1\nLine2"
```
Output:
```
Line 1
Line 2
```
---

## REM or '

Comment (ignored by interpreter).

```vb
REM This is a comment
' This is also a comment
PRINT "Hello" ' comment at the end of code line
```

## SLEEP
Pause execution for specified milliseconds.
```vb
PRINT "Wait..."
SLEEP 2000    ' Wait 2 seconds
PRINT "Done!"
```

## See Also

- [Control Flow](control-flow.md) - IF, FOR, WHILE, etc.
- [Functions A-Z](functions.md) - Built-in functions
- [Graphics Commands](graphics.md) - SCREEN, LINE, CIRCLE, etc.
- [Sound Commands](sounds.md) - LOADSOUND, PLAYSOUND, etc.
- [File I/O](file-io.md) - OPEN, CLOSE, READ, WRITE