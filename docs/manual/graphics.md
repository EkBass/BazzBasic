## Screen Control


### SCREEN - Initialize Graphics Mode
Initialize SDL2 graphics window with specified resolution and title.

```vb
SCREEN mode                      ' Standard BASIC mode
SCREEN 0, width, height          ' Custom resolution
SCREEN 0, width, height, "Title" ' Custom resolution with window title
```

### Standard BASIC Modes
| Mode | Resolution | Description |
|------|-----------|-------------|
| 0 | 640×400 | Text emulation mode |
| 1 | 320×200 | Low resolution |
| 2 | 640×350 | Medium resolution |
| 7 | 320×200 | VGA low-res |
| 9 | 640×350 | EGA enhanced |
| 12 | 640×480 | VGA standard (recommended) |
| 13 | 320×200 | MCGA mode |


#### Examples
```vb
SCREEN 12                        ' 640×480 VGA mode
SCREEN 0, 800, 600               ' 800×600 custom size
SCREEN 0, 1024, 768, "My Game"   ' 1024×768 with custom title
```


### CLS
Clear entire screen to background color.  
**Note:** See performance tips for graphics
```vb
CLS                 ' Clear screen
COLOR 0, 1          ' Set blue background
CLS                 ' Clear to blue
```


### LOCATE
Move text cursor to specified row and column (1-based).
```vb
LOCATE row, column

LOCATE 10, 20       ' Row 10, Column 20
PRINT "Centered"

LOCATE 1, 1         ' Top-left corner
PRINT "Header"
```
**Note:** In graphics mode, character positions are based on 8×8 pixel font cells.

### COLOR
Set foreground (text) and background colors.
```vb
COLOR foreground, background

COLOR 14, 1         ' Yellow text on blue background
PRINT "Warning!"

COLOR 15, 0         ' White on black (default)
```

### Color Palette (0-15)

| Value | Color | Value | Color |
|-------|-------|-------|-------|
| 0 | Black | 8 | Dark Gray |
| 1 | Blue | 9 | Light Blue |
| 2 | Green | 10 | Light Green |
| 3 | Cyan | 11 | Light Cyan |
| 4 | Red | 12 | Light Red |
| 5 | Magenta | 13 | Light Magenta |
| 6 | Brown | 14 | Yellow |
| 7 | Light Gray | 15 | White |

### GETCONSOLE
GETCONSOLE(row, col, type) is meant to be used on console only.  
It can be used to read the character, font color or background color in a certain place on the console screen.

GETCONSOLE returns an integer.  
- The color code is restored directly  
- ASCII character is returned as ASC code  

####  Parameters
GETCONSOLE(x, y, z)  
row: row
col: col
type: 0 returns character, 1 foreground color and 2 background color  

```vb
CLS
COLOR 11, 1
PRINT "abcdefghi"
PRINT "ABCDEFGHI"
COLOR 1, 9
PRINT "987654321"
COLOR 15, 0
' Lets use CHR to translate ASCII-code as character
PRINT "Row 2, col 5 char is: " + CHR(GETCONSOLE(2, 5, 0)) ' Output: E
PRINT "Row 1, col 2 foreground color is: "  + GETCONSOLE(1, 2, 1) ' Output: 11
PRINT "Row 1, col 3 background color is:" + GETCONSOLE(1,3,2) ' Output: 1
```

### SCREENLOCK
Control when graphics are displayed to prevent flickering.
```vb
SCREENLOCK ON       ' Lock screen (start buffering)
SCREENLOCK OFF      ' Unlock and display (present buffer)
SCREENLOCK          ' Same as SCREENLOCK ON
```

**Why use SCREENLOCK?**
Without screen locking, each graphics command immediately updates the display, causing visible flickering during animation. SCREENLOCK buffers all drawing commands and displays them at once.

#### Example - Smooth Animation

```vb
SCREEN 12
DIM angle$
LET angle$ = 0

WHILE INKEY <> 27
    SCREENLOCK ON           ' Start buffering
    
    CLS                     ' Clear
    LET angle$ = angle$ + 5
    
    ' Draw multiple shapes
    LINE (100,100)-(200,200), 15
    CIRCLE (320, 240), 50, 12
    
    SCREENLOCK OFF          ' Display all at once
    SLEEP 16                ' ~60 FPS
WEND
```

### VSYNC
Control vertical synchronization (VSync) to limit or maximize frame rate.

```vb
VSYNC(TRUE)         ' Enable VSync (default)
VSYNC(FALSE)        ' Disable VSync
```

**Parameters:**
- `TRUE` or any non-zero value - Enable VSync
- `FALSE` or `0` - Disable VSync

