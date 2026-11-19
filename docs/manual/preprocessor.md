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

- The path is relative to the file that has the INCLUDE line. If the file is not found there, BazzBasic looks in the main program's folder
- Included files can contain functions, constants, or any valid BazzBasic code
- INCLUDE of the same `.bas` file a second time does nothing: it is skipped with a warning, e.g. `Warning: Line 2: Include 'helpers.bas' already included, skipping.` The program still runs
- Circular includes stop the program before it starts: A includes B which includes A, or a file includes itself. The message is `Error: Circular INCLUDE detected: <file>`

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

### Errors in Included Files

Since 1.8, an error inside an included file names that file and the line in it.

**main.bas:**
```vb
INCLUDE "helpers.bas"

PRINT "Start"
PRINT FN Greet$("Anna")
```

**helpers.bas:**
```vb
DEF FN Greet$(name$)
    RETURN "Hello, " + nmae$
END DEF
```

Output:
```
Start
Error in helpers.bas line 2: Undefined variable: NMAE$
```

- The file name is shown as written in the INCLUDE line
- Errors found before the program starts have the form `Error: helpers.bas line 2: ...`
- Errors in the main program keep the usual form, `Error at line N: ...` (or `Error: Line N: ...`). N is the line in the main file; lines of included files are not counted

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
- `.bb` files are not tied to one release, but a library compiled with a newer BazzBasic may use commands an older interpreter does not have

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
