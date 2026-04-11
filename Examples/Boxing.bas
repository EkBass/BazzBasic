' ============================================
' BOXING - BazzBasic Edition
' Original: Creative Computing, Morristown NJ
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' Olympic Style Boxing: 3 rounds, best 2/3 wins
' Punches: (1) Full Swing, (2) Hook, (3) Uppercut, (4) Jab
' ============================================

[inits]
    LET BLACK#   = 0
    LET RED#     = 4
    LET GREEN#   = 2
    LET YELLOW#  = 14
    LET WHITE#   = 15
    LET CYAN#    = 11
    LET LGRAY#   = 7
    LET LRED#    = 12
    LET LGREEN#  = 10
    LET MAGENTA# = 13

    LET playerWins$    = 0
    LET opponentWins$  = 0
    LET player$        = ""
    LET opponent$      = ""
    LET playerBest$    = 0
    LET playerWeak$    = 0
    LET opponentBest$  = 0
    LET opponentWeak$  = 0
    LET temp$          = ""
    LET playerDamage$  = 0
    LET opponentDamage$ = 0
    LET attacker$      = 0
    LET bars$          = 0
    LET chance$        = 0
    LET oppPunch$      = 0
    LET punch$         = 0
    LET again$         = ""
    LET punchNum$      = 0
    LET punchName$     = ""

    GOSUB [title]
    GOSUB [setup]
    GOSUB [mainGame]
END

' ============================================
' TITLE SCREEN
' ============================================
[title]
    CLS
    COLOR YELLOW#, BLACK#
    PRINT "\n " + REPEAT("*", 40)
    PRINT " *"; REPEAT(" ", 38); "*"
    PRINT " *          ";
    COLOR WHITE#, BLACK#
    PRINT "B O X I N G";
    COLOR YELLOW#, BLACK#
    PRINT "               *"
    PRINT " *"; REPEAT(" ", 38); "*"
    PRINT " *    OLYMPIC STYLE  -  3 ROUNDS       *"
    PRINT " *"; REPEAT(" ", 38); "*"
    PRINT " " + REPEAT("*", 40)

    COLOR LGRAY#, BLACK#
    PRINT "\n CREATIVE COMPUTING  MORRISTOWN, NEW JERSEY"
    PRINT " BazzBasic Edition\n"

    COLOR CYAN#, BLACK#
    PRINT "        __O__"
    PRINT "       / . . \\"
    PRINT "      |   ^   |"
    PRINT "       \\_===_/"
    PRINT "    .---|   |---."
    PRINT "   /    |___|    \\"
    PRINT "  O====/     \\====O"
    PRINT "        |   |"
    PRINT "        |   |"
    PRINT "       _|   |_"
    PRINT "      |_|   |_|"

    COLOR WHITE#, BLACK#
    PRINT "\n Press ENTER to start...";
    INPUT "", temp$
RETURN

' ============================================
' SETUP - Get fighter names and stats
' ============================================
[setup]
    CLS
    COLOR WHITE#, BLACK#
    PRINT "\n"; REPEAT("=", 50)
    PRINT " FIGHTER SETUP"
    PRINT REPEAT("=", 50)

    COLOR CYAN#, BLACK#
    INPUT "\n What is your OPPONENT'S name? ", opponent$
    INPUT " What is YOUR fighter's name? ", player$

    COLOR YELLOW#, BLACK#
    PRINT "\n PUNCH TYPES:"
    COLOR WHITE#, BLACK#
    PRINT "   (1) FULL SWING - High damage, easy to miss"
    PRINT "   (2) HOOK       - Good damage, balanced"
    PRINT "   (3) UPPERCUT   - Medium damage, tricky"
    PRINT "   (4) JAB        - Quick, lower damage"

    COLOR LGREEN#, BLACK#
    PRINT "\n Your fighter's BEST punch gives +2 bonus damage."
    PRINT " What is "; player$; "'s BEST punch (1-4)? ";
    INPUT playerBest$

    COLOR LRED#, BLACK#
    PRINT " Your fighter's VULNERABILITY means opponent hits harder."
    PRINT " What is "; player$; "'s VULNERABILITY (1-4)? ";
    INPUT playerWeak$

    [genOpponent]
    opponentBest$ = INT(RND(4)) + 1
    opponentWeak$ = INT(RND(4)) + 1
    IF opponentBest$ = opponentWeak$ THEN GOTO [genOpponent]

    COLOR WHITE#, BLACK#
    PRINT "\n Press ENTER when ready to fight...";
    INPUT "", temp$
