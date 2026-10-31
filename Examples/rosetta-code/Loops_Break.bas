' ============================================
' ROSETTA: https://rosettacode.org/wiki/Loops/Break
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints random numbers from 0 to 19 in a loop and leaves the loop with EXIT WHILE when the number 10 comes up, otherwise printing a second random number and starting over.
' CATEGORY: basics
' TAGS: loops, break, exit while, rnd
' MINVERSION: 1.5
' ============================================

' Print a random number 0..19. If it is 10, stop the loop.
' Otherwise print a second random number and start over.
' EXIT WHILE leaves the loop at once and continues after WEND.
[inits]
	LET a$

[main]
    WHILE TRUE
        a$ = RND(20)
        PRINT a$;
        IF a$ = 10 THEN EXIT WHILE
        PRINT "  "; RND(20)
    WEND
    PRINT ""
END

' Output (random, for example):
' 3  17
' 12  0
' 7  19
' 10
