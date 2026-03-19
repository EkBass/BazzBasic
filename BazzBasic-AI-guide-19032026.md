> METADATA:  
> Name: BazzBasic

> Description: BazzBasic BASIC interpreter language reference. Use when writing, debugging, or explaining BazzBasic code (.bas files). Triggers on BazzBasic syntax, BASIC programming with $ and # suffixes, SDL2 graphics in BASIC, or references to BazzBasic interpreter features

> About: BazzBasic is built around one simple idea: starting programming should feel nice and even fun. Ease of learning, comfort of exploration and small but important moments of success. Just like the classic BASICs of decades past, but with a fresh and modern feel.

> Purpose: This guide has been provided with the idea that it would be easy and efficient for a modern AI to use this guide and through this either guide a new programmer to the secrets of BazzBasic or, if necessary, generate code himself.  

> Version: This guide is written for BazzBasic version 1.0 and is updated 19.03.2026 09:51 Finnish time.

---

# BazzBasic Language Reference

BazzBasic is a BASIC interpreter for .NET 10 with SDL2 graphics and SDL2_mixer sound support. It is not a clone of any previous BASIC — it aims to be easy, fun, and modern. Released under MIT license.

**Version:** 1.0 (Released February 22, 2026)  
**Author:** Kristian Virtanen (krisu.virtanen@gmail.com)  
**Platform:** Windows (x64 primary); Linux/macOS possible with effort  
**Dependencies:** SDL2.dll, SDL2_mixer (bundled).
**Github:** https://github.com/EkBass/BazzBasic    
**Homepage:** https://ekbass.github.io/BazzBasic/  
**Manual:** "https://ekbass.github.io/BazzBasic/manual/#/"  
**Examples:** "https://github.com/EkBass/BazzBasic/tree/main/Examples"  
**Github_repo:** "https://github.com/EkBass/BazzBasic"  
**Github_discussions:** "https://github.com/EkBass/BazzBasic/discussions"  
**Discord_channel:** "https://discord.com/channels/682603735515529216/1464283741919907932"  
**Thinbasic subforum:** "https://www.thinbasic.com/community/forumdisplay.php?401-BazzBasic"  

## Few examples:
**raycaster_3d:** https://raw.githubusercontent.com/EkBass/BazzBasic/refs/heads/main/Examples/raycaster_3d_optimized.bas  
**voxel_terrain:** https://raw.githubusercontent.com/EkBass/BazzBasic/refs/heads/main/Examples/voxel_terrain.bas  
**sprite load:** https://github.com/EkBass/BazzBasic/blob/main/Examples/countdown_demo.bas  
**Eliza:** https://github.com/EkBass/BazzBasic/blob/main/Examples/Eliza.bas

## This guide:
**BazzBasic AI-guide:** https://huggingface.co/datasets/EkBass/BazzBasic_AI_Guide/tree/main  
Just download the latest *BazzBasic-AI-guide-DDMMYYYY.md* where *DDMMYYYY* marks the date.


## CLI Usage

| Command | Action |
|---------|--------|
| `bazzbasic.exe` | Launch IDE |
| `bazzbasic.exe file.bas` | Run program |
| `bazzbasic.exe -exe file.bas` | Create standalone .exe |
| `bazzbasic.exe -lib file.bas` | Create tokenized library (.bb) |

IDE shortcuts: F5 run, Ctrl+N/O/S new/open/save, Ctrl+Shift+S save as, Ctrl+W close tab, Ctrl+F find, Ctrl+H replace.

In-built IDE is just a small very basic IDE which fires up when double-clicking *bazzbasic.exe*. Usage of Notepad++ etc. recommended.

### External syntax colors.
BazzBasic IDE is developed just so double-clicking *bazzbasic.exe* would bring something in the screen of a newbie. A person can use it, but it stands no chance for more advanced editors.

There are syntax color files for *Notepad++*, *Geany* and *Visual Studio Code* available at https://github.com/EkBass/BazzBasic/tree/main/extras

---