RETURN

' ============================================
' MAIN GAME LOOP - 3 Rounds
' ============================================
[mainGame]
    FOR round$ = 1 TO 3
        IF playerWins$ >= 2 THEN GOTO [playerChamp]
        IF opponentWins$ >= 2 THEN GOTO [opponentChamp]
        GOSUB [playRound]
    NEXT round$

    IF playerWins$ >= 2 THEN GOTO [playerChamp]
    IF opponentWins$ >= 2 THEN GOTO [opponentChamp]
RETURN

' ============================================
' SINGLE ROUND
' ============================================
[playRound]
    playerDamage$   = 0
    opponentDamage$ = 0

    CLS
    COLOR YELLOW#, BLACK#
    PRINT "\n"; REPEAT("=", 50)
    PRINT "              ROUND "; round$; " - FIGHT!"
    PRINT REPEAT("=", 50)

    COLOR LGRAY#, BLACK#
    PRINT " Score: "; player$; " "; playerWins$; " - "; opponentWins$; " "; opponent$
    PRINT REPEAT("-", 50)

    FOR exchange$ = 1 TO 7
        GOSUB [showDamageMeters]

        IF playerDamage$ > 35 THEN GOTO [playerKO]
        IF opponentDamage$ > 35 THEN GOTO [opponentKO]

        attacker$ = INT(RND(10)) + 1

        IF attacker$ > 5 THEN
            GOSUB [opponentAttacks]
        ELSE
            GOSUB [playerAttacks]
        END IF

        SLEEP 800
    NEXT exchange$

    PRINT "\n";
    COLOR WHITE#, BLACK#
    PRINT REPEAT("-", 50)

    IF playerDamage$ > opponentDamage$ THEN
        COLOR LGREEN#, BLACK#
        PRINT " >>> "; player$; " WINS ROUND "; round$; "! <<<"
        playerWins$ = playerWins$ + 1
    ELSE
        COLOR LRED#, BLACK#
        PRINT " >>> "; opponent$; " WINS ROUND "; round$; "! <<<"
        opponentWins$ = opponentWins$ + 1
    END IF

    COLOR WHITE#, BLACK#
    PRINT "\n Press ENTER for next round...";
    INPUT "", temp$
RETURN

' ============================================
' DAMAGE METERS
' ============================================
[showDamageMeters]
    PRINT ""
    COLOR WHITE#, BLACK#

    PRINT " "; LEFT(player$ + REPEAT(" ", 12), 12); " [";
    bars$ = INT(playerDamage$ / 3)
    IF bars$ > 12 THEN bars$ = 12
    COLOR LGREEN#, BLACK#
    PRINT REPEAT("#", bars$);
    COLOR LGRAY#, BLACK#
    PRINT REPEAT(".", 12 - bars$);
    COLOR WHITE#, BLACK#
    PRINT "] "; playerDamage$

    PRINT " "; LEFT(opponent$ + REPEAT(" ", 12), 12); " [";
    bars$ = INT(opponentDamage$ / 3)
    IF bars$ > 12 THEN bars$ = 12
    COLOR LRED#, BLACK#
    PRINT REPEAT("#", bars$);
    COLOR LGRAY#, BLACK#
    PRINT REPEAT(".", 12 - bars$);
    COLOR WHITE#, BLACK#
    PRINT "] "; opponentDamage$
    PRINT ""
RETURN

