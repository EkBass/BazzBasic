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

### ATAN2(n, n2)
Returns the angle, in radians, between the positive x-axis and a vector to the point with the given (x, y) coordinates in the Cartesian plane.
```vb
PRINT ATAN2(5, 10) ' 0.4636476090008061
```

### BETWEEN(n, min, max)
Returns true if *n* is equal or between *min* and *max*
```vb
BETWEEN(1, 1, 10) ' true
BETWEEN(2, 1, 10) ' true
INBETWEEN(1, 1, 10) ' false
INBETWEEN(2, 1, 10) ' true
```

Unlike INBETWEEN which returns true if *n* is not equal and between *min* and *max*, BETWEEN returns true if *n* is equal and between *min* and *max*

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
If the given parameter *n* falls below or exceeds the given limit values *min* or *max*, it is returned within the limits
```vb
LET brightness$ = CLAMP(value$, 20, 255)
' Replaces lines
' IF brightness$ < 20 THEN brightness$ = 20
' IF brightness$ > 255 THEN brightness$ = 255
```

### DEG(radians)
Converts radians to degrees.
```vb
PRINT DEG(PI#)       ' Output: 180
PRINT DEG(HPI#)      ' Output: 90
PRINT DEG(2 * PI#)   ' Output: 360

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

### EULER#
Returns the Euler's constant, *2.718281828459045*
```vb
PRINT EULER# ' Output: 2.718281828459045
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

### HPI#
Returns half of π (pi/2) ≈ 1.5707963267948966. Equivalent to 90 degrees in radians.

Useful in graphics and game programming where 90-degree angles are common.
```vb
PRINT HPI#                   ' Output: 1.5707963267948966
PRINT DEG(HPI#)              ' Output: 90

' Common angles in radians using built-in constants
LET angle_0$ = 0            ' 0 degrees
LET angle_45$ = QPI#         ' 45 degrees
LET angle_90$ = HPI#         ' 90 degrees
LET angle_180$ = PI#         ' 180 degrees
LET angle_270$ = PI# + HPI#   ' 270 degrees
LET angle_360$ = TAU#        ' 360 degrees
```

### INBETWEEN(n, min, max)
Returns true, if *n* is between *min* and *max* and not equal to them

```vb
INBETWEEN(1, 1, 10) ' false
INBETWEEN(2, 1, 10) ' true
BETWEEN(1, 1, 10) ' true
BETWEEN(2, 1, 10) ' true
```

Unlike BETWEEN which returns true if *n* is equal or between *min* and *max*, INBETWEEN returns true if *n* is not equal and between *min* and *max*

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

PRINT LERP(10, 20, 0.25)   ' Output: 12.5
PRINT LERP(10, 20, 0.75)   ' Output: 17.5
```

**Practical examples:**

Distance-based brightness (raycasting):
```vb
LET maxDist# = 10
LET t$ = CLAMP(distance$ / maxDist#, 0, 1)
LET brightness$ = LERP(255, 20, t$)  ' Bright nearby, dark far away
```

Smooth camera movement:
```vb
LET t$ = 0.1  ' 10% closer each frame
cameraX$ = LERP(cameraX$, targetX$, t$)
cameraY$ = LERP(cameraY$, targetY$, t$)
```

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

### PI#
Returns the mathematical constant π (pi) ≈ 3.14159265358979.
```vb
PRINT PI#                    ' Output: 3.14159265358979
LET circumference$ = 2 * PI# * radius$
LET area$ = PI# * radius$ * radius$
```

### POW(n, n)
Return a number raised to the power of another number
```vb
PRINT POW(3, 3)    	' Output: 27
PRINT POW(2, 2)		' Output: 4
```

### QPI#
Returns a quarter of π (pi/4) ≈ 0.7853981633974475. Equivalent to 45 degrees in radians.
```vb
PRINT QPI#                   ' Output: 0.7853981633974475
PRINT DEG(QPI#)              ' Output: 45

LET dx$ = COS(QPI#)          ' ~0.707
LET dy$ = SIN(QPI#)          ' ~0.707
```

### RAD(degrees)
Converts degrees to radians.
```vb
PRINT RAD(90)       ' Output: 1.5707963267948966 (HPI#)
PRINT RAD(180)      ' Output: 3.141592653589793 (PI#)
PRINT RAD(360)      ' Output: 6.283185307179586 (TAU#)

PRINT SIN(RAD(90))  ' Output: 1
PRINT COS(RAD(180)) ' Output: -1
```

### RND(n)
Returns a random integer from 0 to n-1 or a floating point between 0 and 1.
```vb
PRINT RND(10)      	' Output: 0-9
PRINT RND(100)		' Output: 0-99
RND(0)			' Float between 0.0 and 1.0 (IE: 0.5841907423666761)
' Dice roll
LET dice$ = RND(6) + 1
```

### ROUND(n)
Rounds a number according to standard rules
```vb
PRINT ROUND(1.1)    ' Output: 1
PRINT ROUND(1.5)	' Output: 2
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
PRINT SQR(5)      ' Output: 2.23606797749979
PRINT SQR(9)      ' Output: 3
```

### TAN(n)
Returns the tangent of the given angle
```vb
PRINT TAN(0)      ' Output: 0
PRINT TAN(5)      ' Output: -3.380515006246586
PRINT TAN(9)      ' Output: -0.45231565944180985
```

### TAU#
Returns τ (tau) = 2π ≈ 6.28318530717958. Equivalent to 360 degrees in radians (a full circle).
```vb
PRINT TAU#                   ' Output: 6.28318530717958

' Full circle loop
FOR angle$ = 0 TO 359
    LET rad$ = (angle$ / 360) * TAU#
    LET x$ = COS(rad$) * radius$
    LET y$ = SIN(rad$) * radius$
NEXT

' All BazzBasic circle constants:
' QPI#  = π/4  = 45°
' HPI#  = π/2  = 90°
' PI#   = π    = 180°
' TAU#  = 2π   = 360°
```
