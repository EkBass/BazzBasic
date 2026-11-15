' ============================================
' https://rosettacode.org/wiki/Knuth_shuffle
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    LET DECK_SIZE# = 52
    DIM cards$
    LET pick$ = 0
    LET temp$ = 0

    ' Fill the deck with 0..51
    FOR i$ = 0 TO DECK_SIZE# - 1
        cards$(i$) = i$
    NEXT

[main]
    PRINT "before:"
    GOSUB [sub:printDeck]

    ' Walk from the last card down to the second one.
    ' RND(n) returns an integer 0..n-1, so RND(i$ + 1) gives 0..i$
    FOR i$ = DECK_SIZE# - 1 TO 1 STEP -1
        pick$ = RND(i$ + 1)
        IF pick$ <> i$ THEN
            temp$ = cards$(pick$)
            cards$(pick$) = cards$(i$)
            cards$(i$) = temp$
        END IF
    NEXT

    PRINT
    PRINT "after:"
    GOSUB [sub:printDeck]
END

[sub:printDeck]
    FOR j$ = 0 TO DECK_SIZE# - 1
        PRINT cards$(j$); " ";
    NEXT
    PRINT
RETURN

' Output (the "after" line changes on every run):
' before:
' 0 1 2 3 4 5 6 7 8 9 10 ... 49 50 51
'
' after:
' 19 4 46 25 40 28 12 35 51 21 43 23 14 2 50 18 ... 45 1