' ============================================
' PLAYER ATTACKS
' ============================================
[playerAttacks]
    COLOR CYAN#, BLACK#
    PRINT " Your turn! ";
    INPUT "Punch (1-4): ", punch$

    IF punch$ = playerBest$ THEN
        playerDamage$ = playerDamage$ + 2
    END IF

    IF punch$ = 1 THEN GOTO [playerFullSwing]
    IF punch$ = 2 THEN GOTO [playerHook]
    IF punch$ = 3 THEN GOTO [playerUppercut]
    GOTO [playerJab]

[playerFullSwing]
    COLOR WHITE#, BLACK#
    PRINT " "; player$; " winds up a FULL SWING... ";
    IF opponentWeak$ = 1 THEN GOTO [fullSwingHit]
    chance$ = INT(RND(30)) + 1
    IF chance$ < 10 THEN GOTO [fullSwingHit]
    COLOR LGRAY#, BLACK#
    PRINT "MISSES!"
    RETURN

    [fullSwingHit]
    COLOR LGREEN#, BLACK#
    PRINT "CONNECTS! POW!!!"
    playerDamage$ = playerDamage$ + 15
RETURN

[playerHook]
    COLOR WHITE#, BLACK#
    PRINT " "; player$; " throws a HOOK... ";
    IF opponentWeak$ = 2 THEN GOTO [hookHit]
    chance$ = INT(RND(2)) + 1
    IF chance$ = 1 THEN
        COLOR LGRAY#, BLACK#
        PRINT "BLOCKED!"
        RETURN
    END IF

    [hookHit]
    COLOR LGREEN#, BLACK#
    PRINT "CONNECTS!"
    playerDamage$ = playerDamage$ + 7
RETURN

[playerUppercut]
    COLOR WHITE#, BLACK#
    PRINT " "; player$; " tries an UPPERCUT... ";
    IF opponentWeak$ = 3 THEN GOTO [uppercutHit]
    chance$ = INT(RND(100)) + 1
    IF chance$ > 50 THEN
        COLOR LGRAY#, BLACK#
        PRINT "BLOCKED! (Lucky block!)"
        RETURN
    END IF

    [uppercutHit]
    COLOR LGREEN#, BLACK#
    PRINT "CONNECTS!"
    playerDamage$ = playerDamage$ + 4
RETURN

[playerJab]
    COLOR WHITE#, BLACK#
    PRINT " "; player$; " JABS at "; opponent$; "'s head... ";
    IF opponentWeak$ = 4 THEN GOTO [jabHit]
    chance$ = INT(RND(8)) + 1
    IF chance$ < 4 THEN
        COLOR LGRAY#, BLACK#
        PRINT "BLOCKED!"
        RETURN
    END IF

    [jabHit]
    COLOR LGREEN#, BLACK#
    PRINT "HIT!"
    playerDamage$ = playerDamage$ + 3
RETURN

' ============================================
' OPPONENT ATTACKS
' ============================================
[opponentAttacks]
    oppPunch$ = INT(RND(4)) + 1

    IF oppPunch$ = opponentBest$ THEN
        opponentDamage$ = opponentDamage$ + 2
    END IF

    IF oppPunch$ = 1 THEN GOTO [oppFullSwing]
    IF oppPunch$ = 2 THEN GOTO [oppHook]
    IF oppPunch$ = 3 THEN GOTO [oppUppercut]
    GOTO [oppJab]

[oppFullSwing]
    COLOR MAGENTA#, BLACK#
    PRINT " "; opponent$; " takes a FULL SWING... ";
    IF playerWeak$ = 1 THEN GOTO [oppFullSwingHit]
    chance$ = INT(RND(60)) + 1
    IF chance$ < 30 THEN GOTO [oppFullSwingHit]
    COLOR LGRAY#, BLACK#
    PRINT "BLOCKED!"
    RETURN

    [oppFullSwingHit]
    COLOR LRED#, BLACK#
    PRINT "POW! Right in the face!"
    opponentDamage$ = opponentDamage$ + 15
RETURN

[oppHook]
    COLOR MAGENTA#, BLACK#
    PRINT " "; opponent$; " gets you in the JAW with a HOOK!";
    COLOR LRED#, BLACK#
    PRINT " OUCH!"
    opponentDamage$ = opponentDamage$ + 7
    PRINT "    ...AND AGAIN!"
    opponentDamage$ = opponentDamage$ + 5
