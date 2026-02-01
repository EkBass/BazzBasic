REM ============================================
REM Test: INPUT and LINE INPUT in Library
REM Tests library functions with user input
REM ============================================

INCLUDE "InputLib.bb"
INCLUDE "const_lib_test.bb"
PRINT "Testing INPUT and LINE INPUT in library"
PRINT "========================================"
PRINT ""

LET name$ = FN INPUTLIB_getName$()
LET age$ = FN INPUTLIB_getAge$()
LET address$ = FN INPUTLIB_getAddress$()
LET MY_CONSTANT# = "foo"
LET foo$ = FN CONST_LIB_TEST_INVERT_CONST$()

PRINT ""
PRINT "Results:"
PRINT "--------"
PRINT "Name: "; name$
PRINT "Age: "; age$
PRINT "Address: "; address$
PRINT ""
PRINT "Test complete!"
END