## Syntax Fundamentals

### Variables and Constants
Forget traditional BASIC types. Suffixes in BazzBasic define mutability, not data type.

Variables and arrays in BazzBasic are typeless: hold numbers or strings interchangeably

- $ = Mutable Variable  
- # = Immutable Constant


```basic
LET a$                  ' Declare without value
LET name$ = "Alice"		' Variable, string (mutable, $ suffix)
LET age$ = 19			' Variable, integer (mutable, $ suffix)
LET price$ = 1.99		' Variable, decimal (mutable, $ suffix)
LET PI# = 3.14159		' Constant (immutable, # suffix)
LET x$, y$, z$ = 10		' Multiple declaration
```
- All variables require `$` suffix, constants require `#`
- Typeless: hold numbers or strings interchangeably
- Must declare with `LET` before use (except FOR/INPUT which auto-declare)
- Assignment after declaration: `x$ = x$ + 1` (no LET needed)
- **Case-insensitive**: `PRINT`, `print`, `Print` all work
- Naming: letters, numbers, underscores; cannot start with number

### Comparison Behavior
`"123" = 123` is TRUE (cross-type comparison), but slower — keep types consistent.

### Scope
- Main code shares one scope (even inside IF blocks)
- `DEF FN` functions have completely isolated scope
- Only global constants (`#`) are accessible inside functions

### Multiple Statements Per Line
```basic
COLOR 14, 0 : CLS : PRINT "Hello"
```

### Comments
```basic
REM This is a comment
' This is also a comment
PRINT "Hello" ' Inline comment
```

### Escape Sequences in Strings
| Sequence | Result |
|----------|--------|
| `\"` | Quote |
| `\n` | Newline |
| `\t` | Tab |
| `\\` | Backslash |

---

## Arrays
```basic
DIM scores$                        	' Declare (must use DIM)
DIM a$, b$, c$                     	' Multiple declaration
scores$(0) = 95                    	' Numeric index (0-based)
scores$("name") = "Alice"          	' String key (associative)
matrix$(0, 1) = "A2"				' Multi-dimensional
data$(1, "header") = "Name"			' Mixed indexing
```
- Array names must end with `$`
- Fully dynamic: numeric, string, multi-dimensional, mixed indexing
- Arrays **cannot** be passed directly to functions — pass values of individual elements
- Accessing uninitialized elements is an error — check with `HASKEY` first

### Array Functions
| Function | Description |
|----------|-------------|
| `LEN(arr$())` | Element count (note: empty parens) |
| `HASKEY(arr$(key))` | 1 if exists, 0 if not |
| `DELKEY arr$(key)` | Remove element |
| `DELARRAY arr$` | Remove entire array (can re-DIM after) |

---

## Operators

### Arithmetic
`+` (add/concatenate), `-`, `*`, `/` (returns float)

### Comparison
`=` or `==`, `<>` or `!=`, `<`, `>`, `<=`, `>=`

### Logical
`AND`, `OR`, `NOT`

### Precedence (high to low)
`()` → `NOT` → `*`, `/` → `+`, `-` → comparisons → `AND` → `OR`

---

## User-Defined Functions
```basic
DEF FN add$(a$, b$)
    RETURN a$ + b$
END DEF
PRINT FN add$(3, 4)               ' Call with FN prefix
```
- Function name **must** end with `$`, called with `FN` prefix
- **Must be defined before called** (top of file or via INCLUDE)
- Parameters passed **by value**
- Completely isolated scope: no access to global variables, only global constants (`#`)
- Labels inside functions are local — GOTO/GOSUB **cannot** jump outside (error)
- Supports recursion
- Tip: put functions in separate files, `INCLUDE` at program start

---

## Control Flow

### IF Statements
```basic
' Block IF (END IF and ENDIF both work)
IF x$ > 10 THEN
    PRINT "big"
ELSEIF x$ > 5 THEN
    PRINT "medium"
ELSE
    PRINT "small"
ENDIF

' One-line IF (GOTO/GOSUB only)
IF lives$ = 0 THEN GOTO [game_over]
IF key$ = KEY_ESC# THEN GOTO [menu] ELSE GOTO [continue]
IF ready$ = 1 THEN GOSUB [start_game]
```

