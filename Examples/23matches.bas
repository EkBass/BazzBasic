' ============================================
' 23 MATCHES - BazzBasic Edition
' Original: Bob Albrecht, People's Computer Co
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Nim-style game: Take 1-3 matches per turn.
' Whoever takes the LAST match loses!
' ============================================

' Color constants
LET BLACK#		= 0
LET BLUE# 		= 1
LET GREEN# 		= 2
LET CYAN# 		= 3
LET RED# 		= 4
LET MAGENTA# 	= 5
LET BROWN# 		= 6
LET LGRAY# 		= 7
LET DGRAY# 		= 8
LET LBLUE# 		= 9
LET LGREEN# 	= 10
LET LCYAN# 		= 11
LET LRED# 		= 12
LET LMAGENTA#	= 13
LET YELLOW# 	= 14
LET WHITE# 		= 15

GOSUB [title]

[newGame]
    LET matches$ = 23
    LET playerWins$ = 0
    LET compWins$ = 0
    
    GOSUB [playRound]
    GOTO [newGame]
END

' ============================================
' TITLE SCREEN
' ============================================
[title]
    CLS
    COLOR YELLOW#, BLACK#
    PRINT "\n "; REPEAT("*", 40)
    PRINT " *"; REPEAT(" ", 38); "*"
    PRINT " *          ";
    COLOR WHITE#, BLACK#
    PRINT "2 3   M A T C H E S";
    COLOR YELLOW#, BLACK#
    PRINT "         *"
    PRINT " *"; REPEAT(" ", 38); "*"
    PRINT " "; REPEAT("*", 40)
    
    COLOR LGRAY#, BLACK#
    PRINT "\n Original by Bob Albrecht, People's Computer Co"
    PRINT " BazzBasic Edition\n"
    
    ' Draw some matches as ASCII art
    COLOR BROWN#, BLACK#
    PRINT "        "; REPEAT("| ", 12)
    COLOR RED#, BLACK#
    PRINT "        "; REPEAT("* ", 12)
    
    COLOR CYAN#, BLACK#
    PRINT "\n RULES:"
    COLOR WHITE#, BLACK#
    PRINT " - We start with 23 matches"
    PRINT " - Take turns removing 1, 2, or 3 matches"
    PRINT " - Whoever takes the LAST match LOSES!\n"
    
    COLOR YELLOW#, BLACK#
    PRINT " Good luck... you'll need it! (Ha ha)\n"
    
    COLOR WHITE#, BLACK#
    PRINT REPEAT("-", 45)
    PRINT " Press ENTER to start...";
    INPUT "", temp$
RETURN

' ============================================
' PLAY ONE ROUND
' ============================================
[playRound]
    LET matches$ = 23
    
    [gameLoop]
        CLS
        GOSUB [drawMatches]
        
        ' Player's turn
        GOSUB [playerTurn]
        IF matches$ = 0 THEN GOTO [computerWins]
        
        ' Computer's turn
        GOSUB [computerTurn]
        IF matches$ = 0 THEN GOTO [playerWins]
        
        GOTO [gameLoop]

[playerWins]
    CLS
    GOSUB [drawMatches]
    COLOR LGREEN#, BLACK#
    PRINT "\n "; REPEAT("*", 35)
    PRINT " *  YOU WIN! I had to take the last match.  *"
    PRINT " "; REPEAT("*", 35)
    COLOR WHITE#, BLACK#
    PRINT "\n Let's play again...\n"
    PRINT " Press ENTER...";
    INPUT "", temp$
RETURN

[computerWins]
    CLS
    GOSUB [drawMatches]
    COLOR LRED#, BLACK#
    PRINT "\n "; REPEAT("*", 35)
    PRINT " *  I WIN! You took the last match!  *"
    PRINT " "; REPEAT("*", 35)
    COLOR YELLOW#, BLACK#
    PRINT "\n Better luck next time!\n"
    COLOR WHITE#, BLACK#
    PRINT " Press ENTER to try again...";
    INPUT "", temp$
RETURN