**What is VSync?**

VSync synchronizes frame rendering with your monitor's refresh rate (typically 60Hz = 60 FPS). This prevents screen tearing (horizontal lines during fast motion) but limits maximum frame rate.

**When to use:**
- `VSYNC(TRUE)` - Normal gameplay (smoother, no tearing)
- `VSYNC(FALSE)` - Benchmarking, performance testing, FPS measurement

**Important:**
- VSync is **enabled by default** when you call `SCREEN`
- Call `VSYNC` **after** the `SCREEN` command
- If rendering takes longer than 16.67ms (1/60s), VSync will lock to 30 FPS instead of 60 FPS

#### Performance Impact

```vb
' With VSync enabled (default):
' - FPS capped at monitor refresh rate (usually 60)
' - Smooth rendering, no screen tearing
' - If frame takes > 16.67ms → drops to 30 FPS

' With VSync disabled:
' - Unlimited FPS (can exceed 100+ FPS)
' - May show screen tearing
' - Better for performance benchmarking
```

#### Example - FPS Testing

```vb
SCREEN 12
VSYNC(FALSE)        ' Disable for true FPS measurement

LET frameCount$ = 0
LET lastTime$ = TICKS

WHILE INKEY <> KEY_ESC#
    SCREENLOCK ON
    CLS
    
    ' Your rendering code here
    CIRCLE (320, 240), 50, 12
    
    SCREENLOCK OFF
    
    ' Calculate FPS
    frameCount$ = frameCount$ + 1
    LET currentTime$ = TICKS
    
    IF currentTime$ - lastTime$ >= 1000 THEN
        LET fps$ = frameCount$ / ((currentTime$ - lastTime$) / 1000)
        frameCount$ = 0
        lastTime$ = currentTime$
        
        LOCATE 1, 1
        PRINT "FPS: "; INT(fps$); "  "
    ENDIF
WEND

VSYNC(TRUE)         ' Restore default before exit
END
```

#### Example - Toggle VSync at Runtime

```vb
SCREEN 12
LET vsyncEnabled$ = TRUE
VSYNC(vsyncEnabled$)

WHILE INKEY <> KEY_ESC#
    LET key$ = INKEY
    
    ' Press V to toggle VSync
    IF key$ = ASC("v") OR key$ = ASC("V") THEN
        vsyncEnabled$ = NOT vsyncEnabled$
        VSYNC(vsyncEnabled$)
        
        LOCATE 2, 1
        IF vsyncEnabled$ THEN
            PRINT "VSync: ON  "
        ELSE
            PRINT "VSync: OFF "
        ENDIF
    ENDIF
    
    SCREENLOCK ON
    ' Rendering here
    SCREENLOCK OFF
    SLEEP 1
WEND
END
```

**Troubleshooting:**

If your game runs at 30 FPS instead of 60 FPS with VSync enabled:
1. Your rendering takes > 16.67ms per frame
2. VSync forces wait for next refresh (60 FPS ÷ 2 = 30 FPS)
3. Solutions:
   - Reduce number of rays in raycaster
   - Lower screen resolution
   - Optimize rendering code
   - Use `VSYNC(FALSE)` to test maximum achievable FPS

## Basic Graphics Primitives

### PSET - Draw Pixel
Draw a single pixel at coordinates (x, y).
```vb
PSET (x, y), color

PSET (100, 100), 15     ' White pixel
PSET (320, 240), 12     ' Red pixel at center
```

### LINE - Draw Lines and Boxes
Draw lines or filled/unfilled rectangles.
```vb
LINE (x1, y1)-(x2, y2), color           ' Line
LINE (x1, y1)-(x2, y2), color, B        ' Box (outline)
LINE (x1, y1)-(x2, y2), color, BF       ' Box Filled
```

#### Examples
```vb
LINE (10, 10)-(100, 50), 15             ' White line
LINE (50, 50)-(150, 150), 12, B         ' Red box outline
LINE (200, 100)-(300, 200), 9, BF       ' Blue filled box
```

### CIRCLE - Draw Circle
Draw circle or filled circle at center point.
```vb
CIRCLE (centerX, centerY), radius, color
CIRCLE (centerX, centerY), radius, color, filled

CIRCLE (320, 240), 50, 14               ' Yellow circle outline
CIRCLE (100, 100), 30, 12, 1            ' Red filled circle
```

### PAINT - Fill Area
Fill an enclosed area with color (flood fill).
```vb
PAINT (x, y), fillColor, borderColor

' Draw and fill a box
LINE (100, 100)-(200, 200), 15, B       ' White border
PAINT (150, 150), 12, 15                ' Fill red inside white border
```

