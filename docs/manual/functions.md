## Math Functions

### ABS(n)
Returns the absolute value of *n*.
```vb
PRINT ABS(1.5)	' 1.5
PRINT ABS(-1.5)	' 1.5
```

### ATAN(n)
Returns the arc tangent of a *n*
```vb
PRINT ATAN(1.5)	' 0.982793723247329
PRINT ATAN(-1.5)	' -0.982793723247329
```

### BETWEEN(n, min, max)
Returns true, if *n* is between *min* and *max*.
```vb
IF BETWEEN(5, 1, 10) = TRUE THEN
    PRINT "5 is between 1 and 10"
END IF
' Output: 5 is between 1 and 10
```

### CINT(n)
The Cint function converts an expression to type Integer.
```vb
PRINT CINT(3.7)      ' Output: 4
PRINT CINT(3.3)		' Output: 3
PRINT CINT(-3.7)     ' Output: -4
```

### CEIL(n)
Returns the smallest integer that is greater than or equal to a given number
```vb
PRINT CEIL(3.7)      ' Output: 4
PRINT CEIL(3.3)		' Output: 4
PRINT CEIL(-3.7)     ' Output: -3
```

### COS(n)
Returns the cosine of an angle
```vb
PRINT COS(0)    ' Output: 1
PRINT COS(45)	' Output 0.5253219888177297
PRINT COS(90)   ' Output: -0.4480736161291701
```

### CLAMP(n, min, max)
If the given parameter *n* falls below or exceeds the given limit values ​​*min* or *max*, it is returned within the limits
```vb
LET brightness$ = CLAMP(value$, 20, 255)
' Replaces lines
' IF brightness$ < 20 THEN brightness$ = 20
' IF brightness$ > 255 THEN brightness$ = 255
```

### DEG(radians)
Converts radians to degrees.
```vb
PRINT DEG(PI)       ' Output: 180
PRINT DEG(HPI)      ' Output: 90
PRINT DEG(2 * PI)   ' Output: 360

' Convert result back to degrees
LET angle_rad$ = 1.5707963267948966
PRINT DEG(angle_rad$)  ' Output: 90
```
### DISTANCE(x1, y1, x2, y2) or DISTANCE(x1, y1, z1, x2, y2, z2)
Returns the Euclidean distance between two points. Supports both 2D and 3D.

**2D mode** (4 parameters):
```vb
PRINT DISTANCE(0, 0, 3, 4)        ' Output: 5 (3-4-5 triangle)
PRINT DISTANCE(10, 20, 40, 60)    ' Output: 50
```

**3D mode** (6 parameters):
```vb
PRINT DISTANCE(0, 0, 0, 1, 1, 1)  ' Output: 1.732... (sqrt of 3)
PRINT DISTANCE(0, 0, 0, 0, 0, 5)  ' Output: 5
```

**Practical example:**
```vb
LET playerX$ = 100, playerY$ = 200
LET enemyX$ = 250, enemyY$ = 350
LET dist$ = DISTANCE(playerX$, playerY$, enemyX$, enemyY$)

IF dist$ < 50 THEN
    PRINT "Enemy is close!"
END IF
```

### EULER
Returns the Euler's constant, *2.718281828459045*
```vb
PRINT EULER ' Output: 2.718281828459045
```

### EXP(n)
Exponential (e^n).
```vb
PRINT EXP(1)        ' Output: 2.718...
PRINT EXP(0)        ' Output: 1
```

### FLOOR(n)
Rounds down and returns the largest integer
```vb
PRINT FLOOR(1.1)      ' Output: 1
PRINT FLOOR(1.95)       ' Output: 1
PRINT FLOOR(300)       ' Output: 300
```

### HPI
Returns half of π (pi/2) ≈ 1.5707963267948966. Equivalent to 90 degrees in radians.

