REM Simple gumber guessing game with console
REM BazzBasic variation
REM https://github.com/EkBass/BazzBasic
REM https://rosettacode.org/wiki/Guess_the_number

LET secret# = INT(RND(10)) + 1
LET guesses$ = 0

PRINT "I'm thinking of a number between 1 and 10"

WHILE TRUE
    INPUT "Your guess: ", guess$
    guesses$ = guesses$ + 1
    
    IF guess$ = secret# THEN
        PRINT "Correct! You got it in "; guesses$; " tries!"
        SLEEP 2000
        END
    ELSEIF guess$ < secret# THEN
        PRINT "Too low!"
    ELSE
        PRINT "Too high!"
    END IF
WEND