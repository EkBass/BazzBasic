' ============================================
' ROSETTA: https://rosettacode.org/wiki/Grayscale_image
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Converts a picture to grayscale: draws assets/mavbeacon.png, reads every pixel with POINT, computes its luminance from the red, green and blue values and writes the gray pixel back with PSET.
' CATEGORY: drawing
' TAGS: grayscale, image processing, point, pset, loadimage
' REQUIRES: assets/mavbeacon.png
' MINVERSION: 1.5
' ============================================
' Translation of: #BASIC256
' Bit adjusted version of original by: https://github.com/Mkratzen

[inits]
	LET wid# = 293
	LET hgt# = 341
	LET pt$, blu$, grn$, red$, lum$

	SCREEN 0, wid#, hgt#
	LET raster# = LOADIMAGE ("assets/mavbeacon.png")

[draw]
	DRAWSHAPE raster#
		FOR x$ = 0 TO wid# - 1
			FOR y$ = 0 TO hgt# - 1
                pt$ = POINT(x$, y$)
                blu$ = pt$ % 256
                pt$ = INT(pt$ / 256)
				grn$ = pt$ % 256
				pt$ = INT(pt$ / 256)
				red$ = pt$ % 256
				lum$ = INT(0.2126 * red$ + 0.7152 * grn$ + 0.0722 * blu$ + 0.5)
				PSET (x$, y$), RGB(lum$, lum$, lum$)
			NEXT y$
		NEXT x$
	LET kw$ = WAITKEY()
END