Useful in graphics and game programming where 90-degree angles are common.
```vb
PRINT HPI                   ' Output: 1.5707963267948966
PRINT DEG(HPI)              ' Output: 90

' Common angles in radians using built-in constants
LET angle_0$ = 0            ' 0 degrees
LET angle_45$ = QPI         ' 45 degrees
LET angle_90$ = HPI         ' 90 degrees
LET angle_180$ = PI         ' 180 degrees
LET angle_270$ = PI + HPI   ' 270 degrees
LET angle_360$ = TAU        ' 360 degrees
```

### INT(n)
Returns the integer part (truncates toward zero).
```vb
PRINT INT(3.7)     ' Output: 3
PRINT INT(-3.7)    ' Output: -3
```


### LERP(start, end, t)
Linear interpolation between two values. Returns a value between *start* and *end* based on parameter *t* (0.0 to 1.0).

**Parameters:**
- `start` - Starting value (when t = 0)
- `end` - Ending value (when t = 1)  
- `t` - Interpolation factor (0.0 to 1.0)
  - `t = 0.0` returns *start*
  - `t = 0.5` returns halfway between
  - `t = 1.0` returns *end*

**Formula:** `result = start + (end - start) × t`

**Basic examples:**
```vb
PRINT LERP(0, 100, 0)      ' Output: 0   (0% of the way)
PRINT LERP(0, 100, 0.5)    ' Output: 50  (50% of the way)
PRINT LERP(0, 100, 1)      ' Output: 100 (100% of the way)

PRINT LERP(10, 20, 0.25)   ' Output: 12.5 (25% between 10 and 20)
PRINT LERP(10, 20, 0.75)   ' Output: 17.5 (75% between 10 and 20)
```

**Practical examples:**

**Distance-based brightness (raycasting):**
```vb
REM Calculate wall brightness based on distance
LET maxDist# = 10
LET t$ = CLAMP(distance$ / maxDist#, 0, 1)
LET brightness$ = LERP(255, 20, t$)  ' Bright (255) nearby, dark (20) far away
```

**Color gradients:**
```vb
REM Fade from red to blue based on health
LET t$ = health$ / maxHealth$
LET red$ = LERP(255, 0, t$)    ' Full red at low health
LET blue$ = LERP(0, 255, t$)   ' Full blue at full health  
LET color$ = RGB(red$, 0, blue$)
```

**Smooth camera movement:**
```vb
REM Smoothly move camera toward target
LET t$ = 0.1  ' 10% closer each frame
cameraX$ = LERP(cameraX$, targetX$, t$)
cameraY$ = LERP(cameraY$, targetY$, t$)
```

**Animation timing:**
```vb
REM Animate sprite position over time
LET duration# = 2000  ' 2 seconds
LET elapsed$ = TICKS - startTime$
LET t$ = CLAMP(elapsed$ / duration#, 0, 1)

LET spriteX$ = LERP(startX$, endX$, t$)
LET spriteY$ = LERP(startY$, endY$, t$)
```

**Why use LERP?**
- **Clearer intent:** `LERP(0, 100, 0.5)` is more readable than `0 + (100 - 0) * 0.5`
- **Easier to adjust:** Change endpoints without recalculating formulas
- **Common in game development:** Standard function in Unity, Unreal, etc.
- **Versatile:** Works for positions, colors, volumes, speeds, and more


### LOG(n)
Natural logarithm (base e).
```vb
PRINT LOG(2.718)    ' Output: 0.999896315728952
```


### MAX(n, n)
Return higher one from two numbers
```vb
LET A# = 1
LET A$ = 9.8
PRINT MAX(A#, A$)    ' Output: 9.8
```


### MIN(n, n)
Return smaller one from two numbers
```vb
LET A# = 1
LET A$ = 9.8
PRINT MIN(A#, A$)    ' Output: 1
```


### MOD(n, n)
Return modulus (remainder) of the two numbers
```vb
PRINT MOD(10, 3)    ' Output: 1
PRINT MOD(100, 20)	' Output: 0
```

