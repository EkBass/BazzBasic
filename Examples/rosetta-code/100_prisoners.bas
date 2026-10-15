' ============================================
' https://rosettacode.org/wiki/100_prisoners
' BazzBasic: https://github.com/EkBass/BazzBasic
' Simulate random vs. optimal (cycle-following) drawer strategies
' ============================================

[inits]
    LET GAMES#     = 10000
    LET PRISONERS# = 100
    LET MAX_OPENS# = 50

    DIM drawer$             ' drawer$(n) = card inside drawer n
    DIM order$              ' permutation of drawer numbers, used by random strategy

    LET randomWins$  = 0
    LET optimalWins$ = 0
    LET allFound$    = FALSE
    LET found$       = FALSE
    LET p$           = 0
    LET opens$       = 0
    LET card$        = 0
    LET pick$        = 0
    LET j$           = 0
    LET tmp$         = 0
    LET pctRandom$   = 0
    LET pctOptimal$  = 0

[main]
    FOR i$ = 1 TO PRISONERS#
        drawer$(i$) = i$
        order$(i$)  = i$
    NEXT

    PRINT FSTRING("Playing {{-GAMES#-}} games with each strategy...")

    FOR game$ = 1 TO GAMES#
        GOSUB [sub:shuffleDrawers]
        GOSUB [sub:playRandom]
        randomWins$ += allFound$
        GOSUB [sub:playOptimal]
        optimalWins$ += allFound$
    NEXT

    pctRandom$  = ROUND(randomWins$  * 10000 / GAMES#) / 100
    pctOptimal$ = ROUND(optimalWins$ * 10000 / GAMES#) / 100

    PRINT
    PRINT FSTRING("Random strategy : {{-randomWins$-}} wins, {{-pctRandom$-}} %")
    PRINT FSTRING("Optimal strategy: {{-optimalWins$-}} wins, {{-pctOptimal$-}} %")
END

' Fisher-Yates shuffle of the cards into the drawers
[sub:shuffleDrawers]
    FOR i$ = PRISONERS# TO 2 STEP -1
        j$ = RND(i$) + 1
        tmp$ = drawer$(i$)
        drawer$(i$) = drawer$(j$)
        drawer$(j$) = tmp$
    NEXT
RETURN

' Each prisoner opens 50 distinct drawers at random.
' A partial Fisher-Yates over order$ gives the 50 distinct picks;
' order$ always stays a permutation, so it needs no reset.
[sub:playRandom]
    allFound$ = TRUE
    p$ = 1
    WHILE allFound$ AND p$ <= PRISONERS#
        found$ = FALSE
        opens$ = 0
        WHILE NOT found$ AND opens$ < MAX_OPENS#
            opens$ += 1
            j$ = opens$ + RND(PRISONERS# - opens$ + 1)
            tmp$ = order$(opens$)
            order$(opens$) = order$(j$)
            order$(j$) = tmp$
            pick$ = order$(opens$)
            IF drawer$(pick$) = p$ THEN found$ = TRUE
        WEND
        IF NOT found$ THEN allFound$ = FALSE
        p$ += 1
    WEND
RETURN

' Each prisoner opens his own drawer first, then the drawer
' numbered by the card he just saw, until found or 50 opened.
[sub:playOptimal]
    allFound$ = TRUE
    p$ = 1
    WHILE allFound$ AND p$ <= PRISONERS#
        card$ = drawer$(p$)
        opens$ = 1
        WHILE card$ <> p$ AND opens$ < MAX_OPENS#
            card$ = drawer$(card$)
            opens$ += 1
        WEND
        IF card$ <> p$ THEN allFound$ = FALSE
        p$ += 1
    WEND
RETURN

' Output:
' Playing 5000 games with each strategy...
' 
' Random strategy : 0 wins, 0 %
' Optimal strategy: 1577 wins, 31.54 %