RETURN

[oppUppercut]
    COLOR MAGENTA#, BLACK#
    PRINT " "; player$; " is attacked by an UPPERCUT... ";
    IF playerWeak$ = 3 THEN GOTO [oppUppercutHit]
    chance$ = INT(RND(200)) + 1
    IF chance$ > 75 THEN
        COLOR LGREEN#, BLACK#
        PRINT "BLOCKED! Counter-HOOK!"
        playerDamage$ = playerDamage$ + 5
        RETURN
    END IF

    [oppUppercutHit]
    COLOR LRED#, BLACK#
    PRINT "CONNECTS!"
    opponentDamage$ = opponentDamage$ + 8
RETURN

[oppJab]
    COLOR MAGENTA#, BLACK#
    PRINT " "; opponent$; " JABS... ";
    IF playerWeak$ = 4 THEN GOTO [oppJabHit]
    chance$ = INT(RND(7)) + 1
    IF chance$ > 4 THEN
        COLOR LGRAY#, BLACK#
        PRINT "BLOCKED!"
        RETURN
    END IF

    [oppJabHit]
    COLOR LRED#, BLACK#
    PRINT "BLOOD SPILLS!!!"
    opponentDamage$ = opponentDamage$ + 5
RETURN

' ============================================
' K.O. AND VICTORY SCREENS
' ============================================
[playerKO]
    COLOR LRED#, BLACK#
    PRINT "\n\n"; REPEAT("*", 50)
    PRINT "  "; opponent$; " IS KNOCKED COLD!"
    PRINT REPEAT("*", 50)
    COLOR LGREEN#, BLACK#
    PRINT "\n        *** "; player$; " IS THE WINNER! ***"
    PRINT "             K.O. VICTORY!"
    GOTO [gameEnd]

[opponentKO]
    COLOR LRED#, BLACK#
    PRINT "\n\n"; REPEAT("*", 50)
    PRINT "  "; player$; " IS KNOCKED COLD!"
    PRINT REPEAT("*", 50)
    COLOR MAGENTA#, BLACK#
    PRINT "\n        *** "; opponent$; " WINS BY K.O.! ***"
    GOTO [gameEnd]

[playerChamp]
    COLOR YELLOW#, BLACK#
    PRINT "\n\n"; REPEAT("*", 50)
    COLOR LGREEN#, BLACK#
    PRINT "   "; player$; " WINS THE MATCH!"
    PRINT "      "; playerWins$; " - "; opponentWins$
    COLOR YELLOW#, BLACK#
    PRINT REPEAT("*", 50)
    PRINT "\n       *** CHAMPION! ***"
    GOTO [gameEnd]

[opponentChamp]
    COLOR YELLOW#, BLACK#
    PRINT "\n\n"; REPEAT("*", 50)
    COLOR LRED#, BLACK#
    PRINT "   "; opponent$; " AMAZINGLY WINS!"
    PRINT "      "; opponentWins$; " - "; playerWins$
    COLOR YELLOW#, BLACK#
    PRINT REPEAT("*", 50)
    GOTO [gameEnd]

[gameEnd]
    COLOR WHITE#, BLACK#
    PRINT "\n\n And now goodbye from the Olympic Arena!\n"

    INPUT "\n Play again? (Y/N): ", again$
    IF UCASE(LEFT(again$, 1)) = "Y" THEN
        playerWins$   = 0
        opponentWins$ = 0
        GOTO [setup]
    END IF
RETURN

' ============================================
' HELPER: Get punch name
' ============================================
[getPunchName]
    IF punchNum$ = 1 THEN
        punchName$ = "FULL SWING"
    ELSEIF punchNum$ = 2 THEN
        punchName$ = "HOOK"
    ELSEIF punchNum$ = 3 THEN
        punchName$ = "UPPERCUT"
    ELSE
        punchName$ = "JAB"
    END IF
RETURN
