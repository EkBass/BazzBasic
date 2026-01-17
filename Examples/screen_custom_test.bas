REM ============================================
REM Test: Custom SCREEN dimensions
REM ============================================

PRINT "Test 1: Custom 800x600 window"
SCREEN 0, 800, 600, "Custom 800x600"

PRINT "Drawing box to show dimensions..."
LINE (0, 0)-(799, 599), 15, B
LINE (100, 100)-(700, 500), 14, BF
LOCATE 15, 30
PRINT "800 x 600 Custom Window"

SLEEP 3000

REM Close graphics and try another size
SCREEN 0

PRINT "Test 2: Custom 1024x768 window"
SCREEN 0, 1024, 768, "Custom 1024x768"

LINE (0, 0)-(1023, 767), 15, B
CIRCLE (512, 384), 200, 10
LOCATE 20, 40
PRINT "1024 x 768 Custom Window"

SLEEP 3000

PRINT "Tests complete!"
END
