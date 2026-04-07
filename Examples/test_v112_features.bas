' ============================================================
' BazzBasic v1.1.2 feature test
' Tests: PRG_ROOT#, CURPOS, JOIN, SCREEN reinitialization
' ============================================================

CLS
COLOR 15, 0
PRINT "BazzBasic v1.1.2 Feature Test"
PRINT REPEAT("=", 40)
PRINT ""

' ------------------------------------------------------------
PRINT "1) PRG_ROOT#"
PRINT "   Value: "; PRG_ROOT#
PRINT ""

' ------------------------------------------------------------
PRINT "2) CURPOS"
LOCATE 10, 5
PRINT "Cursor at row 10, col 5"
LET r$ = CURPOS("row")
LET c$ = CURPOS("col")
PRINT "   CURPOS row: "; r$; "  (expected: 11)"
PRINT "   CURPOS col: "; c$; "  (expected: 1)"
PRINT ""

' ------------------------------------------------------------
PRINT "3) JOIN - array merge (src2 overwrites on conflict)"
DIM a$
DIM b$
DIM c$

a$("name")  = "Alice"
a$("score") = 100
a$("level") = 3

b$("score") = 999   ' Conflict - this should overwrite a$("score")
b$("city")  = "Helsinki"

JOIN c$, a$, b$

PRINT "   c$(name)  = "; c$("name");  "  (expected: Alice)"
PRINT "   c$(score) = "; c$("score"); "  (expected: 999)"
PRINT "   c$(level) = "; c$("level"); "  (expected: 3)"
PRINT "   c$(city)  = "; c$("city");  "  (expected: Helsinki)"

LET ok$ = 1
IF c$("name")  <> "Alice"    THEN PRINT "   ERROR: name"    : ok$ = 0
IF c$("score") <> 999        THEN PRINT "   ERROR: score"   : ok$ = 0
IF c$("level") <> 3          THEN PRINT "   ERROR: level"   : ok$ = 0
IF c$("city")  <> "Helsinki" THEN PRINT "   ERROR: city"    : ok$ = 0
IF ok$ = 1 THEN PRINT "   JOIN: OK"
PRINT ""

' ------------------------------------------------------------
PRINT "4) SCREEN reinitialization"
PRINT "   Opening 400x200 window..."
SLEEP 500
SCREEN 0, 400, 200, "First window"
COLOR 14, 1
CLS
LOCATE 2, 2
PRINT "First SCREEN - 400x200"
LOCATE 3, 2
PRINT "Reinitializing in 2 seconds..."
SLEEP 2000

SCREEN 0, 640, 300, "Second window"
COLOR 10, 0
CLS
LOCATE 2, 2
PRINT "Second SCREEN - 640x300"
LOCATE 3, 2
PRINT "Reinitialization OK! Press any key..."
LET k$ = WAITKEY()

' ------------------------------------------------------------
CLS
COLOR 15, 0
PRINT "All tests done."
PRINT "Press any key to exit."
LET k$ = WAITKEY()
END
