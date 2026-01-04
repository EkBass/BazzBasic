REM Test LET without assignment
LET sound1$
sound1$ = "C:\\Windows\\Media\\Windows Notify.wav"

LET sound2$
sound2$ = "C:\\Windows\\Media\\Windows Ding.wav"

PRINT "Loading sounds..."
LET s1$
s1$ = LOADSOUND(sound1$)

LET s2$
s2$ = LOADSOUND(sound2$)

PRINT "Sound 1 ID: " + s1$
PRINT "Sound 2 ID: " + s2$
PRINT ""

PRINT "Playing sound once..."
SOUNDONCE(s1$)
SLEEP 2000

PRINT "All tests passed!"
END
