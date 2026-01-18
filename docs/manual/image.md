## LOADIMAGE Function

Load BMP images as shapes that can be moved, rotated, and scaled.

### Usage

```basic
id$ = LOADIMAGE("filepath.bmp")
```

**Parameters:**
- `filepath` - Path to BMP image file (relative or absolute)

**Returns:**
- Shape ID string (use with MOVESHAPE, ROTATESHAPE, etc.)

### Example

```basic
SCREEN 12, 640, 480, "Image Demo"

REM Load image
DIM sprite$
LET sprite$ = LOADIMAGE("player.bmp")

REM Position and transform
MOVESHAPE sprite$, 320, 240
ROTATESHAPE sprite$, 45
SCALESHAPE sprite$, 2.0

REM Draw
SCREENLOCK ON
CLS
DRAWSHAPE sprite$
SCREENLOCK OFF
SLEEP 3000
REM Cleanup when done
REMOVESHAPE sprite$
```

## Image Transformations

Once loaded, images work exactly like other shapes:

```basic
DIM img$
LET img$ = LOADIMAGE("logo.bmp")

MOVESHAPE img$, x, y           ' Position
ROTATESHAPE img$, angle        ' Rotate (degrees)
SCALESHAPE img$, scale         ' Scale (1.0 = original size)
SHOWSHAPE img$                 ' Make visible
HIDESHAPE img$                 ' Make invisible
DRAWSHAPE img$                 ' Render to screen
REMOVESHAPE img$               ' Delete and free memory
```

## Creating Test BMP

To create a test BMP for the demo:

### Using Paint (Windows)
1. Open Paint
2. Create image (e.g., 64x64 pixels)
3. Draw something
4. File → Save As → BMP Picture
5. Save as "test.bmp" in your BazzBasic directory

### Using GIMP
1. Create new image (64x64)
2. Draw content
3. File → Export As
4. Choose "Windows BMP image"
5. Save as "test.bmp"

## Current Limitations
- **BMP only**: Currently only supports .BMP files (uncompressed)
- **No transparency**: BMP format doesn't support alpha channel
- **Memory**: Images consume more memory than primitive shapes
- **Color depth**: 24-bit BMP recommended

## Future Enhancements

Planned:
- PNG support (with transparency)
- JPG support
- Sprite sheets
