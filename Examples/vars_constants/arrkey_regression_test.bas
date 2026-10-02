REM Regression check: ROWCOUNT, ASJSON, JOIN still work after OrderedDictionary swap

DIM row$
	row$("0,name") = "Widget"
	row$("0,price") = 9.99
	row$("1,name") = "Gadget"
	row$("1,price") = 19.99

PRINT "ROWCOUNT: "; ROWCOUNT(row$())

PRINT "ASJSON: "; ASJSON(row$())

DIM a$
	a$("x") = 1
DIM b$
	b$("y") = 2
DIM c$
JOIN c$, a$, b$
PRINT "JOIN LEN: "; LEN(c$())

REM Out-of-range ARRKEY should error, not crash silently past bounds
PRINT "Last valid key: "; ARRKEY(row$(), LEN(row$()) - 1)