### POW(n, n)
Return a number raised to the power of another number
```vb
PRINT POW(3, 3)    	' Output: 27
PRINT POW(2, 2)		' Output: 4
```

### PI
Returns the mathematical constant π (pi) ≈ 3.14159265358979.
```vb
PRINT PI                    ' Output: 3.14159265358979
LET circumference$ = 2 * PI * radius$
LET area$ = PI * radius$ * radius$
```

### QPI
Returns a quarter of π (pi/4) ≈ 0.7853981633974475. Equivalent to 45 degrees in radians.

Useful in graphics programming for diagonal movement and isometric calculations.
```vb
PRINT QPI                   ' Output: 0.7853981633974475
PRINT DEG(QPI)              ' Output: 45

' Common use: diagonal directions
LET dx$ = COS(QPI)          ' ~0.707 (equal X and Y component)
LET dy$ = SIN(QPI)          ' ~0.707
```

### RAD(degrees)
Converts degrees to radians.
```vb
PRINT RAD(90)       ' Output: 1.5707963267948966 (HPI)
PRINT RAD(180)      ' Output: 3.141592653589793 (PI)
PRINT RAD(360)      ' Output: 6.283185307179586 (2*PI)

' Use with trigonometric functions
PRINT SIN(RAD(90))  ' Output: 1 (sine of 90 degrees)
PRINT COS(RAD(180)) ' Output: -1 (cosine of 180 degrees)
```

### RND(n)
Returns a random integer from 0 to n-1.
```vb
PRINT RND(10)      ' Output: 0-9
PRINT RND(100)     ' Output: 0-99

' Random number between 1 and 6 (dice roll)
LET dice$ = RND(6) + 1
```

### ROUND(n)
Rounds a number according to standard rules
```vb
PRINT ROUND(1.1)    ' Output: 1
PRINT ROUND(1.5)	   ' Output: 2
PRINT ROUND(1.9)    ' Output: 2
```

### SGN(n)
Returns the sign: -1, 0, or 1.
```vb
PRINT SGN(-5)      ' Output: -1
PRINT SGN(0)       ' Output: 0
PRINT SGN(5)       ' Output: 1
```

### SIN(n)
Returns the sine of a number
```vb
PRINT SIN(-5)      ' Output: 0.9589242746631385
PRINT SIN(0)       ' Output: 0
PRINT SIN(5)       ' Output: -0.9589242746631385
```

### SQR(n)
Returns the square root.
```vb
PRINT SQR(0)      ' Output: 0
PRINT SQR(5)       ' Output: 2.23606797749979
PRINT SQR(9)       ' Output: 3
```

### TAN(n)
Returns the tangent of the given angle
```vb
PRINT TAN(0)      ' Output: 0
PRINT TAN(5)       ' Output: -3.380515006246586
PRINT TAN(9)       ' Output: -0.45231565944180985
```

### TAU
Returns τ (tau) = 2π ≈ 6.28318530717958. Equivalent to 360 degrees in radians (a full circle).

Simplifies expressions that would otherwise use `2 * PI`.
```vb
PRINT TAU                   ' Output: 6.28318530717958

' Full circle loop
FOR angle$ = 0 TO 359
    LET rad$ = (angle$ / 360) * TAU
    LET x$ = COS(rad$) * radius$
    LET y$ = SIN(rad$) * radius$
NEXT

' All BazzBasic circle constants:
' QPI  = π/4  = 45°
' HPI  = π/2  = 90°
' PI   = π    = 180°
' TAU  = 2π   = 360°
```

## Fast Trigonometry (Lookup Tables)
For graphics-intensive applications (games, raycasting, animations), BazzBasic provides fast trigonometric functions using pre-calculated lookup tables. These are significantly faster than standard `SIN`/`COS` functions but have 1-degree precision.