' ============================================
' DRAW MATCHES VISUALLY
' ============================================
[drawMatches]
    COLOR YELLOW#, BLACK#
    PRINT "\n "; REPEAT("=", 45)
    PRINT "              MATCHES REMAINING: ";
    COLOR WHITE#, BLACK#
    PRINT matches$
    COLOR YELLOW#, BLACK#
    PRINT " "; REPEAT("=", 45); "\n"
    
    ' Draw match sticks
    IF matches$ > 0 THEN
        ' Match heads (red)
        COLOR RED#, BLACK#
        PRINT "   ";
        FOR i$ = 1 TO matches$
            PRINT "* ";
        NEXT
        PRINT ""
        
        ' Match sticks (brown)
        COLOR BROWN#, BLACK#
        PRINT "   ";
        FOR i$ = 1 TO matches$
            PRINT "| ";
        NEXT
        PRINT ""
        PRINT "   ";
        FOR i$ = 1 TO matches$
            PRINT "| ";
        NEXT
        PRINT "\n"
    ELSE
        COLOR LGRAY#, BLACK#
        PRINT "   (no matches left)\n"
    END IF
    
    COLOR WHITE#, BLACK#
RETURN

' ============================================
' PLAYER'S TURN
' ============================================
[playerTurn]
    COLOR LGREEN#, BLACK#
    PRINT " YOUR TURN"
    COLOR WHITE#, BLACK#
    
    [getInput]
    PRINT " How many matches do you take (1-3)? ";
    INPUT "", take$
    
    ' Validate input
    IF take$ < 1 OR take$ > 3 THEN
        COLOR LRED#, BLACK#
        PRINT " You must take 1, 2, or 3 matches!"
        COLOR WHITE#, BLACK#
        GOTO [getInput]
    END IF
    
    IF take$ > matches$ THEN
        COLOR LRED#, BLACK#
        PRINT " There are only "; matches$; " matches left!"
        COLOR WHITE#, BLACK#
        GOTO [getInput]
    END IF
    
    ' Check if not integer
    IF take$ <> INT(take$) THEN
        COLOR LRED#, BLACK#
        PRINT " Please enter a whole number!"
        COLOR WHITE#, BLACK#
        GOTO [getInput]
    END IF
    
    matches$ = matches$ - take$
    
    COLOR CYAN#, BLACK#
    PRINT "\n You took "; take$; " match";
    IF take$ > 1 THEN PRINT "es";
    PRINT "."
    
    IF matches$ > 0 THEN
        PRINT " "; matches$; " remaining.\n"
        SLEEP 1000
    END IF
RETURN

' ============================================
' COMPUTER'S TURN (with smart endgame)
' ============================================
[computerTurn]
    COLOR LRED#, BLACK#
    PRINT " COMPUTER'S TURN"
    COLOR WHITE#, BLACK#
    SLEEP 800
    
    ' === SMART ENDGAME: If 4 or fewer, play to win ===
    IF matches$ <= 4 AND matches$ > 1 THEN
        ' Take all but one - force player to take last
        LET compTake$ = matches$ - 1
        GOTO [doCompMove]
    END IF
    
    ' === OPTIMAL STRATEGY: Keep matches at 1 mod 4 ===
    ' Winning positions: 1, 5, 9, 13, 17, 21
    ' After our move, we want (matches mod 4) = 1
    
    LET remainder$ = matches$ - 4 * INT(matches$ / 4)
    
    IF remainder$ = 1 THEN
        ' Already in losing position - take random 1-3
        LET compTake$ = INT(RND(3)) + 1
        IF compTake$ > matches$ THEN compTake$ = matches$
    ELSE
        ' Calculate optimal move
        ' We want to leave (matches - take) mod 4 = 1
        ' So take = (remainder + 3) mod 4
        LET compTake$ = (remainder$ + 3) - 4 * INT((remainder$ + 3) / 4)
        IF compTake$ = 0 THEN compTake$ = 1
        IF compTake$ > matches$ THEN compTake$ = matches$
    END IF
    
    [doCompMove]
    matches$ = matches$ - compTake$
    
    COLOR MAGENTA#, BLACK#
    PRINT " I take "; compTake$; " match";
    IF compTake$ > 1 THEN PRINT "es";
    PRINT "."
    
    IF matches$ > 0 THEN
        PRINT " "; matches$; " remaining.\n"
    END IF
    
    SLEEP 1200
RETURN
