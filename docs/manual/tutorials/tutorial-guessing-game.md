# Tutorial: Guessing Game

Build a simple number guessing game!

## The Goal

Create a game where:
1. Computer picks a random number (1-100)
2. Player guesses
3. Computer says "too high" or "too low"
4. Player wins when they guess correctly

## The Code

```vb
REM Guessing Game

REM Necessary variables
LET secret$		' here is the secret number
LET guess$		' players last guess
LET attempts$	' how many times player has tried

secret$ = INT(RND(100)) + 1	' randomize a number between 1 - 100
' + 1
' Computers see numbers a little differently than humans.
'
' If I ask you to count to ten, you count "one, two. three...nine ten."
' 
' The computer again starts from the number zero.
' "zero, one, two...eight and nine".
'
' So RND(100) returns a value between 0 and 99. That's why we add +1 to it to get a value between 1 and 100


attempts$ = 0 ' this is 0 at start of course

PRINT "I'm thinking of a number between 1 and 100"
PRINT ""

WHILE guess$ <> secret$				' loop until player guess and secret number are same
    INPUT "Your guess: ", guess$
    attempts$ = attempts$ + 1		' increase player attemps each rounf
    
    IF guess$ < secret$ THEN		' If player guess is smaller than secret number
        PRINT "Too low!"
    ELSEIF guess$ > secret$ THEN	' and if its higher
        PRINT "Too high!"
    ENDIF
WEND								' From here, we jump back to begin of the loop as long as "guess$ <> secret$"

' this happens only when WHILE...WEND loop ends
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
