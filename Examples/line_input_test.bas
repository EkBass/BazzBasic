REM ============================================
REM Test: LINE INPUT
REM Reads entire line including spaces
REM ============================================

LET name$ = ""
LET address$ = ""

LINE INPUT "Enter your full name: ", name$
LINE INPUT "Enter your address: ", address$

PRINT ""
PRINT "Name: "; name$
PRINT "Address: "; address$

END
