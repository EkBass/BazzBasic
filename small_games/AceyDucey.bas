' ============================================
' ACEY DUCEY - BazzBasic Edition
' Original: Creative Computing
' This: https://github.com/EkBass/BazzBasic
' ============================================


DEF FN cardName$(v$)
    IF v$ = 11 THEN RETURN "J"
    IF v$ = 12 THEN RETURN "Q"
    IF v$ = 13 THEN RETURN "K"
    IF v$ = 14 THEN RETURN "A"
    RETURN STR(v$)
END DEF

LET money$ = 100
LET deckPos$ = 0
DIM deck$

GOSUB [initGame]

[mainLoop]
    ' Check money
    IF money$ <= 0 THEN GOTO [broke]
    
    ' Check deck. Min. 3 cards
    IF deckPos$ > 49 THEN
        PRINT "\nDeck run out. Shuffling new..."
        GOSUB [shuffleDeck]
    END IF
    
    COLOR 15, 0
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
    
    COLOR 14, 0
    PRINT "\nCards: "; FN cardName$(card1$); " and "; FN cardName$(card2$)
    
    ' Sama kortti = uusi jako
    IF card1$ = card2$ THEN
        COLOR 7, 0
        PRINT "Same card, new deal!"
        GOTO [mainLoop]
    END IF
    
    COLOR 15, 0
    INPUT "\nYour bet (0 = pass): ", bet$
    
    IF bet$ = 0 THEN
        COLOR 8, 0
        PRINT "Chicken! New deal..."
        GOTO [mainLoop]
    END IF
    
    IF bet$ > money$ THEN
        COLOR 12, 0
        PRINT "Not enough money. You have only $"; money$
        GOTO [mainLoop]
    END IF
    
    IF bet$ < 0 THEN
        PRINT "Value of a card please."
        GOTO [mainLoop]
    END IF
    
    ' Draw third
    LET card3$ = deck$(deckPos$)
    deckPos$ = deckPos$ + 1
    
    COLOR 11, 0
    PRINT "Third card: "; FN cardName$(card3$)
    
    ' Win
    IF card3$ > card1$ AND card3$ < card2$ THEN
        COLOR 10, 0
        PRINT "*** You win $"; bet$; "! ***"
        money$ = money$ + bet$
    ELSE
        COLOR 12, 0
        PRINT "You lost $"; bet$
        money$ = money$ - bet$
    END IF
    
    GOTO [mainLoop]

[broke]
    COLOR 4, 0
    PRINT "\n================================"
    PRINT "  OUT OF MONEY! GAME OVER!"
    PRINT "================================"
    
    COLOR 15, 0
    INPUT "\nNew game? (y/n): ", again$
    IF UCASE(LEFT(again$, 1)) = "Y" THEN
        money$ = 100
        GOSUB [shuffleDeck]
        GOTO [mainLoop]
    END IF
    
    PRINT "\nCheers!"
    END

' ============================================
' INIT
' ============================================
[initGame]
    COLOR 14, 0
    CLS
    PRINT " "; REPEAT("*", 28)
    PRINT " *  ACEY DUCEY              *"
    PRINT " *  BazzBasic Edition       *"
    PRINT " "; REPEAT("*", 28)
    
    COLOR 7, 0
    PRINT "\n You bet does third card have a value between two first cards"
    PRINT "\n Ace is 14."
    
    GOSUB [shuffleDeck]
    RETURN

' ============================================
' Fisher-Yates
' ============================================
[shuffleDeck]
    LET idx$ = 0
    FOR suit$ = 0 TO 3
        FOR value$ = 2 TO 14
            deck$(idx$) = value$
            idx$ = idx$ + 1
        NEXT
    NEXT
    
    FOR i$ = 51 TO 1 STEP -1
        LET j$ = RND(i$ + 1)
        LET temp$ = deck$(i$)
        deck$(i$) = deck$(j$)
        deck$(j$) = temp$
    NEXT
    
    deckPos$ = 0
    COLOR 8, 0
    PRINT "Deck shuffled."
    RETURN