### FOR Loops
```basic
FOR i$ = 1 TO 10 STEP 2           ' Auto-declares variable, STEP optional
    PRINT i$
NEXT

FOR i$ = 10 TO 1 STEP -1          ' Count down
    PRINT i$
NEXT
```

### WHILE Loops
```basic
WHILE x$ < 100
    x$ = x$ * 2
WEND
```

### Labels, GOTO, GOSUB
```basic
[start]
GOSUB [subroutine]
GOTO [start]
END

[subroutine]
    PRINT "Hello"
RETURN
```

### Dynamic Jumps (Labels as Variables)
```basic
LET target$ = "[menu]"
GOTO target$                       ' Variable holds label string
LET dest# = "[jump]"
GOSUB dest#                        ' Constants work too
```

If you want to make a dynamic jump, use the "[" and "]" characters to indicate to BazzBasic that it is specifically a label.

```basic
LET target$ = "[menu]" ' Correct way
LET target$ = "menu" ' Incorrect way
```

### Other
| Command | Description |
|---------|-------------|
| `SLEEP ms` | Pause execution |
| `END` | Terminate program |

---

## I/O Commands

| Command | Description |
|---------|-------------|
| `PRINT expr; expr` | Output (`;` = no space, `,` = tab) |
| `PRINT "text";` | Trailing `;` suppresses newline |
| `INPUT "prompt", var$` | Read input (splits on whitespace/comma) |
| `INPUT "prompt", a$, b$` | Read multiple values |
| `INPUT var$` | Default prompt `"? "` |
| `LINE INPUT "prompt", var$` | Read entire line including spaces |
| `CLS` | Clear screen |
| `LOCATE row, col` | Move cursor (1-based) |
| `COLOR fg, bg` | Set colors (0-15 palette) |
| `GETCONSOLE(row, col, type)` | Console read: 0=char(ASCII), 1=fg, 2=bg |
| `INKEY` | Non-blocking key check (0 if none, >256 for special keys) |
| `KEYDOWN(key#)` | Returns TRUE if specified key is currently held down |

### INPUT vs LINE INPUT
| Feature | INPUT | LINE INPUT |
|---------|-------|------------|
| Reads spaces | No (splits) | Yes |
| Multiple variables | Yes | No |
| Default prompt | `"? "` | None |

### INKEY vs KEYDOWN
| Feature | INKEY | KEYDOWN |
|---------|-------|---------|
| Returns | Key value or 0 | TRUE/FALSE |
| Key held | Reports once | Reports while held |
| Use case | Menu navigation | Game movement, held keys |

```basic
' KEYDOWN example — smooth movement
IF KEYDOWN(KEY_LEFT#) THEN x$ = x$ - 5
IF KEYDOWN(KEY_RIGHT#) THEN x$ = x$ + 5
```

---

## Math Functions

| Function | Description |
|----------|-------------|
| `ABS(n)` | Absolute value |
| `ATAN(n)` | Returns the arc tangent of n |
| `BETWEEN(n, min, max)` | TRUE if n is in range |
| `CEIL(n)` | Rounds up |
| `CINT(n)` | Convert to integer (rounds) |
| `COS(n)` | Returns the cosine of an angle |
| `CLAMP(n, min, max)` | Constrain value to range |
| `DEG(radians)` | Radians to degrees |
| `DISTANCE(x1,y1,x2,y2)` | 2D Euclidean distance |
| `DISTANCE(x1,y1,z1,x2,y2,z2)` | 3D Euclidean distance |
| `EXP(n)` | Exponential (e^n) |
| `FLOOR(n)` | Rounds down |
| `INT(n)` | Truncate toward zero |
| `LERP(start, end, t)` | Linear interpolation (t = 0.0-1.0) |
| `LOG(n)` | Natural log |
| `MAX(a, b)` | Returns higher from a & b |
| `MIN(a, b)` | Returns smaller from a & b |
| `MOD(a, b)` | Remainder |
| `POW(base, exp)` | Power |
| `RAD(degrees)` | Degrees to radians |
| `RND(n)` | Random 0 to n-1 |
| `ROUND(n)` | Standard rounding |
| `SGN(n)` | Sign (-1, 0, 1) |
| `SIN(n)` | Returns the sine of n |
| `SQR(n)` | Square root |
| `TAN(n)` | Returns the tangent of n |


