' test string manipulation spped
LET ROUNDS# = 100
LET IMPS# = 32
LET testString$ = SRAND(IMPS#)
LET value$

PRINT ASC("A")
END
FOR i$ = 1 to ROUNDS#
	FOR ii$ = 1 to IMPS#
		value$ = value$ + (testString$, ii$, 1)
	NEXT
	PRINT i$; " : "; value$
NEXT
