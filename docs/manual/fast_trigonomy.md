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
FastTrig(TRUE)

LET x$ = FastCos(45)
LET y$ = FastSin(45)

FastTrig(FALSE)
```

### FastSin(angle)
Returns the sine of an angle (in degrees) using a lookup table.
Angle is automatically normalized to 0-359. Precision: 1 degree.

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
Angle is automatically normalized to 0-359. Precision: 1 degree.

```vb
FastTrig(TRUE)

PRINT FastCos(0)    ' Output: 1
PRINT FastCos(90)   ' Output: 0
PRINT FastCos(180)  ' Output: -1
PRINT FastCos(270)  ' Output: 0

FOR angle$ = 0 TO 359
    LET dx$ = FastCos(angle$)
    LET dy$ = FastSin(angle$)
    ' Cast ray in direction (dx, dy)
NEXT

FastTrig(FALSE)
```

### FastRad(angle)
Converts degrees to radians using an optimized formula.
Angle is automatically normalized to 0-359 **before** conversion — so a full turn (360) wraps to 0.

**Note:** Does not require `FastTrig(TRUE)`. Unlike `FastSin`/`FastCos`, this function never checks whether fast trig tables are enabled — it works standalone.

**Not the same as `RAD(angle)`:** `RAD()` does not normalize and converts the raw angle as given (`RAD(360)` = 6.283185307179586, i.e. 2×PI). `FastRad()` always normalizes first, so `FastRad(360)` = `FastRad(0)` = 0. Pick `RAD()` if you need the literal, un-wrapped radian value.

```vb
PRINT FastRad(90)   ' Output: 1.5707963267948966 (HPI)
PRINT FastRad(180)  ' Output: 3.141592653589793 (PI)
PRINT FastRad(360)  ' Output: 0 (wraps to angle 0, NOT 2*PI)
PRINT FastRad(450)  ' Output: 1.5707963267948966 (same as FastRad(90))
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