### Math Constants
| Constant | Value | Notes |
|----------|-------|-------|
| `PI` | 3.14159265358979 | 180° |
| `HPI` | 1.5707963267929895 | 90° (PI/2) |
| `QPI` | 0.7853981633974483 | 45° (PI/4) |
| `TAU` | 6.283185307179586 | 360° (PI*2) |
| `EULER` | 2.718281828459045 | e |

All are raw-coded values — no math at runtime, maximum performance.

### Fast Trigonometry (Lookup Tables)
For graphics-intensive applications — ~20x faster than SIN/COS, 1-degree precision.

```basic
FastTrig(TRUE)           ' Enable lookup tables (~5.6 KB)

LET x$ = FastCos(45)    ' Degrees, auto-normalized to 0-359
LET y$ = FastSin(90)
LET r$ = FastRad(180)   ' Degrees to radians (doesn't need FastTrig)

FastTrig(FALSE)          ' Free memory when done
```

**Use FastTrig when:** raycasting, rotating sprites, particle systems, any loop calling trig hundreds of times per frame.
**Use regular SIN/COS when:** high precision needed, one-time calculations.

---

## String Functions

| Function | Description |
|----------|-------------|
| `ASC(s$)` | Character to ASCII code |
| `CHR(n)` | ASCII code to character |
| `INSTR(s$, search$)` | Find substring position (0 = not found) |
| `INSTR(start$, s$, search$)` | Find substring starting from position start$ (0 = not found) |
| `INVERT(s$)` | Inverts a string |
| `LCASE(s$)` | Converts to lowercase |
| `LEFT(s$, n)` | First n characters |
| `LEN(s$)` | String length |
| `LTRIM(s$)` | Left trim |
| `MID(s$, start, len)` | Substring (1-based) len optional |
| `REPEAT(s$, n)` | Repeat s$ for n times |
| `REPLACE(s$, old$, new$)` | Replace all occurrences |
| `RIGHT(s$, n)` | Last n characters |
| `RTRIM(s$)` | Right trim |
| `SPLIT(s$, delim$, arr$)` | Split into array |
| `SRAND(n)` | Returns random string length of n from allowed chars (letters, numbers and "_") |
| `STR(n)` | Number to string |
| `TRIM(s$)` | Remove leading/trailing spaces |
| `UCASE(s$)` | Converts to uppercase |
| `VAL(s$)` | String to number |

---

## File I/O

```basic
' Simple text file
FileWrite "save.txt", data$
LET data$ = FileRead("save.txt")

' Array read/write (key=value format)
DIM a$
a$("name") = "player1"
a$("score") = 9999
FileWrite "scores.txt", a$

DIM b$
LET b$ = FileRead("scores.txt")
PRINT b$("name")                   ' Output: player1
```

**Array file format:**
```
name=player1
score=9999
multi,dim,key=value
```

| Function/Command | Description |
|---------|-------------|
| `FileRead(path)` | Read file; returns string or populates array |
| `FileWrite path, data` | Write string or array to file |
| `FileExists(path)` | Returns 1 if file exists, 0 if not |
| `FileDelete path` | Delete a file |
| `FileList(path$, arr$)` | List files in directory into array |

---

## Network (HTTP)

```basic
DIM response$
LET response$ = HTTPGET("https://api.example.com/data")
PRINT response$

DIM result$
LET result$ = HTTPPOST("https://api.example.com/post", "{""key"":""value""}")
PRINT result$
```