**Performance:** ~20x faster than `SIN(RAD(x))` for integer degree values.

**Memory:** Uses ~5.6 KB when enabled (360 values × 2 tables × 8 bytes).


### FastTrig(enable)
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

### FastSin(angle)
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

### FastCos(angle)
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

### FastRad(angle)
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

### Fast Trig Example: Raycasting
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

### When to Use Fast Trig
**Use FastTrig when:**
- Rendering graphics at high frame rates (60+ FPS)
- Raycasting or ray tracing
- Rotating sprites or shapes
- Particle systems with many particles
- Any loop that calls `SIN`/`COS` hundreds of times per frame

**Use regular SIN/COS when:**
- Scientific calculations requiring high precision
- One-time calculations
- Angles are not in integer degrees
- Memory is extremely limited


## String Functions

### ASC(s$)
Returns ASCII code of first character.
```vb
PRINT ASC("A")      ' Output: 65
PRINT ASC("Hello")  ' Output: 72 (H)
```

### CHR(n)
Returns character for ASCII code.
```vb
PRINT CHR(65)      ' Output: A
PRINT CHR(10)      ' Output: (newline)
```

### INSTR(s$, search$) or INSTR(start, s$, search$)
Finds position of substring (1-based, 0 if not found).
```vb
PRINT INSTR("Hello World", "World")    ' Output: 7
PRINT INSTR("Hello World", "xyz")      ' Output: 0
PRINT INSTR(8, "Hello World", "o")     ' Output: 8
```

### INVERT(s$)
Inverts a string
```vb
PRINT INVERT("Hello World")      ' Output: dlroW olleH
```

### LCASE(s$)
Converts to lowercase.
```vb
PRINT LCASE("Hello")  ' Output: hello
```

### LEFT(s$, n)
Returns first n characters.
```vb
PRINT LEFT("Hello World", 5)  ' Output: Hello
```

### LEN(s$)
Returns string length.
```vb
PRINT LEN("Hello")  ' Output: 5
PRINT LEN("")       ' Output: 0
```

### LTRIM(s$)
Removes blank characters from the left of the text
```vb
PRINT LTRIM("        Hello World") ' Output: Hello World
```

### MID(s$, start) or MID(s$, start, length)
Returns substring starting at position (1-based).
```vb
PRINT MID("Hello World", 7)     ' Output: World
PRINT MID("Hello World", 7, 3)  ' Output: Wor
PRINT MID("Hello World", 1, 5)  ' Output: Hello
```

### REPEAT(s$, n)
Repeats the text requested times
```vb
LET a$ = REPEAT("Foo", 10)
PRINT a$ ' Output: FooFooFooFooFooFooFooFooFooFoo
```

### REPLACE(s$,a$, b$)
Replaces a$ with b$ from s$
```vb
LET text$ = "Hello World"
LET result$ = REPLACE(text$, "World", "BazzBasic")
PRINT result$  ' "Hello BazzBasic"
```

### RIGHT(s$, n)
Returns last n characters.
```vb
PRINT RIGHT("Hello World", 5) ' Output: World
```

### RTRIM(s$)
Removes blank characters from the right of the text
```vb
LET a$ = "Foo     "
LET b$ = "Bar"
a$ = RTRIM(a$)
PRINT a$ + b$ ' Output: FooBar
```

### SPLIT(s$, a$, b$)
Splits string in to array according seperator
```vb
DIM parts$
REM Split with ","
LET count$ = SPLIT(parts$, "apple,banana,orange", ",")
PRINT "Parts: "; count$
PRINT parts$(0)  ' "apple"
PRINT parts$(1)  ' "banana"
PRINT parts$(2)  ' "orange"
```

### SRAND(n)
Returns random string lenght of *n* from allowed chars.  
**Allowed chars:**  *ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456780_*
```vb
PRINT SRAND(10)  ' Output example: noAR1S-Qw1
```

