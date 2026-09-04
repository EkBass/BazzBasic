' ============================================
' GRAPHICS SNIPPET 7: LOADIMAGE - Images As Shapes
' Once loaded, an image handle works with the exact same
' MOVESHAPE / ROTATESHAPE / SCALESHAPE / DRAWSHAPE / REMOVESHAPE
' calls as a procedural LOADSHAPE shape.
'
' NEEDS AN ASSET: put a PNG (recommended, has alpha transparency)
' or BMP named "sprite.png" in the same folder as this .bas file
' before running. Without it, LOADIMAGE will fail to find the file.
'
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

' --- FLAGGED DOCUMENTATION CONFLICT (not resolved here) ---
' graphics.md's own inline code comment for MOVESHAPE on an image says:
'     MOVESHAPE IMG#, x, y   ' Position (center point)
' - matching how every other shape type is documented to behave -
' but the same file's "Notes" section a little further down states:
'     "Images are positioned by their top-left point"
' These directly contradict each other, and this hasn't been tested
' against the actual interpreter. Don't assume either one silently -
' if exact placement matters, verify empirically with a known image
' size before relying on it.

[inits]
    SCREEN 0, 640, 480, "LOADIMAGE Demo (needs sprite.png)"

    LET SPRITE# = LOADIMAGE("sprite.png")
    MOVESHAPE SPRITE#, 320, 240
    SCALESHAPE SPRITE#, 1.5

    LET spinAngle$ = 0

[main]
    WHILE INKEY <> KEY_ESC#
        spinAngle$ = spinAngle$ + 2
        IF spinAngle$ >= 360 THEN
            spinAngle$ = 0
        END IF
        ROTATESHAPE SPRITE#, spinAngle$

        SCREENLOCK ON
            LINE (0, 0)-(640, 480), 0, BF
            DRAWSHAPE SPRITE#
            DRAWSTRING "ESC to quit", 10, 10, RGB(255, 255, 255)
        SCREENLOCK OFF

        SLEEP 16
    WEND

    REMOVESHAPE SPRITE#
END

' --- For reference: loading from a URL instead of a local file ---
' LET SPRITE# = LOADIMAGE("https://example.com/sprite.png")
' ' downloads sprite.png to the program's root folder, then loads it
' ' exactly like a local file. To tidy up afterwards:
' SHELL("move sprite.png images\sprite.png")   ' move it into a subfolder
' ' or
' FILEDELETE "sprite.png"                       ' just delete it
