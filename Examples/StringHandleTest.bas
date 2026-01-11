' BazzBasic
' Loop through string

LET testString$ = SRAND(16)
LET value$

FOR i$ = 1 to LEN(testString$)
	value$ = MID(testString$, i$, 1)
	PRINT i$; " : "; value$
NEXT
