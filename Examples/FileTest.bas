REM ============================================================================
REM BazzBasic - File Operations Test
REM Testing: FileRead, FileExists, FileWrite, FileAppend, FileDelete, ROOT#
REM ============================================================================

PRINT "=== BazzBasic File Operations Test ==="
PRINT ""

REM Display ROOT# constant
PRINT "ROOT# = "; ROOT#
PRINT ""

REM Test file paths
LET testfile$ = "test_output.txt"
LET datafile$ = "data.txt"

REM ============================================================================
REM Test 1: FileWrite - Create new file
REM ============================================================================
PRINT "Test 1: Writing to file..."
FileWrite testfile$, "Hello from BazzBasic!\nThis is line 2.\n"
IF FileExists(testfile$) = 1 THEN
    PRINT "  [OK] File created successfully"
ELSE
    PRINT "  [FAIL] File was not created"
ENDIF
PRINT ""

REM ============================================================================
REM Test 2: FileRead - Read file contents
REM ============================================================================
PRINT "Test 2: Reading file contents..."
LET content$ = FileRead(testfile$)
PRINT "  Contents:"
PRINT content$
PRINT ""

REM ============================================================================
REM Test 3: FileAppend - Add more content
REM ============================================================================
PRINT "Test 3: Appending to file..."
FileAppend testfile$, "This is appended line 3.\n"
LET newcontent$ = FileRead(testfile$)
PRINT "  New contents:"
PRINT newcontent$
PRINT ""

REM ============================================================================
REM Test 4: FileExists - Check if file exists
REM ============================================================================
PRINT "Test 4: Checking file existence..."
IF FileExists(testfile$) = 1 THEN
    PRINT "  [OK] test_output.txt exists"
ELSE
    PRINT "  [FAIL] test_output.txt doesn't exist"
ENDIF

IF FileExists("nonexistent.txt") = 0 THEN
    PRINT "  [OK] nonexistent.txt correctly reported as missing"
ELSE
    PRINT "  [FAIL] nonexistent.txt incorrectly reported as existing"
ENDIF
PRINT ""

REM ============================================================================
REM Test 5: FileDelete - Remove file
REM ============================================================================
PRINT "Test 5: Deleting file..."
FileDelete testfile$
IF FileExists(testfile$) = 0 THEN
    PRINT "  [OK] File deleted successfully"
ELSE
    PRINT "  [FAIL] File was not deleted"
ENDIF
PRINT ""

REM ============================================================================
REM Test 6: Write to subdirectory (auto-create directory)
REM ============================================================================
PRINT "Test 6: Writing to subdirectory..."
LET subdir$ = "testdata/output.txt"
FileWrite subdir$, "Data in subdirectory\n"
IF FileExists(subdir$) = 1 THEN
    PRINT "  [OK] Subdirectory and file created"
    LET subdircontent$ = FileRead(subdir$)
    PRINT "  Contents: "; subdircontent$
    FileDelete subdir$
ELSE
    PRINT "  [FAIL] Failed to create subdirectory"
ENDIF
PRINT ""

REM ============================================================================
REM Test 7: Use ROOT# for absolute path
REM ============================================================================
PRINT "Test 7: Using ROOT# constant..."
LET absolutepath$ = ROOT# + "\\roottest.txt"
FileWrite absolutepath$, "Written using ROOT# constant\n"
IF FileExists(absolutepath$) = 1 THEN
    PRINT "  [OK] File written using ROOT#"
    LET rootcontent$ = FileRead(absolutepath$)
    PRINT "  Contents: "; rootcontent$
    FileDelete absolutepath$
ELSE
    PRINT "  [FAIL] Failed to use ROOT# constant"
ENDIF
PRINT ""

REM ============================================================================
REM Test 8: Highscore simulation
REM ============================================================================
PRINT "Test 8: Simulating highscore save/load..."
LET scorefile$ = "highscore.txt"
LET score# = 12345

REM Save score
FileWrite scorefile$, STR(score#)
PRINT "  Saved score: "; score#

REM Load score
LET loadedscore$ = FileRead(scorefile$)
LET loadedscore# = VAL(loadedscore$)
PRINT "  Loaded score: "; loadedscore#

IF loadedscore# = score# THEN
    PRINT "  [OK] Score saved and loaded correctly"
ELSE
    PRINT "  [FAIL] Score mismatch"
ENDIF

FileDelete scorefile$
PRINT ""

PRINT "=== All file operation tests completed! ==="
END
