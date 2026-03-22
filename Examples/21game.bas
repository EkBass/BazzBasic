' ============================================
' 21 GAME - BazzBasic Edition
' https://rosettacode.org/wiki/21_game
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Two players alternate saying 1, 2, or 3.
' That number is added to a running total.
' The player who reaches exactly 21 WINS!
' ============================================

' Color constants
LET BLACK#      = 0
LET BLUE#       = 1
LET GREEN#      = 2
LET CYAN#       = 3
LET RED#        = 4
LET MAGENTA#    = 5
LET BROWN#      = 6
LET LGRAY#      = 7
LET DGRAY#      = 8
LET LBLUE#      = 9
LET LGREEN#     = 10
LET LCYAN#      = 11
LET LRED#       = 12
LET LMAGENTA#   = 13
LET YELLOW#     = 14
LET WHITE#      = 15

GOSUB [sub:title]

[sub:newGame]
    GOSUB [sub:playRound]
    GOTO [sub:newGame]
END

' ============================================
' TITLE SCREEN
' ============================================
[sub:title]
    CLS
    COLOR YELLOW#, BLACK#
    PRINT "\n "; REPEAT("*", 40)
    PRINT " *"; REPEAT(" ", 38); "*"
    PRINT " *          ";
    COLOR WHITE#, BLACK#
    PRINT "T H E   2 1   G A M E";
    COLOR YELLOW#, BLACK#
    PRINT "          *"
    PRINT " *"; REPEAT(" ", 38); "*"
    PRINT " "; REPEAT("*", 40)

    COLOR LGRAY#, BLACK#
    PRINT "\n Rosetta Code task: rosettacode.org/wiki/21_game"
    PRINT " BazzBasic Edition\n"

    COLOR CYAN#, BLACK#
    PRINT " RULES:"
    COLOR WHITE#, BLACK#
    PRINT " - Running total starts at 0"
    PRINT " - Take turns saying a number: 1, 2, or 3"
    PRINT " - That number is added to the running total"
    PRINT " - The player who reaches exactly 21 WINS!\n"

    COLOR YELLOW#, BLACK#
    PRINT " Hint: there IS a perfect strategy...\n"

    COLOR WHITE#, BLACK#
    PRINT REPEAT("-", 50)
    PRINT " Press ENTER to start...";
    WAITKEY(KEY_ENTER#)
    PRINT ""
RETURN

' ============================================
' PLAY ONE ROUND
' ============================================
[sub:playRound]
    LET total$ = 0

    [gameLoop]
        CLS
        GOSUB [sub:drawTotal]

        GOSUB [sub:playerTurn]
        IF total$ = 21 THEN GOTO [sub:playerWins]

        GOSUB [sub:computerTurn]
        IF total$ = 21 THEN GOTO [sub:computerWins]

        GOTO [gameLoop]

[sub:playerWins]
    CLS
    GOSUB [sub:drawTotal]
    COLOR LGREEN#, BLACK#
    PRINT "\n "; REPEAT("*", 34)
    PRINT " *  YOU WIN! You reached 21!  *"
    PRINT " "; REPEAT("*", 34)
    COLOR WHITE#, BLACK#
    PRINT "\n You found the strategy! Play again?\n"
    PRINT " Press ENTER...";
    WAITKEY(KEY_ENTER#)
    PRINT ""
RETURN

[sub:computerWins]
    CLS
    GOSUB [sub:drawTotal]
    COLOR LRED#, BLACK#
    PRINT "\n "; REPEAT("*", 32)
    PRINT " *  I WIN! I reached 21.  *"
    PRINT " "; REPEAT("*", 32)
    COLOR YELLOW#, BLACK#
    PRINT "\n Better luck next time!\n"
    COLOR WHITE#, BLACK#
    PRINT " Press ENTER to try again...";
    WAITKEY(KEY_ENTER#)
    PRINT ""
RETURN

' ============================================
' SHOW THE RUNNING TOTAL WITH A PROGRESS BAR
' ============================================
[sub:drawTotal]
    COLOR YELLOW#, BLACK#
    PRINT "\n "; REPEAT("=", 44)
    PRINT "          RUNNING TOTAL:  ";
    COLOR WHITE#, BLACK#
    PRINT total$; " / 21"
    COLOR YELLOW#, BLACK#
    PRINT " "; REPEAT("=", 44); "\n"

    COLOR CYAN#, BLACK#
    PRINT "  [";
    COLOR LGREEN#, BLACK#
    PRINT REPEAT("|", total$);
    COLOR DGRAY#, BLACK#
    PRINT REPEAT(".", 21 - total$);
    COLOR CYAN#, BLACK#
    PRINT "] ";
    COLOR WHITE#, BLACK#
    PRINT total$; "\n"
RETURN

' ============================================
' PLAYER'S TURN
' ============================================
[sub:playerTurn]
    COLOR LGREEN#, BLACK#
    PRINT " YOUR TURN — press 1, 2 or 3: ";
    COLOR WHITE#, BLACK#

    LET key$ = WAITKEY(KEY_1#, KEY_2#, KEY_3#)
    LET said$ = key$ - 48       ' ASCII: '1'=49, '2'=50, '3'=51

    ' Only remaining check: don't exceed 21
    WHILE total$ + said$ > 21
        COLOR LRED#, BLACK#
        PRINT said$; "  (would exceed 21!)"
        PRINT " Choose 1 to "; 21 - total$; ": ";
        COLOR WHITE#, BLACK#
        LET key$ = WAITKEY(KEY_1#, KEY_2#, KEY_3#)
        LET said$ = key$ - 48
    WEND

    total$ = total$ + said$

    COLOR CYAN#, BLACK#
    PRINT said$; "  — total is now "; total$; "\n"
    SLEEP 700
RETURN

' ============================================
' COMPUTER'S TURN - optimal strategy
' ============================================
' Losing positions for the current player: 1, 5, 9, 13, 17
' (no matter what you say, opponent reaches the next one)
' These are all 1 mod 4. Computer always aims to leave
' the human at one of these positions.
'
' Formula: say = (4 + 1 - total mod 4) mod 4
' If result is 0 we are stuck in a losing spot -> random
' ============================================
[sub:computerTurn]
    COLOR LRED#, BLACK#
    PRINT " COMPUTER'S TURN"
    COLOR WHITE#, BLACK#
    SLEEP 900

    ' Win immediately if possible
    IF 21 - total$ >= 1 AND 21 - total$ <= 3 THEN
        LET compSaid$ = 21 - total$
        GOTO [doCompMove]
    END IF

    ' Optimal: leave total at 1, 5, 9, 13 or 17 (all 1 mod 4)
    LET compSaid$ = MOD(4 + 1 - MOD(total$, 4), 4)

    ' compSaid = 0 means we are in a losing position -> random
    IF compSaid$ = 0 THEN LET compSaid$ = INT(RND(3)) + 1

    ' Safety: never exceed 21
    IF total$ + compSaid$ > 21 THEN LET compSaid$ = 21 - total$

    [doCompMove]
    total$ = total$ + compSaid$

    COLOR MAGENTA#, BLACK#
    PRINT " I say "; compSaid$; " — total is now "; total$; "\n"
    SLEEP 1200
RETURN
