# News and changes
These changes are about the current source code. These are effected once new binary release is published

## Mar 2026

## 22nd Mar 2026

Quick "rerelease" as 1.1b

- I forgot to update version from source
- I forgot to update syntax files for Notepad++, VS Code, Geany and built-in IDE
- Headers "support" not documented
  
```vb
HTTPGET(url$)                           ' works as before
HTTPGET(url$, headers$)         ' new, optional

HTTPPOST(url$, body$)                       ' works as before
HTTPPOST(url$, body$, headers$)     ' new, optional
```

## 22nd Mar 2026

Released as version 1.1

## 22nd Mar 2026

At Rosetta code I got inspired to create pendulum animation.
[pendulum_animation.bas](Examples/pendulum_animation.bas)

## 21st Mar 2026

BazzBasic-AI_guide.md is a tutorial for modern AI's. With it, AI can easily teach the user how to use BazzBasic.

Just download the file, attach it as project file or via prompt to AI and you are cool to go.  

[Technical guide ment for AI](https://github.com/EkBass/BazzBasic/discussions/26)

---
Unfortunately, the GamePad support I planned didn't make it to version 1.1

The reason is that the SDL2 library has been having problems for some time, especially with Bluetooth gamepads.

I didn't want to do something half-hearted, so the gamepad support is now on hold until SDL2 gets its library back in condition.

Instead, I added three other functions that I've had in mind for some time: *BASE64ENCODE*, *BASE64DECODE* and *SHA256*

## 21st Mar 2026

Added JSON support: `ASJSON`, `ASARRAY`, `LOADJSON`, `SAVEJSON`

```vb
DIM data$
data$("name") = "Alice"
data$("score") = 9999
data$("address,city") = "New York"

LET json$ = ASJSON(data$)
' Output: {"name":"Alice","score":9999,"address":{"city":"New York"}}

DIM back$
LET count$ = ASARRAY(back$, json$)
PRINT back$("name")         ' Alice
PRINT back$("address,city") ' New York

SAVEJSON data$, "save.json"
DIM loaded$
LOADJSON loaded$, "save.json"
```

Added `BASE64ENCODE`, `BASE64DECODE` and `SHA256`

```vb
LET encoded$ = BASE64ENCODE("Hello, World!")
PRINT encoded$              ' SGVsbG8sIFdvcmxkIQ==

LET decoded$ = BASE64DECODE(encoded$)
PRINT decoded$              ' Hello, World!

LET hash$ = SHA256("password123")
PRINT hash$                 ' ef92b778... (64-char lowercase hex)
```

---

## 14th Mar 2026

## Sound system fix — parallel audio playback

**Problem:** The old implementation loaded MP3/OGG/FLAC files with `Mix_LoadMUS()` which uses the SDL2_mixer's global Music channel — only one sound at a time.

**Fixes:**
- All sounds are now loaded with `Mix_LoadWAV()` → play on their own Mix_Channels in parallel
- `SDL_INIT_AUDIO` added to `SDL_Init()` call in `Graphics.cs`
- `SoundManager` calls `SDL_Init` + `SDL_InitSubSystem` to ensure audio subsystem even without `SCREEN` command
- `SDL_AUDIODRIVER=directsound` set in `Program.cs` to work around WASAPI issues (Nahimic middleware causes "Invalid Handle" error in WASAPI)
- `PlayOnceWait` gets 50ms delay before polling loop due to DirectSound startup delay


## 7th Mar 2026

Added HTTP support for LOADIMAGE
### LOADIMAGE with url
```vb
LET sprite$ = LOADIMAGE("https://example.com/sprite.png")
' → downloads "sprite.png" to root of your program
' → sprite$ works just as with normal file load

' to remove or move the downloaded file
SHELL("move sprite.png images\sprite.png")   ' move to subfolder
' or
FileDelete "sprite.png"                       ' just delete it
```

Added WAITKEY() function. 

## WAITKEY
Halts the execution until requested key is pressed.

```vb
' Wait just the ENTER key
PRINT "ENTER"
PRINT WAITKEY(KEY_ENTER#) ' output: 13

' Wait any of "a", "b" or "esc" keys
PRINT "A, B or ESC"
PRINT WAITKEY(KEY_A#, KEY_B#, KEY_ESC#) ' output: depends of your choice of key

PRINT "Press any key..." 
LET a$ = WAITKEY()
PRINT a$ ' output: val of key you pressed
```

## 2nd Mar 2026

Added SHELL feature

```vb
' SHELL arg$, timeout$
' Sends a command to the system command interpreter  
' Param *timeout$* is optional. If not given, standard 5000 milliseconds used for timeout.

' with default timeout option
LET a$ = SHELL("dir *.txt")
PRINT a$

' sets timeout to 2 seconds
' 1000ms = 1 second etc.
LET a$ = SHELL("dir *.txt", 2000)
PRINT a$
```


## Feb 2026

## 22nd Feb. 2026

- Released as version 1.0, source and binary
  
  
## 21st Feb. 2026
- FILEREAD and FILEWRITE now supports arrays too.
- **Example with array:**
```vb
LET FILENAME# = "array.txt"
DIM a$
a$("first") = 1
a$("second") = 2
a$("third") = 3
a$("fourth") = "Four"
a$("fourth", "temp") = "Temp"
FileWrite FILENAME#, a$
DIM b$ = FileRead(FILENAME#)
PRINT b$("fourth", "temp") ' Output: Temp
```

**array.txt content:**
```
first=1
second=2
third=3
fourth=Four
fourth,temp=Temp
```

## 21st Feb. 2026

- Added statements HTTPPOST and HTTPGET. These statements allow you to send HTTP POST and GET requests to a specified URL and retrieve the response as a string.
```vb
DIM response$
LET response$ = HTTPGET("https://httpbin.org/get")
PRINT response$

DIM postResult$
LET postResult$ = HTTPPOST("https://httpbin.org/post", "{""key"":""value""}")
PRINT postResult$
```


- Added statement LOADSHEET(<path>, <size x>, <size t>)
```vb
REM ============================================
REM LOADSHEET demo: countdown 9 -> 0
REM sheet_numbers.png: 640x256, 128x128 sprites
REM Sprite 1=0, 2=1, 3=2 ... 10=9
REM ============================================

SCREEN 640, 480, "Countdown!"

DIM sprites$
LOADSHEET sprites$, 128, 128, "examples/sheet_numbers.png"

REM Center position for a 128x128 sprite on 640x480 screen
LET x# = 256
LET y# = 176

REM Count down from 9 to 0
REM Sprite index = number + 1  (sprite 10 = digit 9, sprite 1 = digit 0)
FOR i$ = 9 TO 0 STEP -1
    CLS
    LET spriteIndex$
    LET spriteIndex$ = i$ + 1
    MOVESHAPE sprites$(spriteIndex$), x#, y#
    DRAWSHAPE sprites$(spriteIndex$)
    SLEEP 500
NEXT

END
```

- - Added FULLSCREEN TRUE/FALSE. Enables or disables borderless fullscreen mode.
```vb
SCREEN 640, 480, "My title"
FULLSCREEN TRUE   ' borderless fullscreen on
FULLSCREEN FALSE  ' Windowed mode
```


## 14th Feb. 2026

- Fixed INPUT and LINE INPUT when using GFX. Binary release also updated

## 14th Feb. 2026

- Added KEYDOWN(<key constant#>) function with what it's possible to check state of all key constants
- Added key constants to all keys I could imagine. Will add more if figured out some is missing

##  13th Feb. 2026

- Released as version 0.9

## 12th Feb. 2026

- Added LERP(start, end, t). Linear interpolation between two values. Returns a value between *start* and *end* based on parameter *t* (0.0 to 1.0).
- Added EULER, which returns raw coded value of e (EULER) 2.718281828459045
- Added VSYNC(TRUE/FALSE). VSync limits frame rate to display refresh rate (typically 60 FPS) but prevents screen tearing. Disabling VSync allows unlimited frame rate but may cause visual artifacts.
- Added DISTANCE(x1, y1, x2, y2) or DISTANCE(x1, y1, z1, x2, y2, z2) which returns distance of 2D or 3D coordinates
- Added CLAMP(n, min, max). If the given parameter *n* falls below or exceeds the given limit values ​​*min* or *max*, it is returned within the limits

```vb
LET brightness$ = CLAMP(value$, 20, 255)
' Replaces lines
' IF brightness$ < 20 THEN brightness$ = 20
' IF brightness$ > 255 THEN brightness$ = 255
```

### 11th Feb. 2026

- Added TAU, which returns raw coded value of PI * 2
- Added QPI, which returns raw coded value of PI / 4
- Added BETWEEN(value, min, max) which returns TRUE if value is between min and max.

### 8th Feb 2026

Version 0.8 released as binary

### 8th Feb. 2026

- Succesfully changed audio from NAudio to SDL2_mixer.

#### Fast Trigonometry (Lookup Tables)

For graphics-intensive applications (games, raycasting, animations), BazzBasic provides fast trigonometric functions using pre-calculated lookup tables. These are significantly faster than standard `SIN`/`COS` functions but have 1-degree precision.

**Performance:** ~20x faster than `SIN(RAD(x))` for integer degree values.

**Memory:** Uses ~5.6 KB when enabled (360 values � 2 tables � 8 bytes).


##### FastTrig(enable)
Enables or disables fast trigonometry lookup tables.

**Parameters:**
- `TRUE` (or any non-zero value) - Creates lookup tables
- `FALSE` (or 0) - Destroys lookup tables and frees memory

**Important:** Must call `FastTrig(TRUE)` before using `FastSin`, `FastCos`, or `FastRad`.

```vb
' Enable at program start
FastTrig(TRUE)

' Use fast trig functions...
LET x$ = FastCos(45)
LET y$ = FastSin(45)

' Disable at program end to free memory
FastTrig(FALSE)
```


##### FastSin(angle)
Returns the sine of an angle (in degrees) using a lookup table.

**Parameters:**
- `angle` - Angle in degrees (automatically normalized to 0-359)

**Returns:** Sine value (-1.0 to 1.0)

**Precision:** 1 degree (sufficient for most games and graphics)

```vb
FastTrig(TRUE)

PRINT FastSin(0)    ' Output: 0
PRINT FastSin(90)   ' Output: 1
PRINT FastSin(180)  ' Output: 0
PRINT FastSin(270)  ' Output: -1

' Angles are automatically wrapped
PRINT FastSin(450)  ' Same as FastSin(90) = 1
PRINT FastSin(-90)  ' Same as FastSin(270) = -1

FastTrig(FALSE)
```


##### FastCos(angle)
Returns the cosine of an angle (in degrees) using a lookup table.

**Parameters:**
- `angle` - Angle in degrees (automatically normalized to 0-359)

**Returns:** Cosine value (-1.0 to 1.0)

**Precision:** 1 degree (sufficient for most games and graphics)

```vb
FastTrig(TRUE)

PRINT FastCos(0)    ' Output: 1
PRINT FastCos(90)   ' Output: 0
PRINT FastCos(180)  ' Output: -1
PRINT FastCos(270)  ' Output: 0

' Use in raycasting
FOR angle$ = 0 TO 359
    LET dx$ = FastCos(angle$)
    LET dy$ = FastSin(angle$)
    ' Cast ray in direction (dx, dy)
NEXT

FastTrig(FALSE)
```


##### FastRad(angle)
Converts degrees to radians using an optimized formula.

**Parameters:**
- `angle` - Angle in degrees (automatically normalized to 0-359)

**Returns:** Angle in radians

**Note:** This function doesn't require `FastTrig(TRUE)` but is included for consistency.

```vb
PRINT FastRad(90)   ' Output: 1.5707963267948966 (HPI)
PRINT FastRad(180)  ' Output: 3.141592653589793 (PI)
PRINT FastRad(360)  ' Output: 6.283185307179586 (2*PI)
```


##### Fast Trig Example: Raycasting

```vb
REM Fast raycasting demo
SCREEN 12

' Enable fast trigonometry
FastTrig(TRUE)

LET player_angle$ = 0
LET num_rays# = 320

[mainloop]
    ' Update player rotation
    LET player_angle$ = player_angle$ + 1
    IF player_angle$ >= 360 THEN player_angle$ = 0
    
    ' Cast all rays
    FOR ray$ = 0 TO num_rays# - 1
        LET ray_angle$ = player_angle$ + ray$
        
        ' Fast lookup instead of SIN(RAD(angle))
        LET dx$ = FastCos(ray_angle$)
        LET dy$ = FastSin(ray_angle$)
        
        ' Raycast logic here...
        ' (20x faster than using SIN/COS!)
    NEXT
    
    IF INKEY = KEY_ESC# THEN GOTO [cleanup]
    GOTO [mainloop]

[cleanup]
' Free memory
FastTrig(FALSE)
END
```


##### When to Use Fast Trig

**Use FastTrig when:**
- Rendering graphics at high frame rates (60+ FPS)
- Raycasting or ray tracing
- Rotating sprites or shapes
- Particle systems with many particles
- Any loop that calls `SIN`/`COS` hundreds of times per frame

**Use regular SIN/COS when:**
- Math calculations requiring high precision
- One-time calculations
- Angles are not in integer degrees
- Memory is extremely limited

### 7th Feb. 2026

- Added keyword **HPI** which returns raw coded 1,5707963267929895
- Added keyword **PI** which returns 3.14159265358979  
- Added keywords **RAD** & **DEG**
  
**PI** and **HPI** are raw coded values, so no math involved. Should make performance much better.

```vb
REM Test RAD and DEG functions
PRINT "Testing RAD() and DEG() functions"
PRINT

REM Test degrees to radians
PRINT "90 degrees = "; RAD(90); " radians"
PRINT "180 degrees = "; RAD(180); " radians"
PRINT "360 degrees = "; RAD(360); " radians"
PRINT

REM Test radians to degrees  
PRINT "PI radians = "; DEG(PI); " degrees"
PRINT "PI/2 radians = "; DEG(PI/2); " degrees"
PRINT

REM Test with trigonometry
PRINT "SIN(RAD(90)) = "; SIN(RAD(90))
PRINT "COS(RAD(180)) = "; COS(RAD(180))
PRINT

END
```

```batch
Testing RAD() and DEG() functions

90 degrees = 1.5707963267948966 radians
180 degrees = 3.141592653589793 radians
360 degrees = 6.283185307179586 radians

PI radians = 179.99999999999983 degrees
PI/2 radians = 89.99999999999991 degrees

SIN(RAD(90)) = 1
COS(RAD(180)) = -1
````

### 1st Feb 2026

The documentation has been worked on and is now a bit better than good.

BazzBasic supports creating libraries: bazzbasic.exe -lib file.bas

LINE INPUT is now in the list of supported commands

Version 0.7 released to this date

## Jan 2026

### 18th Jan 2026
With all the previous add-ons, BazzBasic ver. 0.6 is now available as binary and source.


### 18th Jan 2026
Merging BazzBasic and basic code into a single executable file is now possible.

_bazzbasic.exe -exe filename.bas_ produces the _filename.exe_ file.

BazzBasic does not compile the BASIC code, but rather includes it as part of itself.

Read more https://ekbass.github.io/BazzBasic/manual/#/packaging



### 18th Jan 2026
Finished working with PNG and Alpha-color supports.  
LOCATE in graphical screen now overdraws old text instead of just writing new top of it.  

**Supported Formats**

**Format:** PNG  
Transparency: Full alpha (0-255)  
Recomended  

**Format**: BMP  
Transparency: None  
Legacy support

---

### 18th Jan 2026
Generated a manual with Docify.   
BazzBasic homepage now links to it.

Major idea is, that github wiki becomes a as development wiki and this docify as user wiki.

---

### 17th Jan 26
Fixed a bug that prevented to use custom resolution with SCREEN 0  
Terminal now closes if no errors when running via IDE  
Small gap between IDE line numbers and user code.

---

### 17th Jan 26
BazzBasic has now in-built simple IDE.  
Start _bazzbasic.exe_ with out params to open it.  
If opened with params, the .bas file is interpreted normally.  
After few new features, released as version 0.6

---

### 10th Jan 26
Generated __vsix__ file to add BazzBasic syntaxes for VS Code.  
See https://github.com/EkBass/BazzBasic/blob/main/extras/readme.md

---

### 9th Jan 26
Released first one, version 0.5
