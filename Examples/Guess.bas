REM Simple gumber guessing game with console
REM BazzBasic variation
REM https://github.com/EkBass/BazzBasic

LET secret# = INT(RND(100)) + 1
LET guesses$ = 0

PRINT "I'm thinking of a number between 1 and 100"

[guess]
    INPUT "Your guess: ", guess$
    guesses$ = guesses$ + 1
    
    IF guess$ = secret# THEN
        PRINT "Correct! You got it in "; guesses$; " tries!"
        END
    ELSEIF guess$ < secret# THEN
        PRINT "Too low!"
    ELSE
        PRINT "Too high!"
    END IF
    
    GOTO [guess]
