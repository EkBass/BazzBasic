![BazzBasic logo"](https://github.com/EkBass/BazzBasic/blob/main/img/bazzbasic-colors-small.png))

# BazzBasic

A BASIC interpreter written in FreeBASIC. Features user-defined functions, associative arrays, and modern error handling.

*"Bazz" - a nod to bass guitar and the golden era of 80s BASIC interpreters.*

## Features

- **Variables** with `$` suffix: `LET name$ = "value"`
- **Constants** with `#` suffix: `LET PI# = 3.14159` (immutable)
- **Dynamic arrays** with mixed indexing: `DIM data$` then `data$(1, "key", 3) = value`
- **User-defined functions** with recursion: `DEF FN factorial(n$)`
- **Control structures**: IF/ELSEIF/ELSE/ENDIF, FOR/NEXT, WHILE/WEND, GOTO, GOSUB
- **Built-in functions**: Math, string manipulation, array operations
- **Standalone executables**: Bundle your program with the interpreter
- **Error messages** with line numbers

## Building

Requires [FreeBASIC](https://www.freebasic.net/) compiler.

```cmd
build.bat
```

Or manually:
```cmd
fbc64 -t 65536 bazzbasic.bas
fbc64 bazzpack.bas
```

## Usage

**Run a BASIC program:**
```cmd
bazzbasic.exe program.bas
```

**Create standalone executable:**
```cmd
bazzpack.exe program.bas
```
This creates `program.exe` that runs without needing the interpreter.

```cmd
bazzpack.exe game.bas mygame.exe
```
Specify custom output name.

## Quick Reference

### Variables and Constants

```basic
REM Variables ($) - can be changed
LET name$ = "Alice"
LET age$ = 30
LET a$, b$, c$ = 100     ' Multiple declarations

REM Constants (#) - immutable
LET MAX# = 999
LET PI# = 3.14159
```

### Arrays

```basic
REM Must declare with DIM first
DIM scores$
DIM matrix$, lookup$

REM Numeric indexing
scores$(0) = 95
scores$(1) = 87

REM Multi-dimensional
matrix$(0, 0) = "top-left"
matrix$(1, 2) = "row 1, col 2"

REM Associative (string keys)
lookup$("name") = "Bob"
lookup$("age") = 25

REM Mixed indexing
data$(1, "header", 0) = "value"

REM Array functions
PRINT LEN(scores$())              ' Number of elements
PRINT HASKEY(lookup$("name"))     ' 1 if exists, 0 if not
DELKEY lookup$("name")            ' Remove key
```

### Control Flow

```basic
REM Block IF
IF score$ >= 90 THEN
    PRINT "Excellent!"
ELSEIF score$ >= 70 THEN
    PRINT "Good"
ELSE
    PRINT "Keep trying"
END IF

REM One-line IF
IF ready$ = 1 THEN GOTO [start] ELSE GOTO [wait]

REM FOR loop
FOR i$ = 1 TO 10 STEP 2
    PRINT i$
NEXT

REM WHILE loop
LET count$ = 0
WHILE count$ < 5
    PRINT count$
    count$ = count$ + 1
WEND

REM Labels and GOTO/GOSUB
[main]
    GOSUB [greet]
    GOTO [end]

[greet]
    PRINT "Hello!"
    RETURN

[end]
    END
```

### User-Defined Functions

```basic
REM Simple function
DEF FN double(x$)
    RETURN x$ * 2
END DEF

PRINT FN double(21)    ' Output: 42

REM Recursive function
DEF FN factorial(n$)
    IF n$ <= 1 THEN
        RETURN 1
    END IF
    RETURN n$ * FN factorial(n$ - 1)
END DEF

PRINT FN factorial(5)  ' Output: 120
```

### Input/Output

```basic
PRINT "Hello, World!"
PRINT "Value: "; x$; " units"

INPUT "Enter name: ", name$

LET key$ = INKEY$      ' Non-blocking keyboard input

CLS                    ' Clear screen
LOCATE 10, 20          ' Position cursor
COLOR 14, 1            ' Yellow on blue
SLEEP 1000             ' Wait 1 second
```

### Built-in Functions

**Math:** `ABS`, `INT`, `SQR`, `SIN`, `COS`, `TAN`, `LOG`, `EXP`, `SGN`, `RND`

**String:** `LEN`, `LEFT$`, `RIGHT$`, `MID$`, `CHR$`, `ASC`, `STR$`, `VAL`, `UCASE$`, `LCASE$`, `INSTR`

**Array:** `LEN(array$())`, `HASKEY(array$(key))`

### Built-in Constants

```basic
REM Keyboard
KEY_UP#, KEY_DOWN#, KEY_LEFT#, KEY_RIGHT#
KEY_ENTER#, KEY_ESC#, KEY_SPACE#, KEY_TAB#, KEY_BACKSPACE#
KEY_F1# ... KEY_F12#
KEY_HOME#, KEY_END#, KEY_PGUP#, KEY_PGDN#, KEY_INSERT#, KEY_DELETE#

REM Mouse
MOUSE_LEFT#, MOUSE_RIGHT#, MOUSE_MIDDLE#
```

## Example Program

```basic
REM Number guessing game
LET secret# = INT(RND * 100) + 1
LET guesses$ = 0

PRINT "Guess a number between 1 and 100"

[guess]
    INPUT "Your guess: ", guess$
    guesses$ = guesses$ + 1
    
    IF guess$ = secret# THEN
        PRINT "Correct! You got it in "; guesses$; " tries!"
        END
    ELSEIF guess$ < secret# THEN
        PRINT "Too low!"
    ELSE
        PRINT "Too high!"
    END IF
    
    GOTO [guess]
```

## Error Handling

Errors display line number and code:

```
=== VIRHE ===
Rivi 15: unknown$(0) = "test"
Taulukkoa ei ole maaritelty, kayta ensin DIM: unknown$
=============
```

## Limitations

- Maximum 256 program lines
- Maximum 32 tokens per line
- No file I/O (OPEN, CLOSE, etc.)
- No graphics commands (PSET, LINE, CIRCLE)
- No sound commands

## License

MIT License - See LICENSE file

## Author

Kristian Virtanen (2025-2026)
