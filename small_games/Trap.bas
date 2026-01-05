' TRAP - BazzBasic Edition
' Original by Steve Ullman (1972)
' BazzBasic version optimized for AI Reference

[start]
    LET max_guesses# = 6
    LET range# = 100
    
    COLOR 14, 0 : CLS
    PRINT " "; REPEAT("*", 32)
    PRINT " *"; REPEAT(" ", 30); "*"
    PRINT " * TRAP                         *"
    PRINT " * CREATIVE COMPUTING           *"
    PRINT " *"; REPEAT(" ", 30); "*"
    PRINT " "; REPEAT("*", 32)
    
    COLOR 15, 0
    PRINT "\n INSTRUCTIONS (Y/N)? ";
    INPUT "", z$
    
    IF UCASE(LEFT(z$, 1)) = "Y" THEN
        COLOR 7, 0
        PRINT "\n I AM THINKING OF A NUMBER BETWEEN 1 AND"; range#
        PRINT " TRY TO GUESS MY NUMBER. ON EACH GUESS,"
        PRINT " YOU ARE TO ENTER 2 NUMBERS, TRYING TO TRAP"
        PRINT " MY NUMBER BETWEEN THE TWO NUMBERS. I WILL"
        PRINT " TELL YOU IF YOU HAVE TRAPPED MY NUMBER, IF MY"
        PRINT " NUMBER IS LARGER THAN YOUR TWO NUMBERS, OR IF"
        PRINT " MY NUMBER IS SMALLER THAN YOUR TWO NUMBERS."
        PRINT " IF YOU WANT TO GUESS ONE SINGLE NUMBER, TYPE"
        PRINT " YOUR GUESS FOR BOTH YOUR TRAP NUMBERS."
        PRINT " YOU GET"; max_guesses#; "GUESSES TO GET MY NUMBER."
    END IF

[game_init]
    LET secret$ = RND(range#) + 1
    
    FOR q$ = 1 TO max_guesses#
        COLOR 15, 0
        PRINT "\n GUESS #"; q$;
        INPUT " - ENTER TWO NUMBERS (e.g. 10, 20): ", a$, b$
        
        ' Winning condition: single guess match
        IF a$ = b$ AND secret$ = a$ THEN GOTO [win]
        
        ' Ensure a$ is the smaller number
        IF VAL(a$) > VAL(b$) THEN
            LET temp$ = a$
            a$ = b$
            b$ = temp$
        END IF
        
        ' Check trap logic
        IF VAL(a$) <= VAL(secret$) AND VAL(secret$) <= VAL(b$) THEN
            COLOR 10, 0
            PRINT " YOU HAVE TRAPPED MY NUMBER."
        ELSEIF VAL(secret$) < VAL(a$) THEN
            COLOR 9, 0
            PRINT " MY NUMBER IS SMALLER THAN YOUR TRAP NUMBERS."
        ELSE
            COLOR 12, 0
            PRINT " MY NUMBER IS LARGER THAN YOUR TRAP NUMBERS."
        END IF
    NEXT q$

    COLOR 4, 0
    PRINT "\n SORRY, THAT'S"; max_guesses#; "GUESSES."
    PRINT " THE NUMBER WAS"; secret$
    GOTO [retry]

[win]
    COLOR 13, 0
    PRINT "\n *** YOU GOT IT!!! ***"

[retry]
    COLOR 15, 0
    PRINT "\n TRY AGAIN (Y/N)? ";
    INPUT "", r$
    IF UCASE$(LEFT$(r$, 1)) = "Y" THEN GOTO [game_init]

[exit]
    PRINT "\n BYE..."
    END