### STR(n)
Converts number to string.
```vb
LET s$ = STR(42)
PRINT "Value: " + s$  ' Output: Value: 42
```

### TRIM(s$)
Removes blank characters from start and end of text
```vb
LET a$ = "    Foo     "
LET b$ = "    Bar     "
a$ = TRIM(a$)
b$ = TRIM(b$)
PRINT a$ + b$ ' Output: FooBar
```

### UCASE(s$)
Converts to uppercase.
```vb
PRINT UCASE("Hello")  ' Output: HELLO
```

### VAL(s$)
Converts string to number.
```vb
LET n$ = VAL("42")
PRINT n$ + 8        ' Output: 50
```

## Array Functions

### LEN(array$())
Returns number of elements in array.
```vb
DIM items$
items$(0) = "a"
items$(1) = "b"
items$(2) = "c"
PRINT LEN(items$())  ' Output: 3
```

### HASKEY(array$(key))
Returns 1 if key exists, 0 otherwise.
```vb
DIM data$
data$("name") = "Alice"

PRINT HASKEY(data$("name"))   ' Output: 1
PRINT HASKEY(data$("age"))    ' Output: 0
```

### DELKEY - Remove Element
Removes an element from the array:
```vb
DIM cache$
cache$("temp") = "value"
PRINT HASKEY(cache$("temp"))  ' Output: 1

DELKEY cache$("temp")
PRINT HASKEY(cache$("temp"))  ' Output: 0
```

### DELARRAY - Remove Entire Array
Removes the entire array and all its elements:
```vb
DIM arr$
arr$("name") = "Test"
arr$(0) = "Zero"

PRINT LEN(arr$())             ' Output: 2

DELARRAY arr$

' Array no longer exists, can be re-declared
DIM arr$
PRINT LEN(arr$())             ' Output: 0
```

## Input Functions

### INKEY
Returns current key press (non-blocking). Returns 0 if no key pressed.
```vb
[loop]
    LET k$ = INKEY
    IF k$ = 0 THEN GOTO [loop]
    IF k$ = KEY_ESC# THEN END
    PRINT "Key code: "; k$
    GOTO [loop]
```

Special keys return values > 256:
- Arrow keys: KEY_UP#, KEY_DOWN#, KEY_LEFT#, KEY_RIGHT#
- Function keys: KEY_F1# through KEY_F12#

### KEYDOWN
Read key states via key constants  
**Note:** KEYDOWN availale only when graphics screen used. Not via console
```vb
REM KEYDOWN Test
SCREEN 12

LET x$ = 320
LET y$ = 240

WHILE INKEY <> KEY_ESC#
    SCREENLOCK ON
    LINE (0,0)-(640,480), 0, BF
    
    IF KEYDOWN(KEY_W#) THEN y$ = y$ - 2
    IF KEYDOWN(KEY_S#) THEN y$ = y$ + 2
    IF KEYDOWN(KEY_A#) THEN x$ = x$ - 2
    IF KEYDOWN(KEY_D#) THEN x$ = x$ + 2
    
    IF KEYDOWN(KEY_LSHIFT#) THEN
        CIRCLE (x$, y$), 20, RGB(255, 0, 0), 1
    ELSE
        CIRCLE (x$, y$), 10, RGB(0, 255, 0), 1
    END IF
    
    LOCATE 1, 1
    COLOR 15, 0
    PRINT "WASD=Move  SHIFT=Big  ESC=Quit"
    LOCATE 2, 1
    PRINT "X:"; x$; " Y:"; y$; "   "
    
    SCREENLOCK OFF
    SLEEP 16
WEND
END
```

### MOUSEX, MOUSEY
**Note: Only available when graphics screen is open.**

Returns mouse cursor position.
```vb
SCREEN 12
[loop]
    LOCATE 1, 1
    PRINT "X:"; MOUSEX; " Y:"; MOUSEY; "   "
    GOTO [loop]
```

