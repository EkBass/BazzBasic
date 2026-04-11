' ============================================
' ACEY DUCEY - BazzBasic Edition
' Original: Creative Computing
' https://github.com/EkBass/BazzBasic
' ============================================

DEF FN CardName$(v$)
    IF v$ = 11 THEN RETURN "J"
    IF v$ = 12 THEN RETURN "Q"
    IF v$ = 13 THEN RETURN "K"
    IF v$ = 14 THEN RETURN "A"
    RETURN STR(v$)
END DEF

' ── INIT ────────────────────────────────────
[inits]
    LET BLACK#  = 0
    LET RED#    = 4
    LET DGRAY#  = 8
    LET LGRAY#  = 7
    LET LGREEN# = 10
    LET LCYAN#  = 11
    LET LRED#   = 12
    LET YELLOW# = 14
    LET WHITE#  = 15

    DIM deck$

    LET money$   = 0
    LET deckPos$ = 0
    LET card1$   = 0
    LET card2$   = 0
    LET card3$   = 0
    LET bet$     = 0
    LET temp$    = 0
    LET key$     = 0
    LET idx$     = 0
    LET j$       = 0

    GOSUB [sub:initGame]

' ── MAIN LOOP ───────────────────────────────
[mainLoop]
    IF money$ <= 0 THEN GOTO [sub:broke]

    IF deckPos$ > 49 THEN
        PRINT "\nDeck run out. Shuffling new..."
        GOSUB [sub:shuffleDeck]
    END IF

    COLOR WHITE#, BLACK#
    PRINT "\n-----------------------------"
    PRINT "Money: $"; money$
    PRINT "-----------------------------"

    card1$ = deck$(deckPos$)
    deckPos$ = deckPos$ + 1
    card2$ = deck$(deckPos$)
    deckPos$ = deckPos$ + 1

    IF card1$ > card2$ THEN
        temp$  = card1$
        card1$ = card2$
        card2$ = temp$
    END IF

    COLOR YELLOW#, BLACK#
    PRINT "\nCards: "; FN CardName$(card1$); " and "; FN CardName$(card2$)

    IF card1$ = card2$ THEN
        COLOR LGRAY#, BLACK#
        PRINT "Same card, new deal!"
        GOTO [mainLoop]
    END IF

    COLOR WHITE#, BLACK#
    INPUT "\nYour bet (0 = pass): ", bet$

    IF bet$ = 0 THEN
        COLOR DGRAY#, BLACK#
        PRINT "Chicken! New deal..."
        GOTO [mainLoop]
    END IF

    IF NOT BETWEEN(bet$, 1, money$) THEN
        COLOR LRED#, BLACK#
        PRINT "Bet must be between 1 and $"; money$
        GOTO [mainLoop]
    END IF

    card3$ = deck$(deckPos$)
    deckPos$ = deckPos$ + 1

    COLOR LCYAN#, BLACK#
    PRINT "Third card: "; FN CardName$(card3$)

    IF card3$ > card1$ AND card3$ < card2$ THEN
        COLOR LGREEN#, BLACK#
        PRINT "*** You win $"; bet$; "! ***"
        money$ = money$ + bet$
    ELSE
        COLOR LRED#, BLACK#
        PRINT "You lost $"; bet$
        money$ = money$ - bet$
    END IF

GOTO [mainLoop]

' ── SUBROUTINES ─────────────────────────────
[sub:broke]
    COLOR RED#, BLACK#
    PRINT "\n================================"
    PRINT "  OUT OF MONEY! GAME OVER!"
    PRINT "================================"

    COLOR WHITE#, BLACK#
    PRINT "\nNew game? (y/n): "
    key$ = WAITKEY(KEY_Y#, KEY_N#)
    IF key$ = KEY_Y# THEN
        money$ = 100
        GOSUB [sub:shuffleDeck]
        GOTO [mainLoop]
    END IF

    PRINT "\nCheers!"
END

[sub:initGame]
    COLOR YELLOW#, BLACK#
    CLS
    PRINT " "; REPEAT("*", 28)
    PRINT " *  ACEY DUCEY              *"
    PRINT " *  BazzBasic Edition       *"
    PRINT " "; REPEAT("*", 28)

    COLOR LGRAY#, BLACK#
    PRINT "\n Bet whether the third card falls between the first two."
    PRINT "\n Ace is high (14)."

    money$   = 100
    deckPos$ = 0
    card1$   = 0
    card2$   = 0
    card3$   = 0
    bet$     = 0
    temp$    = 0

    GOSUB [sub:shuffleDeck]
RETURN

[sub:shuffleDeck]
    idx$ = 0
    FOR suit$ = 0 TO 3
        FOR value$ = 2 TO 14
            deck$(idx$) = value$
            idx$ = idx$ + 1
        NEXT
    NEXT

    FOR i$ = 51 TO 1 STEP -1
        j$        = RND(i$ + 1)
        temp$     = deck$(i$)
        deck$(i$) = deck$(j$)
        deck$(j$) = temp$
    NEXT

    deckPos$ = 0
    COLOR DGRAY#, BLACK#
    PRINT "Deck shuffled."
RETURN
