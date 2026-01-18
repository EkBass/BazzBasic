## LOADIMAGE Function

Load images as shapes that can be moved, rotated, and scaled.

### Supported Formats

| Format | Transparency | Notes |
|--------|--------------|-------|
| **PNG** | Full alpha (0-255) | Recommended for sprites |
| **BMP** | None | Legacy support |

### Usage

```basic
id$ = LOADIMAGE("filepath")
```

**Parameters:**
- `filepath` - Path to image file (PNG or BMP)

**Returns:**
- Shape ID string (use with MOVESHAPE, ROTATESHAPE, etc.)

### Example

```basic
SCREEN 12, 640, 480, "Image Demo"

REM Load PNG image with transparency
DIM sprite$
LET sprite$ = LOADIMAGE("player.png")

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

## PNG Transparency (Alpha Channel)

PNG images support full alpha transparency. Each pixel can have an alpha value from 0 to 255:

| Alpha Value | Result |
|-------------|--------|
| 255 | Fully opaque (solid) |
| 128 | 50% transparent (blends with background) |
| 0 | Fully transparent (invisible) |

Transparency is read directly from the PNG file - no color key needed. Create transparent areas in any image editor (GIMP, Photoshop, Paint.NET, etc.) and save as PNG.

### Example with transparency

```basic
SCREEN 0, 800, 600, "Alpha Demo"

REM Draw background
LINE (0, 0)-(800, 600), RGB(50, 50, 100), BF

REM Load PNG with transparent areas
DIM ghost$
LET ghost$ = LOADIMAGE("ghost.png")
MOVESHAPE ghost$, 400, 300
DRAWSHAPE ghost$

REM Transparent pixels show the blue background
```

## Image Transformations

Once loaded, images work exactly like other shapes:

```basic
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

## Creating Images

### For PNG with transparency (recommended)

**GIMP:**
1. Create new image with transparent background
2. Draw your sprite
3. File → Export As → PNG
4. Keep alpha channel enabled

**Paint.NET:**
1. Create new image (transparent background)
2. Draw content
3. Save as PNG

**Photoshop:**
1. New document with transparent background
2. Draw content
3. File → Export → PNG (ensure transparency)

### For BMP (legacy)

1. Create image in any editor
2. Save as 24-bit BMP (uncompressed)
3. Note: No transparency support

## Notes

- Images are positioned by their **center point**
- PNG is recommended for all new projects
- BMP support retained for backwards compatibility
- Memory: Larger images use more memory