### MOUSEB
**Note: Only available when graphics screen is open.**

Returns mouse button state (bitmask).
```vb
' MOUSE_LEFT# = 1, MOUSE_RIGHT# = 2, MOUSE_MIDDLE# = 4
LET buttons$ = MOUSEB
IF buttons$ AND MOUSE_LEFT# THEN PRINT "Left clicked"
IF buttons$ AND MOUSE_RIGHT# THEN PRINT "Right clicked"
```

## Color Functions

### RGB(r, g, b)
Creates a color value from red, green, and blue components.

**Parameters:**
- `r` - Red component (0-255)
- `g` - Green component (0-255)
- `b` - Blue component (0-255)

**Returns:** A combined color value for use with graphics commands.

```vb
LET red$ = RGB(255, 0, 0)
LET green$ = RGB(0, 255, 0)
LET blue$ = RGB(0, 0, 255)
LET white$ = RGB(255, 255, 255)
LET black$ = RGB(0, 0, 0)
LET purple$ = RGB(128, 0, 128)

' Use with graphics commands
PSET 100, 100, RGB(255, 128, 0)   ' Orange pixel
LINE (0, 0)-(100, 100), RGB(0, 255, 0)  ' Green line
CIRCLE 200, 200, 50, RGB(255, 0, 0)     ' Red circle
```
**Tip:** Store frequently used colors in constants for better performance:

```vb
LET COLOR_PLAYER# = RGB(0, 128, 255)
LET COLOR_ENEMY# = RGB(255, 64, 64)
LET COLOR_BACKGROUND# = RGB(32, 32, 48)
```

## Logical Values

### TRUE, FALSE
Boolean constants.
```vb
LET gameOver$ = FALSE

WHILE NOT gameOver$
    ' game loop
    IF lives$ = 0 THEN gameOver$ = TRUE
WEND
```

## Time Functions

### TIME(format$)
Returns current date/time as a formatted string. Uses .NET DateTime format strings.
```vb
PRINT TIME()                ' Default: "16:30:45"
PRINT TIME("HH:mm:ss")      ' "16:30:45"
PRINT TIME("dd.MM.yyyy")    ' "09.01.2026"
PRINT TIME("yyyy-MM-dd")    ' "2026-01-09"
PRINT TIME("dddd")          ' "Friday"
PRINT TIME("MMMM")          ' "January"
PRINT TIME("dd MMMM yyyy")  ' "09 January 2026"
PRINT TIME("HH:mm")         ' "16:30"
```

**Common format codes:**
| Code | Description | Example | 
|------|-------------|--------| 
| HH | Hour (00-23) | 16 | 
| mm | Minutes | 30 | 
| ss | Seconds | 45 | 
| dd | Day | 09 | 
| MM | Month (number) | 01 | 
| MMM | Month (short) | Jan | 
| MMMM | Month (full) | January | 
| yy | Year (2 digits) | 26 | 
| yyyy | Year (4 digits) | 2026 | 
| ddd | Weekday (short) | Fri | 
| dddd | Weekday (full) | Friday | 


### TICKS
Returns milliseconds elapsed since program started. Useful for timing, animations, and game loops.
```vb
LET start$ = TICKS

' Do some work
FOR i$ = 1 TO 10000
    LET x$ = x$ + 1
NEXT

LET elapsed$ = TICKS - start$
PRINT "Time taken: "; elapsed$; " ms"
```

**Game loop timing example:**
```vb
SCREEN 12
LET lastFrame$ = TICKS
LET frameTime# = 16  ' ~60 FPS

[gameloop]
    LET now$ = TICKS
    IF now$ - lastFrame$ >= frameTime# THEN
        ' Update game logic here
        lastFrame$ = now$
    ENDIF
    
    IF INKEY = KEY_ESC# THEN END
    GOTO [gameloop]
```