- Returns response body as string
- Supports HTTPS
- Use `""` inside strings to escape quotes in JSON bodies
- Timeout handled gracefully — returns error message string on failure

---

## Sound (SDL2_mixer)

```basic
DIM bgm$
LET bgm$ = LOADSOUND("music.wav")
LET sfx$ = LOADSOUND("jump.wav")

SOUNDREPEAT(bgm$)                  ' Loop continuously
SOUNDONCE(sfx$)                    ' Play once
SOUNDSTOP(bgm$)                    ' Stop specific sound
SOUNDSTOPALL                       ' Stop all sounds
```

| Command | Description |
|---------|-------------|
| `LOADSOUND(path)` | Load sound file, returns ID |
| `SOUNDONCE(id$)` | Play once |
| `SOUNDREPEAT(id$)` | Loop continuously |
| `SOUNDSTOP(id$)` | Stop specific sound |
| `SOUNDSTOPALL` | Stop all sounds |

- Formats: WAV (recommended), MP3, others via SDL2_mixer
- Thread-safe, multiple simultaneous sounds supported
- Load sounds once at startup for performance

---

## Graphics (SDL2)

### Screen Setup
```basic
SCREEN 12                          ' 640x480 VGA mode
SCREEN 0, 800, 600, "Title"       ' Custom size with title
```
Modes: 0=640x400, 1=320x200, 2=640x350, 7=320x200, 9=640x350, 12=640x480, 13=320x200

### Fullscreen
```basic
FULLSCREEN TRUE                    ' Borderless fullscreen
FULLSCREEN FALSE                   ' Windowed mode
```
Call after `SCREEN`.

### VSync
```basic
VSYNC(TRUE)                        ' Enable (default) — caps to monitor refresh
VSYNC(FALSE)                       ' Disable — unlimited FPS, may tear
```

### Double Buffering (Required for Animation)
```basic
SCREENLOCK ON                      ' Start buffering
' ... draw commands ...
SCREENLOCK OFF                     ' Display frame
SLEEP 16                           ' ~60 FPS
```
`SCREENLOCK` without argument = `SCREENLOCK ON`. Do math/logic outside SCREENLOCK block.

### Drawing Primitives
| Command | Description |
|---------|-------------|
| `PSET (x, y), color` | Draw pixel |
| `POINT(x, y)` | Read pixel color (returns RGB integer) |
| `LINE (x1,y1)-(x2,y2), color` | Draw line |
| `LINE (x1,y1)-(x2,y2), color, B` | Box outline |
| `LINE (x1,y1)-(x2,y2), color, BF` | Filled box (faster than CLS) |
| `CIRCLE (cx, cy), r, color` | Circle outline |
| `CIRCLE (cx, cy), r, color, 1` | Filled circle |
| `PAINT (x, y), fill, border` | Flood fill |
| `RGB(r, g, b)` | Create color (0-255 each) |

### Shape/Sprite System
```basic
DIM sprite$
sprite$ = LOADSHAPE("RECTANGLE", 50, 50, RGB(255,0,0))  ' Types: RECTANGLE, CIRCLE, TRIANGLE
sprite$ = LOADIMAGE("player.png")                        ' PNG (with alpha) or BMP

MOVESHAPE sprite$, x, y            ' Position (top-left point)
ROTATESHAPE sprite$, angle          ' Absolute degrees
SCALESHAPE sprite$, 1.5             ' 1.0 = original
SHOWSHAPE sprite$
HIDESHAPE sprite$
DRAWSHAPE sprite$                   ' Render
REMOVESHAPE sprite$                 ' Free memory
```
- PNG recommended (full alpha transparency 0-255), BMP for legacy
- Images positioned by their **top-left point**
- Rotation is absolute, not cumulative
- Always REMOVESHAPE when done to free memory

