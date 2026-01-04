SCREEN 12
DIM sprite$
LET sprite$ = LOADIMAGE("temp.bmp")

MOVESHAPE sprite$, 320, 240
ROTATESHAPE sprite$, 45      ' Pyöritä 45 astetta
SCALESHAPE sprite$, 2.0      ' 2x suurempi

SCREENLOCK ON
DRAWSHAPE sprite$
SCREENLOCK OFF
SLEEP 3000
REMOVESHAPE sprite$          ' Vapauta muisti
END