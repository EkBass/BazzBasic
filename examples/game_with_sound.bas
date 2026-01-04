REM ============================================================================
REM Simple Game Sound Example
REM Demonstrates using sounds in a simple number guessing game
REM ============================================================================

REM Load sound effects
DIM correct$
DIM wrong$
DIM victory$

correct$ = LOADSOUND("C:\Windows\Media\Windows Ding.wav")
wrong$ = LOADSOUND("C:\Windows\Media\Windows Error.wav")
victory$ = LOADSOUND("C:\Windows\Media\Windows Notify.wav")

REM Simple number guessing game
PRINT "=== Number Guessing Game ==="
PRINT ""

DIM target
DIM guess
DIM tries

target = INT(RND * 10) + 1
tries = 0

PRINT "I'm thinking of a number between 1 and 10..."
PRINT ""

WHILE guess <> target
    INPUT "Your guess: ", guess
    tries = tries + 1
    
    IF guess = target THEN
        PRINT "Correct! You win in " + STR(tries) + " tries!"
        SOUNDONCEWAIT(victory$)
    ELSEIF guess < target THEN
        PRINT "Too low! Try again."
        SOUNDONCE(wrong$)
    ELSE
        PRINT "Too high! Try again."
        SOUNDONCE(wrong$)
    ENDIF
    
    SLEEP 500
WEND

PRINT ""
PRINT "Thanks for playing!"
END