### RGB - Create Color Value
Create custom RGB color (0-255 per channel).
```vb
LET color$ = RGB(red, green, blue)

LET purple$ = RGB(128, 0, 128)
PSET (100, 100), purple$

LET orange$ = RGB(255, 165, 0)
CIRCLE (320, 240), 50, orange$
```

### POINT - Read pixel color from screen
Returns a RGP color value from certain point of the screen.
```vb
LET c$ = POINT(100, 100)
```


## Shape System (Sprites)

### LOADSHAPE - Create Shape

Create or load a new shape and return its ID.
```vb
id$ = LOADSHAPE(type$, width, height, color)
```

**Shape types:**
- `"RECTANGLE"` - Rectangle shape
- `"CIRCLE"` - Circle shape  
- `"TRIANGLE"` - Triangle shape

#### Examples

```vb
DIM square$
LET square$ = LOADSHAPE("RECTANGLE", 50, 50, RGB(255, 0, 0))

DIM ball$
LET ball$ = LOADSHAPE("CIRCLE", 40, 40, RGB(0, 255, 0))

DIM arrow$
LET arrow$ = LOADSHAPE("TRIANGLE", 30, 40, RGB(0, 0, 255))
```

### MOVESHAPE - Position Shape

Move shape to absolute screen position.

```vb
MOVESHAPE id$, x, y

MOVESHAPE square$, 320, 240     ' Center of 640×480 screen
MOVESHAPE ball$, 100, 100       ' Top-left area
```

### ROTATESHAPE - Rotate Shape

Rotate shape to specified angle in degrees.

```vb
ROTATESHAPE id$, angle

ROTATESHAPE square$, 45         ' 45 degrees
ROTATESHAPE arrow$, 180         ' Upside down
ROTATESHAPE triangle$, 270      ' 90 degrees counter-clockwise
```

**Note:** Rotation is absolute, not cumulative. To spin continuously:

```vb
DIM angle$
LET angle$ = 0

WHILE 1
    LET angle$ = angle$ + 5
    IF angle$ >= 360 THEN
        LET angle$ = 0
    ENDIF
    ROTATESHAPE square$, angle$
    SLEEP 16
WEND
```

### SCALESHAPE - Scale Shape Size

Scale shape by multiplier (1.0 = original size).

```vb
SCALESHAPE id$, scale

SCALESHAPE ball$, 0.5           ' Half size
SCALESHAPE square$, 2.0         ' Double size
SCALESHAPE triangle$, 1.5       ' 150% size
```

**Pulsing effect:**

```vb
DIM scale$
DIM direction$
LET scale$ = 1
LET direction$ = 0.01

WHILE 1
    LET scale$ = scale$ + direction$
    
    IF scale$ >= 1.5 OR scale$ <= 0.5 THEN
        LET direction$ = direction$ * -1
    ENDIF
    
    SCALESHAPE ball$, scale$
    SLEEP 16
WEND
```

### DRAWSHAPE - Render Shape

Draw shape to screen at current position/rotation/scale.

```vb
DRAWSHAPE id$

SCREENLOCK ON
CLS
DRAWSHAPE square$
DRAWSHAPE ball$
DRAWSHAPE triangle$
SCREENLOCK OFF
```

**Important:** Use with SCREENLOCK for smooth rendering!

### SHOWSHAPE / HIDESHAPE - Toggle Visibility

Show or hide shape without removing it.

```vb
SHOWSHAPE id$
HIDESHAPE id$

HIDESHAPE enemy$                ' Temporarily hide
' ... do something ...
SHOWSHAPE enemy$                ' Show again
```

### REMOVESHAPE - Delete Shape

Permanently remove shape from memory.

```vb
REMOVESHAPE id$

REMOVESHAPE square$             ' Delete and free memory
```

**Note:** Always remove shapes when done to free memory!

### LOADIMAGE
**Note:** Images can be handled just as shapes
```vb
SCREEN 12
DIM sprite$
LET sprite$ = LOADIMAGE("temp.bmp")
' Currently, only .bmp is supported

MOVESHAPE sprite$, 320, 240
ROTATESHAPE sprite$, 45      ' Rotate 45
SCALESHAPE sprite$, 2.0      ' Scale by 2

SCREENLOCK ON
DRAWSHAPE sprite$
SCREENLOCK OFF
SLEEP 3000
REMOVESHAPE sprite$          ' Free mem
END
```

## Mouse Input

### MOUSE CONSTANTS
```vb
MOUSE_LEFT#    ' Value: 1
MOUSE_RIGHT#   ' Value: 2
MOUSE_MIDDLE#  ' Value: 4
```

### MOUSEX / MOUSEY - Mouse Position

