# BazzBasic Reserved Words

Complete list of all reserved keywords. All are case-insensitive.  
Variables must end with `$`, constants with `#` — they cannot share names with keywords.

---

## Control Flow
| Keyword | Description |
|---------|-------------|
| `DEF` | Begin function definition (`DEF FN name$(...)`) |
| `DIM` | Declare array |
| `ELSE` | Alternative branch in IF block |
| `ELSEIF` | Chained condition in IF block |
| `END` | Terminate program; also `END IF`, `END DEF` |
| `ENDIF` | Close IF block (alias for `END IF`) |
| `FN` | Call user-defined function (`FN name$(...)`) |
| `FOR` | Begin counted loop |
| `GOSUB` | Call subroutine at label |
| `GOTO` | Jump to label |
| `IF` | Conditional branch |
| `INCLUDE` | Insert source file or library |
| `LET` | Declare variable or constant |
| `NEXT` | End FOR loop |
| `PRINT` | Output to screen |
| `REM` | Comment (also `'`) |
| `RETURN` | Return from GOSUB or DEF FN |
| `STEP` | Loop increment in FOR |
| `THEN` | Required after IF condition |
| `TO` | Range separator in FOR |
| `WEND` | End WHILE loop |
| `WHILE` | Begin conditional loop |

---

## I/O
| Keyword | Description |
|---------|-------------|
| `CLS` | Clear screen |
| `COLOR` | Set text foreground/background color |
| `CURPOS` | Read cursor row or col: `CURPOS("row")` / `CURPOS("col")` |
| `GETCONSOLE` | Read character or color from console position |
| `INPUT` | Read user input |
| `LINE INPUT` | Read full line including spaces |
| `LOCATE` | Move text cursor |
| `SLEEP` | Pause execution (milliseconds) |

---

## Graphics
| Keyword | Description |
|---------|-------------|
| `CIRCLE` | Draw circle or filled circle |
| `DRAWSHAPE` | Render a shape/image to screen |
| `FULLSCREEN` | Toggle borderless fullscreen |
| `HIDESHAPE` | Hide shape without removing |
| `LINE` | Draw line, box outline, or filled box |
| `LOADIMAGE` | Load PNG/BMP (or URL) as shape |
| `LOADSHEET` | Load sprite sheet into array |
| `LOADSHAPE` | Create geometric shape |
| `MOVESHAPE` | Set shape position |
| `PAINT` | Flood fill |
| `POINT` | Read pixel color |
| `PSET` | Draw single pixel |
| `REMOVESHAPE` | Delete shape and free memory |
| `RGB` | Create color value from R, G, B components |
| `ROTATESHAPE` | Rotate shape (absolute degrees) |
| `SCALESHAPE` | Scale shape |
| `SCREEN` | Initialize graphics window |
| `SCREENLOCK` | Buffer drawing (`ON`) / present frame (`OFF`) |
| `SHOWSHAPE` | Make hidden shape visible |
| `VSYNC` | Enable/disable vertical sync |

---

## Sound
| Keyword | Description |
|---------|-------------|
| `LOADSOUND` | Load sound file, returns ID |
| `SOUNDONCE` | Play sound once (non-blocking) |
| `SOUNDONCEWAIT` | Play sound once (blocking) |
| `SOUNDREPEAT` | Loop sound continuously |
| `SOUNDSTOP` | Stop specific sound |
| `SOUNDSTOPALL` | Stop all sounds |

---

## File
| Keyword | Description |
|---------|-------------|
| `FILEAPPEND` | Append string to file |
| `FILEDELETE` | Delete a file |
| `FILEEXISTS` | Returns 1 if file exists |
| `FILEREAD` | Read file as string or key=value array |
| `FILEWRITE` | Write string or array to file |
| `SHELL` | Run system command, returns output |

---

## Network & Data
| Keyword | Description |
|---------|-------------|
| `ASARRAY` | Parse JSON string into array |
| `ASJSON` | Convert array to JSON string |
| `BASE64DECODE` | Decode Base64 string |
| `BASE64ENCODE` | Encode string to Base64 |
| `HTTPGET` | HTTP GET request |
| `HTTPPOST` | HTTP POST request |
| `LOADJSON` | Load JSON file into array |
| `SAVEJSON` | Save array as JSON file |
| `SHA256` | SHA256 hash (64-char hex) |

---

