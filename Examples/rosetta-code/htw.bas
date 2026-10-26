' =================================================
' https://rosettacode.org/wiki/Hunt_the_Wumpus
' BazzBasic: https://ekbass.github.io/BazzBasic/
' =================================================

[init]
LET player$ = RND(20)+1
LET wumpu$ = RND(20)+1
LET bat1$ = RND(20)+1
LET bat2$ = RND(20)+1
LET pit1$ = RND(20)+1
LET pit2$ = RND(20)+1
LET arrow$ = 5
WHILE wumpu$ = player$
   LET wumpu$ = RND(20)+1
WEND
WHILE bat1$ = player$ OR bat1$ = wumpu$
   LET bat1$ = RND(20)+1
WEND
WHILE bat2$ = player$ OR bat2$ = bat1$ OR bat2$ = wumpu$
    LET bat2$ = RND(20)+1
WEND
WHILE pit1$ = player$ OR pit1$ = bat1$ OR pit1$ = bat2$ OR pit1$ = wumpu$
    LET pit1$ = RND(20)+1
WEND
WHILE pit2$ = player$ OR pit2$ = bat1$ OR pit2$ = bat2$ OR pit2$ = wumpu$ OR pit2$ = pit1$
    LET pit2$ = RND(20)+1
WEND

' I feel like theres gotta be a better way to do this, yeah?
' also, this array lines up more with [this](https://en.wikipedia.org/wiki/Hunt_the_Wumpus#/media/File:Hunt_the_Wumpus_map.svg) map of the game.
DIM tunnel$
tunnel$(1, 1) = 2
tunnel$(1, 2) = 5
tunnel$(1, 3) = 8
tunnel$(2, 1) = 1
tunnel$(2, 2) = 3
tunnel$(2, 3) = 10
tunnel$(3, 1) = 2
tunnel$(3, 2) = 4
tunnel$(3, 3) = 12
tunnel$(4, 1) = 3
tunnel$(4, 2) = 5
tunnel$(4, 3) = 14
tunnel$(5, 1) = 4
tunnel$(5, 2) = 1
tunnel$(5, 3) = 6
tunnel$(6, 1) = 5
tunnel$(6, 2) = 7
tunnel$(6, 3) = 15
tunnel$(7, 1) = 6
tunnel$(7, 2) = 8
tunnel$(7, 3) = 17
tunnel$(8, 1) = 7
tunnel$(8, 2) = 9
tunnel$(8, 3) = 1
tunnel$(9, 1) = 8
tunnel$(9, 2) = 10
tunnel$(9, 3) = 18
tunnel$(10, 1) = 9
tunnel$(10, 2) = 11
tunnel$(10, 3) = 2
tunnel$(11, 1) = 10
tunnel$(11, 2) = 12
tunnel$(11, 3) = 19
tunnel$(12, 1) = 11
tunnel$(12, 2) = 13
tunnel$(12, 3) = 3
tunnel$(13, 1) = 12
tunnel$(13, 2) = 14
tunnel$(13, 3) = 20
tunnel$(14, 1) = 13
tunnel$(14, 2) = 15
tunnel$(14, 3) = 4
tunnel$(15, 1) = 14
tunnel$(15, 2) = 6
tunnel$(15, 3) = 16
tunnel$(16, 1) = 17
tunnel$(16, 2) = 20
tunnel$(16, 3) = 15
tunnel$(17, 1) = 16
tunnel$(17, 2) = 18
tunnel$(17, 3) = 7
tunnel$(18, 1) = 17
tunnel$(18, 2) = 19
tunnel$(18, 3) = 9
tunnel$(19, 1) = 18
tunnel$(19, 2) = 20
tunnel$(19, 3) = 11
tunnel$(20, 1) = 19
tunnel$(20, 2) = 16
tunnel$(20, 3) = 13

[main]
IF player$ = wumpu$ THEN
    PRINT "You have been eaten by the Wumpus!"
    GOTO [defeat]
