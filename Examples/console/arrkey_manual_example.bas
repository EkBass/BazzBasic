' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Loops over an associative array and prints each key with its value using ARRKEY.
' CATEGORY: basics
' TAGS: arrays, arrkey, associative arrays
' MINVERSION: 1.5
' ============================================
DIM scores$
	scores$("Alice") = 95
	scores$("Bob")   = 87
	scores$("Carol") = 92

FOR i$ = 0 TO LEN(scores$()) - 1
    LET name$ = ARRKEY(scores$(), i$)
    PRINT name$; ": "; scores$(name$)
NEXT i$
END
