' ============================================
' ACEY DUCEY - BazzBasic Edition
' Original: Creative Computing
' This: https://github.com/EkBass/BazzBasic
' Updated for BazzBasic v1.1
' ============================================

' ── 1. CONSTANTS ────────────────────────────
LET BLACK#    = 0
LET RED#      = 4
LET DGRAY#    = 8
LET LGRAY#    = 7
LET LGREEN#   = 10
LET LCYAN#    = 11
LET LRED#     = 12
LET YELLOW#   = 14
LET WHITE#    = 15

' ── 2. FUNCTIONS ────────────────────────────
DEF FN CardName$(v$)
    IF v$ = 11 THEN RETURN "J"
    IF v$ = 12 THEN RETURN "Q"
    IF v$ = 13 THEN RETURN "K"
    IF v$ = 14 THEN RETURN "A"
    RETURN STR(v$)
END DEF

' ── 3. INIT ─────────────────────────────────
DIM deck$
GOSUB [sub:initGame]

' ── 4. MAIN LOOP ────────────────────────────
[mainLoop]
    ' Check money
    IF money$ <= 0 THEN GOTO [sub:broke]

    ' Need 3 cards; reshuffle when fewer than 3 remain
    IF deckPos$ > 49 THEN
        PRINT "\nDeck run out. Shuffling new..."
        GOSUB [sub:shuffleDeck]
    END IF

    COLOR WHITE#, BLACK#
    PRINT "\n-----------------------------"
    PRINT "Money: $"; money$
    PRINT "-----------------------------"

    ' Draw 2 cards
    LET card1$ = deck$(deckPos$)
    deckPos$ = deckPos$ + 1
    LET card2$ = deck$(deckPos$)
    deckPos$ = deckPos$ + 1

    ' Smaller first
    IF card1$ > card2$ THEN
        LET temp$ = card1$
        card1$ = card2$
        card2$ = temp$
    END IF

    COLOR YELLOW#, BLACK#
    PRINT "\nCards: "; FN CardName$(card1$); " and "; FN CardName$(card2$)

    ' Same card - redeal
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

    ' Draw third card
    LET card3$ = deck$(deckPos$)
    deckPos$ = deckPos$ + 1

    COLOR LCYAN#, BLACK#
    PRINT "Third card: "; FN CardName$(card3$)

    ' Win condition - strictly between the two cards
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

' ── 5. SUBROUTINES ──────────────────────────
[sub:broke]
    COLOR RED#, BLACK#
    PRINT "\n================================"
    PRINT "  OUT OF MONEY! GAME OVER!"
    PRINT "================================"

    COLOR WHITE#, BLACK#
    PRINT "\nNew game? (y/n): "
	
	LET rep$ = WAITKEY(KEY_Y#, KEY_N#)
    IF  rep$ = KEY_Y# THEN
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

    ' Init variables here to avoid lookup penalty in the main loop
    LET money$ = 100
    LET deckPos$ = 0
    LET card1$ = 0
    LET card2$ = 0
    LET card3$ = 0
    LET bet$ = 0
    LET temp$ = 0
    LET again$ = ""

    GOSUB [sub:shuffleDeck]
RETURN

[sub:shuffleDeck]
    ' Build deck (4 suits x 13 values = 52 cards)
    LET idx$ = 0
    FOR suit$ = 0 TO 3
        FOR value$ = 2 TO 14
            deck$(idx$) = value$
            idx$ = idx$ + 1
        NEXT
    NEXT

    ' Fisher-Yates shuffle
    FOR i$ = 51 TO 1 STEP -1
        LET j$ = RND(i$ + 1)
        LET temp$ = deck$(i$)
        deck$(i$) = deck$(j$)
        deck$(j$) = temp$
    NEXT

    deckPos$ = 0
    COLOR DGRAY#, BLACK#
    PRINT "Deck shuffled."
RETURN
