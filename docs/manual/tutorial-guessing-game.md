# Tutorial: Guessing Game

Build a simple number guessing game!

## The Goal

Create a game where:
1. Computer picks a random number (1-100)
2. Player guesses
3. Computer says "too high" or "too low"
4. Player wins when they guess correctly

## The Code

```basic
REM Guessing Game
LET secret$
LET guess$
LET attempts$

secret$ = INT(RND(100)) + 1
attempts$ = 0

PRINT "I'm thinking of a number between 1 and 100"
PRINT ""

WHILE guess$ <> secret$
    INPUT "Your guess: ", guess$
    attempts$ = attempts$ + 1
    
    IF guess$ < secret$ THEN
        PRINT "Too low!"
    ELSEIF guess$ > secret$ THEN
        PRINT "Too high!"
    ENDIF
WEND

PRINT ""
PRINT "Correct! You got it in "; attempts$; " attempts!"
```

## How It Works

1. `RND(100)` generates random number 0-99
2. `INT()` removes decimals
3. `+ 1` shifts range to 1-100
4. `WHILE` loop continues until correct guess
5. `IF/ELSEIF` gives hints

## Challenges

Try modifying the game:
- Change the range (1-50, 1-1000)
- Add a maximum number of attempts
- Show how close the guess was

## What You Learned

- `RND()` for random numbers
- `WHILE/WEND` loops
- `IF/ELSEIF/ENDIF` conditions
- Counting with variables

## Next Steps

- [Ball Animation Tutorial](tutorial-ball-animation.md)
- [Control Flow Reference](control-flow.md)
