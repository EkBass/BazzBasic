REM ============================================================================
REM BazzBasic Sound System Test
REM Tests LOADSOUND, SOUNDONCE, SOUNDREPEAT, SOUNDSTOP, SOUNDSTOPALL, SOUNDONCEWAIT
REM ============================================================================

PRINT "BazzBasic Sound System Test"
PRINT "==========================="
PRINT ""

REM Load test sound files
REM NOTE: Replace these paths with actual .wav or .mp3 files on your system

LET sound1$
sound1$ = "C:\\Users\\ekvir\\source\\repos\\BazzBasic\\examples\\cinematic-hit.mp3"
LET sound2$
sound2$ = "C:\\Users\\ekvir\\source\\repos\\BazzBasic\\examples\\footsteps-approaching.mp3"

PRINT "Loading sounds..."
LET s1$
s1$ = LOADSOUND(sound1$)
LET s2$
s2$ = LOADSOUND(sound2$)


PRINT "Sound 1 ID: " + s1$
PRINT "Sound 2 ID: " + s2$
PRINT ""

REM Test 1: Play sound once in background
PRINT "Test 1: Playing sound once in background..."
SOUNDONCE(s1$)
SLEEP 2000
PRINT "Done"
PRINT ""

REM Test 2: Play sound and wait
PRINT "Test 2: Playing sound and waiting for completion..."
SOUNDONCEWAIT(s2$)
PRINT "Done"
PRINT ""

REM Test 3: Play repeating sound
PRINT "Test 3: Playing repeating sound for 3 seconds..."
SOUNDREPEAT(s1$)
SLEEP 3000
PRINT "Stopping sound..."
SOUNDSTOP(s1$)
PRINT "Done"
PRINT ""

REM Test 4: Multiple sounds
PRINT "Test 4: Playing multiple sounds simultaneously..."
SOUNDONCE(s1$)
SOUNDONCE(s2$)
SLEEP 2000
PRINT "Done"
PRINT ""

REM Test 5: Stop all sounds
PRINT "Test 5: Testing SOUNDSTOPALL..."
SOUNDREPEAT(s1$)
SOUNDREPEAT(s2$)
SLEEP 1000
PRINT "Stopping all sounds..."
SOUNDSTOPALL
SLEEP 500
PRINT "Done"
PRINT ""

PRINT "All tests completed!"
END
