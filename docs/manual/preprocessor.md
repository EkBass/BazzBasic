# Preprocessor & Source Control

BazzBasic supports splitting your program across multiple files. This helps keep large programs organized and allows reusable code libraries.

## INCLUDE

Include another BazzBasic source file. The contents of the included file are inserted at the exact point of the INCLUDE statement — as if you had written the code there directly.

```vb
INCLUDE "utils.bas"
INCLUDE "graphics_helpers.bas"
INCLUDE "MathLib.bb"    ' Compiled library
```

### Usage Notes

- Path is relative to the main program file
- Included files can contain functions, constants, or any valid BazzBasic code
- Avoid circular includes (A includes B which includes A)

### Example

**main.bas:**
```vb
INCLUDE "helpers.bas"

LET result$ = FN Square$(5)
PRINT result$    ' Output: 25
```

**helpers.bas:**
```vb
DEF FN Square$(n$)
    RETURN n$ * n$
END DEF
```

BazzBasic reads these as a single program:

```vb
DEF FN Square$(n$)
    RETURN n$ * n$
END DEF

LET result$ = FN Square$(5)
PRINT result$    ' Output: 25
```

## Compiled Libraries (.bb)

Library files contain only `DEF FN` functions and are compiled to a tokenized `.bb` format.

```vb
' Compile:  bazzbasic.exe -lib MathLib.bas  →  MathLib.bb
INCLUDE "MathLib.bb"

' Library functions are prefixed with FILENAME_
PRINT FN MATHLIB_Square$(5)    ' Output: 25
```

- Libraries can only contain `DEF FN` functions
- Functions are auto-prefixed with the filename: `MATHLIB_functionname$`
- Library functions can read global constants (`#`) from the main program
- `.bb` files are version-locked — may not work across BazzBasic versions

## Recommended Program Structure

For larger programs, split code into focused files and INCLUDE them:

```vb
' main.bas
INCLUDE "constants.bas"
INCLUDE "functions.bas"
INCLUDE "inits.bas"

[main]
    GOSUB [sub:update]
    GOSUB [sub:draw]
    SLEEP 16
    GOTO [main]
END

INCLUDE "subs.bas"
```

## See Also
- [Comments](comments.md) — REM and '
- [Libraries](libraries.md) — creating and distributing .bb files
