' ============================================
' ROSETTA: https://rosettacode.org/wiki/Guess_the_number
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Picks a random number from 1 to 10 and lets the player guess it, answering too low or too high until the guess is right.
' CATEGORY: games
' TAGS: guessing game, random number, input, loop
' MINVERSION: 1.5
' ============================================

[inits]
	LET secret# = INT(RND(10)) + 1
	LET guesses$ = 0


[main]
	PRINT "I'm thinking of a number between 1 and 10"

	WHILE TRUE
		INPUT "Your guess: ", guess$
		guesses$+= 1
		
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
END