Get current mouse coordinates.

```vb
x$ = MOUSEX                     ' X coordinate (0 to screen width)
y$ = MOUSEY                     ' Y coordinate (0 to screen height)

LET x$ = MOUSEX
LET y$ = MOUSEY
PSET (x$, y$), 15               ' Draw at mouse position
```

### MOUSEB - Mouse Buttons

Get mouse button state (bitwise flags).

```vb
buttons$ = MOUSEB

' Button flags:
' MOUSE_LEFT#    ' Value: 1
' MOUSE_RIGHT#   ' Value: 2
' MOUSE_MIDDLE#  ' Value: 4
```

**Check specific buttons:**

```vb
LET buttons$ = MOUSEB

IF buttons$ AND MOUSE_LEFT# THEN
    PRINT "Left button pressed"
ENDIF

IF buttons$ AND MOUSE_RIGHT# THEN
    PRINT "Right button pressed"
ENDIF

IF buttons$ > 0 THEN
    PRINT "Any button pressed"
ENDIF
```

## Complete Examples

### Example 1: Rotating Shapes

[RotatingShapesDemo.bas](https://github.com/EkBass/BazzBasic/blob/main/Examples/RotatingShapesDemo.bas)

### Example 2: Bouncing Ball
[BouncingBall.bas](https://github.com/EkBass/BazzBasic/blob/main/Examples/BouncingBall.bas)


## Performance Tips

1. **Always use SCREENLOCK for animation:**
   ```vb
   WHILE 1
   	' Math and logic here
   		
		SCREENLOCK ON
		' All drawing here
		SCREENLOCK OFF
	
		' Delay here
       SLEEP 16
   WEND
   ```

2. **Clear only what you need:**
   ```vb
   ' Clear only draw area, not text
   COLOR 0, 0
   LINE (0, 50)-(640, 480), 0, BF
   ```

3. **LINE... BF is much faster than CLS**
   ```vb
	' Filling screen with LINE... BF is faster than CLS
	' CLS works fine with console
    COLOR 0, 0
    LINE (0, 80)-(640, 480), 0, BF
	```


4. **Remove unused shapes:**
   ```vb
   REMOVESHAPE oldShape$  ' Free memory
   ```

5. **Use RGB() once, store value:**
   ```vb
   DIM myColor$
   LET myColor$ = RGB(128, 64, 200)
   ' Use myColor$ multiple times
   ```

6. **Target 60 FPS with SLEEP 16:**
   ```vb
   SLEEP 16  ' ~60 FPS (1000ms / 60 ≈ 16ms)
   ```


---

## Image Support

### LOADIMAGE Function

Load images as shapes that can be moved, rotated, and scaled.

#### Supported Formats

| Format | Transparency | Notes |
|--------|--------------|-------|
| **PNG** | Full alpha (0-255) | Recommended for sprites |
| **BMP** | None | Legacy support |

#### Usage

```vb
id$ = LOADIMAGE("filepath")
```

**Parameters:**
- `filepath` - Path to image file (PNG or BMP)

**Returns:**
- Shape ID string (use with MOVESHAPE, ROTATESHAPE, etc.)

#### Example

```vb
SCREEN 12, 640, 480, "Image Demo"

REM Load PNG image with transparency
DIM sprite$
LET sprite$ = LOADIMAGE("player.png")

REM Position and transform
MOVESHAPE sprite$, 320, 240
ROTATESHAPE sprite$, 45
SCALESHAPE sprite$, 2.0

REM Draw
DRAWSHAPE sprite$
FLIP

SLEEP 3000

REM Cleanup when done
REMOVESHAPE sprite$
```

### PNG Transparency (Alpha Channel)

PNG images support full alpha transparency. Each pixel can have an alpha value from 0 to 255:

| Alpha Value | Result |
|-------------|--------|
| 255 | Fully opaque (solid) |
| 128 | 50% transparent |
| 0 | Fully transparent |

Transparency is read directly from the PNG file - no color key needed.

### Image Transformations

Once loaded, images work exactly like other shapes:

```vb
DIM img$
LET img$ = LOADIMAGE("logo.png")

MOVESHAPE img$, x, y           ' Position (center point)
ROTATESHAPE img$, angle        ' Rotate (degrees)
SCALESHAPE img$, scale         ' Scale (1.0 = original size)
SHOWSHAPE img$                 ' Make visible
HIDESHAPE img$                 ' Make invisible
DRAWSHAPE img$                 ' Render to screen
REMOVESHAPE img$               ' Delete and free memory
```

### Notes

- Images are positioned by their **center point**
- PNG is recommended for all new projects
- Larger images use more memory
