DIM scores$
	scores$("Alice") = 95
	scores$("Bob")   = 87
	scores$("Carol") = 92

FOR i$ = 0 TO LEN(scores$()) - 1
    LET name$ = ARRKEY(scores$(), i$)
    PRINT name$; ": "; scores$(name$)
NEXT i$
END