### Sprite Sheets (LOADSHEET)
```basic
DIM sprites$
LOADSHEET sprites$, spriteW, spriteH, "sheet.png"

' Access sprites by 1-based index
MOVESHAPE sprites$(index$), x#, y#
DRAWSHAPE sprites$(index$)
```
- Sprites indexed left-to-right, top-to-bottom starting at 1
- All sprites must be same size (spriteW x spriteH)

### Mouse Input (Graphics Mode Only)
| Function | Description |
|----------|-------------|
| `MOUSEX` / `MOUSEY` | Cursor position |
| `MOUSEB` | Button state (bitmask, use `AND`) |

Button constants: `MOUSE_LEFT#`=1, `MOUSE_RIGHT#`=2, `MOUSE_MIDDLE#`=4

### Color Palette (0-15)
| 0 Black | 4 Red | 8 Dark Gray | 12 Light Red |
|---------|-------|-------------|--------------|
| 1 Blue | 5 Magenta | 9 Light Blue | 13 Light Magenta |
| 2 Green | 6 Brown | 10 Light Green | 14 Yellow |
| 3 Cyan | 7 Light Gray | 11 Light Cyan | 15 White |

### Performance Tips
1. Use `SCREENLOCK ON/OFF` for all animation
2. `LINE...BF` is faster than `CLS` for clearing
3. Store `RGB()` values in constants
4. REMOVESHAPE unused shapes
5. SLEEP 16 for ~60 FPS
6. Do math/logic outside SCREENLOCK block

---

## Built-in Constants

### Arrow Keys
| | | |
|---|---|---|
| `KEY_UP#` | `KEY_DOWN#` | `KEY_LEFT#` |
| `KEY_RIGHT#` | | |

### Special Keys
| | | |
|---|---|---|
| `KEY_ESC#` | `KEY_TAB#` | `KEY_BACKSPACE#` |
| `KEY_ENTER#` | `KEY_SPACE#` | `KEY_INSERT#` |
| `KEY_DELETE#` | `KEY_HOME#` | `KEY_END#` |
| `KEY_PGUP#` | `KEY_PGDN#` | |

### Modifier Keys
| | | |
|---|---|---|
| `KEY_LSHIFT#` | `KEY_RSHIFT#` | `KEY_LCTRL#` |
| `KEY_RCTRL#` | `KEY_LALT#` | `KEY_RALT#` |
| `KEY_LWIN#` | `KEY_RWIN#` | |

### Function Keys
| | | |
|---|---|---|
| `KEY_F1#` | `KEY_F2#` | `KEY_F3#` |
| `KEY_F4#` | `KEY_F5#` | `KEY_F6#` |
| `KEY_F7#` | `KEY_F8#` | `KEY_F9#` |
| `KEY_F10#` | `KEY_F11#` | `KEY_F12#` |

### Numpad Keys
| | | |
|---|---|---|
| `KEY_NUMPAD0#` | `KEY_NUMPAD1#` | `KEY_NUMPAD2#` |
| `KEY_NUMPAD3#` | `KEY_NUMPAD4#` | `KEY_NUMPAD5#` |
| `KEY_NUMPAD6#` | `KEY_NUMPAD7#` | `KEY_NUMPAD8#` |
| `KEY_NUMPAD9#` | | |

### Punctuation Keys
| | | |
|---|---|---|
| `KEY_COMMA#` | `KEY_DOT#` | `KEY_MINUS#` |
| `KEY_EQUALS#` | `KEY_SLASH#` | `KEY_BACKSLASH#` |
| `KEY_SEP#` | `KEY_GRAVE#` | `KEY_LBRACKET#` |
| `KEY_RBRACKET#` | | |

### Alphabet Keys
| | | |
|---|---|---|
| `KEY_A#` | `KEY_B#` | `KEY_C#` |
| `KEY_D#` | `KEY_E#` | `KEY_F#` |
| `KEY_G#` | `KEY_H#` | `KEY_I#` |
| `KEY_J#` | `KEY_K#` | `KEY_L#` |
| `KEY_M#` | `KEY_N#` | `KEY_O#` |
| `KEY_P#` | `KEY_Q#` | `KEY_R#` |
| `KEY_S#` | `KEY_T#` | `KEY_U#` |
| `KEY_V#` | `KEY_W#` | `KEY_X#` |
| `KEY_Y#` | `KEY_Z#` | |

