REM ============================================
REM Test: LOCATE bug fix - text should clear properly
REM ============================================

SCREEN 0, 640, 480, "LOCATE Test"

COLOR 15, 0

REM Write some text
LOCATE 5, 5
PRINT "ABCDEFGHIJKLMNOP"

SLEEP 1000

REM Now overwrite with spaces - should completely clear
LOCATE 5, 5
PRINT "                "

SLEEP 500

REM Write shorter text
LOCATE 5, 5
PRINT "OK!"

SLEEP 1000

REM Test with different colors
COLOR 14, 1
LOCATE 10, 10
PRINT "Yellow on Blue"

SLEEP 1000

COLOR 15, 0
LOCATE 10, 10
PRINT "              "

LOCATE 10, 10
PRINT "Cleared!"

SLEEP 2000
END
