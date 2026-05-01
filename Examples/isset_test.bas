REM ============================================
REM Test: ISSET() variable existence check
REM ============================================

PRINT "Testing ISSET..."
PRINT ""

REM --- Test 1: Existing variable ---
LET a$ = "foo"
PRINT "Test 1: " + ISSET(a$)
PRINT "Expect: 1"
PRINT ""

REM --- Test 2: Variable declared without value ---
LET b$
PRINT "Test 2: " + ISSET(b$)
PRINT "Expect: 1"
PRINT ""

REM --- Test 3: Existing constant ---
LET MAX# = 100
PRINT "Test 3: " + ISSET(MAX#)
PRINT "Expect: 1"
PRINT ""

REM --- Test 4: Undefined variable ---
PRINT "Test 4: " + ISSET(undef$)
PRINT "Expect: 0"
PRINT ""

REM --- Test 5: Undefined constant ---
PRINT "Test 5: " + ISSET(UNDEF#)
PRINT "Expect: 0"
PRINT ""

REM --- Test 6: Suffix matters: a$ exists, A# does not ---
PRINT "Test 6a: " + ISSET(a$)
PRINT "Expect:  1"
PRINT "Test 6b: " + ISSET(A#)
PRINT "Expect:  0"
PRINT ""

REM --- Test 7: Case-insensitive name matching for $ ---
LET myVar$ = "hello"
PRINT "Test 7a: " + ISSET(myVar$)
PRINT "Test 7b: " + ISSET(MYVAR$)
PRINT "Test 7c: " + ISSET(myvar$)
PRINT "Expect:  1, 1, 1"
PRINT ""

REM --- Test 8: Array name as scalar - should be false ---
DIM arr$
    arr$(0) = "zero"
    arr$(1) = "one"
PRINT "Test 8: " + ISSET(arr$)
PRINT "Expect: 0   (arr$ is an array, not a scalar)"
PRINT ""

REM --- Test 9: Array element access - should be false ---
PRINT "Test 9a: " + ISSET(arr$(0))
PRINT "Test 9b: " + ISSET(arr$(99))
PRINT "Expect:  0, 0   (array elements are not scalar variables)"
PRINT ""

REM --- Test 10: Multidim array element access ---
DIM grid$
    grid$(0, 0) = "X"
PRINT "Test 10: " + ISSET(grid$(0, 0))
PRINT "Expect:  0"
PRINT ""

REM --- Test 11: Use ISSET in IF ---
IF ISSET(a$) THEN
    PRINT "Test 11a: a$ is set"
ELSE
    PRINT "Test 11a: a$ is NOT set (wrong!)"
END IF

IF ISSET(undef2$) THEN
    PRINT "Test 11b: undef2$ is set (wrong!)"
ELSE
    PRINT "Test 11b: undef2$ is NOT set"
END IF
PRINT "Expect:   a$ is set, undef2$ is NOT set"
PRINT ""

PRINT "All ISSET tests done!"
END