### Number Keys
| | | |
|---|---|---|
| `KEY_0#` | `KEY_1#` | `KEY_2#` |
| `KEY_3#` | `KEY_4#` | `KEY_5#` |
| `KEY_6#` | `KEY_7#` | `KEY_8#` |
| `KEY_9#` | | |

### Mouse
```basic
MOUSE_LEFT# = 1, MOUSE_RIGHT# = 2, MOUSE_MIDDLE# = 4
```

### Logical
`TRUE` = 1, `FALSE` = 0

---

## Source Control

### INCLUDE
```basic
INCLUDE "other_file.bas"           ' Insert source at this point
INCLUDE "MathLib.bb"               ' Include compiled library
```

### Libraries (.bb files)
```basic
' MathLib.bas — can ONLY contain DEF FN functions
DEF FN add$(x$, y$)
    RETURN x$ + y$
END DEF
```
Compile: `bazzbasic.exe -lib MathLib.bas` → `MathLib.bb`

```basic
INCLUDE "MathLib.bb"
PRINT FN MATHLIB_add$(5, 3)        ' Auto-prefix: FILENAME_ + functionName
```
- Libraries can only contain `DEF FN` functions
- Library functions can access main program constants (`#`)
- Version-locked: .bb may not work across BazzBasic versions

---

## Common Patterns

### Game Loop
```basic
SCREEN 12
LET running$ = TRUE

WHILE running$
    LET key$ = INKEY
    IF key$ = KEY_ESC# THEN running$ = FALSE

    ' Math and logic here

    SCREENLOCK ON
    LINE (0,0)-(640,480), 0, BF       ' Fast clear
    ' Draw game state
    SCREENLOCK OFF
    SLEEP 16
WEND
END
```

### HTTP + Data
```basic
DIM response$
LET response$ = HTTPGET("https://api.example.com/scores")
PRINT response$

DIM payload$
LET payload$ = HTTPPOST("https://api.example.com/submit", "{""score"":9999}")
PRINT payload$
```

### Save/Load with Arrays
```basic
DIM save$
save$("level") = 3
save$("hp") = 80
FileWrite "save.txt", save$

DIM load$
LET load$ = FileRead("save.txt")
PRINT load$("level")               ' Output: 3
```

### Sound with Graphics
```basic
SCREEN 12
LET bgm$ = LOADSOUND("music.wav")
LET sfx$ = LOADSOUND("jump.wav")
SOUNDREPEAT(bgm$)

WHILE INKEY <> KEY_ESC#
    IF INKEY = KEY_SPACE# THEN SOUNDONCE(sfx$)
    SLEEP 16
WEND
SOUNDSTOPALL
END
```

---

## Code Style Conventions

**Variables** — `camelCase$`
```basic
LET playerName$ = "Hero"
LET score$ = 0
```

**Constants** — `UPPER_SNAKE_CASE#`
```basic
LET MAX_HEALTH# = 100
LET SCREEN_W# = 640
```

**Arrays** — `camelCase$` (like variables, declared with DIM)
```basic
DIM scores$
DIM playerData$
```

**User-defined functions** — `PascalCase$`
```basic
DEF FN CalculateDamage$(attack$, defence$)
DEF FN IsColliding$(x$, y$)
```

**Labels** — descriptive names, `[sub:]` prefix recommended for subroutines
```basic
[sub:DrawPlayer]                   ' Subroutine
[gameLoop]                         ' Jump target
```

### Program Structure
1. Constants first
2. User-defined functions (or INCLUDE them)
3. Main program loop
4. Subroutines (labels) last

### Subroutine Indentation
```basic
[sub:DrawPlayer]
    MOVESHAPE player$, x$, y$
    DRAWSHAPE player$
RETURN
```