## Math Functions
| Keyword | Description |
|---------|-------------|
| `ABS` | Absolute value |
| `ATAN` | Arc tangent |
| `BETWEEN` | TRUE if value is within range |
| `CEIL` | Round up |
| `CINT` | Round to nearest integer |
| `CLAMP` | Constrain value to range |
| `COS` | Cosine (radians) |
| `DEG` | Radians to degrees |
| `DISTANCE` | 2D or 3D Euclidean distance |
| `EULER` | Euler's number (e = 2.71828...) |
| `EXP` | e raised to power |
| `FASTCOS` | Fast cosine (degrees, lookup table) |
| `FASTRAD` | Fast degrees-to-radians |
| `FASTSIN` | Fast sine (degrees, lookup table) |
| `FASTTRIG` | Enable/disable fast trig lookup tables |
| `FLOOR` | Round down |
| `HPI` | π/2 (90°) |
| `INT` | Truncate toward zero |
| `LERP` | Linear interpolation |
| `LOG` | Natural logarithm |
| `MAX` | Higher of two values |
| `MIN` | Lower of two values |
| `MOD` | Remainder |
| `PI` | π (3.14159...) |
| `POW` | Power |
| `QPI` | π/4 (45°) |
| `RAD` | Degrees to radians |
| `RND` | Random integer 0 to n-1 |
| `ROUND` | Standard rounding |
| `SGN` | Sign (-1, 0, 1) |
| `SIN` | Sine (radians) |
| `SQR` | Square root |
| `TAN` | Tangent (radians) |
| `TAU` | 2π (360°) |

---

## String Functions
| Keyword | Description |
|---------|-------------|
| `ASC` | Character to ASCII code |
| `CHR` | ASCII code to character |
| `INSTR` | Find substring position |
| `INVERT` | Reverse string |
| `LCASE` | Convert to lowercase |
| `LEFT` | First n characters |
| `LEN` | String length (also array element count) |
| `LTRIM` | Strip leading whitespace |
| `MID` | Substring |
| `REPEAT` | Repeat string n times |
| `REPLACE` | Replace all occurrences |
| `RIGHT` | Last n characters |
| `RTRIM` | Strip trailing whitespace |
| `SPLIT` | Split string into array |
| `SRAND` | Random alphanumeric string |
| `STR` | Number to string |
| `TRIM` | Strip leading and trailing whitespace |
| `UCASE` | Convert to uppercase |
| `VAL` | String to number |

---

## Input & Mouse
| Keyword | Description |
|---------|-------------|
| `INKEY` | Non-blocking key check |
| `KEYDOWN` | TRUE if key is held (graphics mode only) |
| `MOUSEMIDDLE` | 1 if middle button pressed (graphics mode) |
| `MOUSELEFT` | 1 if left button pressed (graphics mode) |
| `MOUSERIGHT` | 1 if right button pressed (graphics mode) |
| `MOUSEX` | Mouse cursor X position (graphics mode) |
| `MOUSEY` | Mouse cursor Y position (graphics mode) |
| `WAITKEY` | Block until key pressed |

---

## Arrays
| Keyword | Description |
|---------|-------------|
| `DELARRAY` | Remove entire array |
| `DELKEY` | Remove one array element |
| `HASKEY` | 1 if array element exists |
| `JOIN` | Merge two arrays; src2$ overwrites src1$ on conflict |

---

## Time
| Keyword | Description |
|---------|-------------|
| `TICKS` | Milliseconds since program start |
| `TIME` | Current date/time as formatted string |

---

## Logic
| Keyword | Description |
|---------|-------------|
| `AND` | Logical AND |
| `FALSE` | 0 |
| `NOT` | Logical NOT |
| `OFF` | Alias for FALSE (used with SCREENLOCK, VSYNC) |
| `ON` | Alias for TRUE (used with SCREENLOCK, VSYNC) |
| `OR` | Logical OR |
| `TRUE` | 1 |

---

## Built-in Constants
These are auto-initialized at startup — no `LET` required.

| Constant | Value |
|----------|-------|
| `BBVER#` | BazzBasic version string (e.g. `"1.1d"`) |
| `PRG_ROOT#` | Program base directory path |
| `TRUE` | 1 |
| `FALSE` | 0 |
| `PI` | 3.14159265358979 |
| `HPI` | 1.5707963267929895 (π/2) |
| `QPI` | 0.7853981633974483 (π/4) |
| `TAU` | 6.283185307179586 (2π) |
| `EULER` | 2.718281828459045 (e) |

### Keyboard constants
`KEY_UP#` `KEY_DOWN#` `KEY_LEFT#` `KEY_RIGHT#`  
`KEY_ESC#` `KEY_ENTER#` `KEY_SPACE#` `KEY_TAB#` `KEY_BACKSPACE#`  
`KEY_INSERT#` `KEY_DELETE#` `KEY_HOME#` `KEY_END#` `KEY_PGUP#` `KEY_PGDN#`  
`KEY_F1#` … `KEY_F12#`  
`KEY_A#` … `KEY_Z#`  
`KEY_0#` … `KEY_9#`  
`KEY_NUMPAD0#` … `KEY_NUMPAD9#`  
`KEY_LSHIFT#` `KEY_RSHIFT#` `KEY_LCTRL#` `KEY_RCTRL#` `KEY_LALT#` `KEY_RALT#` `KEY_LWIN#` `KEY_RWIN#`  
`KEY_COMMA#` `KEY_DOT#` `KEY_MINUS#` `KEY_EQUALS#` `KEY_SLASH#` `KEY_BACKSLASH#` `KEY_GRAVE#` `KEY_LBRACKET#` `KEY_RBRACKET#` `KEY_SEP#`
