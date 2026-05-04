' Paper, Rock, Scissors - Ported from Python
' BazzBasic version 1.4

' Original https://github.com/omonimus1/chicken_wings_and_PYTHON/blob/master/rock_scissor_paper/rock_scissor_paper.py

' ---- FUNCTIONS ----
' Note: Functions must be defined before they are called.
DEF FN GetWinner$(user$, comp$)
    ' 1 = Paper, 2 = Rock, 3 = Scissor
    IF user$ = comp$ THEN RETURN "nobody"
    
    ' User chooses Paper
    IF user$ = 1 THEN
        IF comp$ = 2 THEN RETURN "user" ELSE RETURN "computer"
    END IF
    
    ' User chooses Rock
    IF user$ = 2 THEN
        IF comp$ = 1 THEN RETURN "computer" ELSE RETURN "user"
    END IF
    
    ' User chooses Scissor
    IF user$ = 3 THEN
        IF comp$ = 1 THEN RETURN "user" ELSE RETURN "computer"
    END IF
    
    RETURN "nobody"
END DEF

[inits]
    LET choice$ = 0
    LET compChoice$ = 0
    LET result$ = ""
    
    ' Console Colors
    LET COL_HEAD# = 14  ' Yellow
    LET COL_TEXT# = 15  ' White
    LET COL_WIN#  = 10  ' Lt Green
    LET COL_LOSE# = 12  ' Lt Red
    LET COL_NEUT# = 11  ' Cyan

[main]
    WHILE TRUE
        COLOR COL_HEAD#, 0
        PRINT "\n--- PAPER, ROCK, SCISSORS ---"
        COLOR COL_TEXT#, 0
        PRINT "1 - Paper"
        PRINT "2 - Rock"
        PRINT "3 - Scissor"
        PRINT "Press any other key to stop."

        ' Adjusted original INPUT to WAITKEY() + BETWEEN() combination
        ' more "mature"
        choice$ = WAITKEY()

        ' Exit if choice is not 1, 2, or 3
        IF BETWEEN(choice$, KEY_1#, KEY_3#) = FALSE THEN
            PRINT "Goodbye!"
            END
        END IF
        
        ' User's hand
        PRINT "\nYou chose:"
        LET hand$ = choice$
        GOSUB [sub:print_hand]
        
        ' Computer's move (RND(3) gives 0-2, so +1 gives 1-3)
        compChoice$ = RND(3) + 1
        PRINT "Computer chose:"
        LET hand$ = compChoice$
        GOSUB [sub:print_hand]
        
        ' Determine winner
        result$ = FN GetWinner$(choice$, compChoice$)
        
        ' Print result with colors
        IF result$ = "user" THEN
            COLOR COL_WIN#, 0
            PRINT ">>> User won! <<<"
        ELSEIF result$ = "computer" THEN
            COLOR COL_LOSE#, 0
            PRINT ">>> Computer won! <<<"
        ELSE
            COLOR COL_NEUT#, 0
            PRINT ">>> Nobody won (Tie) <<<"
        END IF
        
        COLOR COL_TEXT#, 0
        PRINT "-----------------------------"
    WEND
END

' ---- SUBROUTINES ----
[sub:print_hand]
    IF hand$ = 1 THEN GOSUB [sub:paper]
    IF hand$ = 2 THEN GOSUB [sub:rock]
    IF hand$ = 3 THEN GOSUB [sub:scissor]
RETURN

[sub:paper]
    PRINT "      _______"
    PRINT "---'     ____)____"
    PRINT "            _______)"
    PRINT "           ________)"
    PRINT "          ________)"
    PRINT "---.___________)"
RETURN

[sub:rock]
    PRINT "    _______"
    PRINT "---'   ___)"
    PRINT "      (____)"
    PRINT "      (____)"
    PRINT "      (___)"
    PRINT "---.__(__)"
RETURN

[sub:scissor]
    PRINT "    _______"
    PRINT "---'   ___)____"
    PRINT "          _____)"
    PRINT "       __________)"
    PRINT "      (____)"
    PRINT "---.__(___)"
RETURN
