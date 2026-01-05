SCREEN 12
DIM sprite$
LET sprite$ = LOADIMAGE("temp.bmp") # Download from this same folder

MOVESHAPE sprite$, 320, 240
ROTATESHAPE sprite$, 45      ' Rotate 45
SCALESHAPE sprite$, 2.0      ' Scale by 2

SCREENLOCK ON
DRAWSHAPE sprite$
SCREENLOCK OFF
SLEEP 3000
REMOVESHAPE sprite$          ' Free mem
END