END IF
IF player$ = pit1$ OR player$ = pit2$ THEN
    PRINT "Aaaaaaaaaaa! You have fallen into a bottomless pit."
    GOTO [defeat]
ENDIF
IF player$ = bat1$ OR player$ = bat2$ THEN
    PRINT "A bat has carried you into another empty room."
    GOTO [batrandom]
ENDIF
GOTO [stayinalive]

[defeat]
PRINT "You lose! Better luck next time."
END

[stayinalive]
PRINT "You are in room: "; player$; ". There are tunnels to rooms "; tunnel$(player$,1); ", "; tunnel$(player$,2); ", and "; tunnel$(player$,3); ". ";
    IF wumpu$ = tunnel$(player$,1) OR wumpu$ = tunnel$(player$,2) OR wumpu$ = tunnel$(player$,3) THEN
        PRINT "You smell something terrible nearby."
    ENDIF
    IF bat1$ = tunnel$(player$,1) OR bat1$ = tunnel$(player$,2) OR bat1$ = tunnel$(player$,3) THEN
        PRINT "You hear a rustling."
    ENDIF
    IF bat2$ = tunnel$(player$,1) OR bat2$ = tunnel$(player$,2) OR bat2$ = tunnel$(player$,3) THEN
        PRINT "You hear a rustling."
    ENDIF
    IF pit1$ = tunnel$(player$,1) OR pit1$ = tunnel$(player$,2) OR pit1$ = tunnel$(player$,3) THEN
        PRINT "You feel a cold wind blowing from a nearby cavern."
    ENDIF
    IF pit2$ = tunnel$(player$,1) OR pit2$ = tunnel$(player$,2) OR pit2$ = tunnel$(player$,3) THEN
        PRINT "You feel a cold wind blowing from a nearby cavern."
    ENDIF
    PRINT "\nYou have "; arrow$; " arrows left."
INPUT "What would you like to do? (A = shoot, or room number) \n", choice$
PRINT "You typed: "; choice$
IF choice$ = "A" OR choice$ = "a" THEN
    GOTO [arrows]
ENDIF
LET target$ = VAL(choice$)
IF target$ = tunnel$(player$,1) OR target$ = tunnel$(player$,2) OR target$ = tunnel$(player$,3) THEN
    LET player$ = target$
    PRINT "You walk to room "; player$
    GOTO [main]
ELSE
    PRINT "You can't get there from here."
    GOTO [stayinalive]
ENDIF

[arrows]
IF arrow$ > 0 THEN
    INPUT "Which room would you like to shoot into? ", target$
        IF target$ = player$ THEN
            PRINT "You shot yourself. Why would you want to do such a thing?"
            GOTO [defeat]
        ENDIF
        IF target$ = tunnel$(player$,1) OR target$ = tunnel$(player$,2) OR target$ = tunnel$(player$,3) THEN
            IF target$ = wumpu$ THEN
                GOTO [victory]
            ENDIF
            PRINT "The Wumpus awakes!"
            IF RND(0) < 0.75 THEN
                PRINT "He moves to a nearby cavern."
                LET wumpu$ = tunnel$(wumpu$, RND(3) + 1)
            ELSE
                PRINT "He goes back to sleep."
            ENDIF
            arrow$ = arrow$ - 1
            IF arrow$ = 0 THEN
                PRINT "You have run out of arrows!"
                GOTO [defeat]
            ENDIF
            GOTO [main]
        ELSE 
            PRINT "You can't shoot that room from here."
            GOTO [stayinalive]
        ENDIF
ENDIF
GOTO [stayinalive]

[batrandom]
LET player$ = RND(20)+1
    WHILE player$ = wumpu$ OR player$ = bat1$ OR player$ = bat2$ OR player$ = pit1$ OR player$ = pit2$
        LET player$ = RND(20)+1  
    WEND
GOTO [stayinalive]

[victory]
PRINT "You have slain the Wumpus!"
SLEEP 250
PRINT "You have won!"
END
