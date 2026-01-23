# Preprocessor

Preprocessor directives are processed before the program runs.

---

## INCLUDE

Include another BazzBasic file.

```basic
INCLUDE "utils.bas"
INCLUDE "graphics_helpers.bas"
```

The included file's contents are inserted at the INCLUDE location.

### Usage Notes

- Path is relative to the main program file
- Included files can contain functions, subroutines, or any valid code
- Avoid circular includes (file A includes B which includes A)

### Example

**main.bas:**
```basic
INCLUDE "math_utils.bas"

LET result$ = Square(5)
PRINT result$    ' Output: 25
```

**math_utils.bas:**
```basic
DEF FN Square(n$)
    RETURN n$ * n$
END DEF
```

---

## REM

Comment - ignored by the interpreter.

```basic
REM This is a comment
' This is also a comment (shorthand)

PRINT "Hello"  ' Inline comment
```

### Multi-line Comments

BazzBasic doesn't have block comments, use multiple REM lines:

```basic
REM ================================
REM Program: My Game
REM Author: Krisu
REM Date: 2026
REM ================================
```
