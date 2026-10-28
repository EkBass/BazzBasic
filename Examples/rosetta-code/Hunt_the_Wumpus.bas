' =================================================
' https://rosettacode.org/wiki/Hunt_the_Wumpus
' Bit adjusted version of original by: https://github.com/Mkratzen
' BazzBasic: https://ekbass.github.io/BazzBasic/
' =================================================

' TRUE if room$ is one of the three given rooms
DEF FN Near$(room$, a$, b$, c$)
    IF room$ = a$ OR room$ = b$ OR room$ = c$ THEN RETURN TRUE
    RETURN FALSE
END DEF

[inits]
    ' Dodecahedron: three tunnels from each of the 20 rooms
    LET MAP# = "2,5,8,1,3,10,2,4,12,3,5,14,4,1,6,5,7,15,6,8,17,7,9,1,8,10,18,9,11,2,10,12,19,11,13,3,12,14,20,13,15,4,14,6,16,17,20,15,16,18,7,17,19,9,18,20,11,19,16,13"
    LET ARROWS# = 5

    DIM parts$, tunnel$
    LET n$ = SPLIT(parts$, MAP#, ",")
    FOR r$ = 1 TO 20
        FOR c$ = 1 TO 3
            tunnel$(r$, c$) = VAL(parts$((r$ - 1) * 3 + c$ - 1))
        NEXT
    NEXT

    LET player$, wumpus$, bat1$, bat2$, pit1$, pit2$
    LET t1$, t2$, t3$
    LET choice$, target$
    LET arrows$ = ARROWS#

    ' Everything starts in a different room
    player$ = RND(20) + 1
    wumpus$ = player$
    WHILE wumpus$ = player$
        wumpus$ = RND(20) + 1
    WEND
    bat1$ = player$
    WHILE bat1$ = player$ OR bat1$ = wumpus$
        bat1$ = RND(20) + 1
    WEND
    bat2$ = player$
    WHILE bat2$ = player$ OR bat2$ = wumpus$ OR bat2$ = bat1$
        bat2$ = RND(20) + 1
    WEND
    pit1$ = player$
    WHILE pit1$ = player$ OR pit1$ = wumpus$ OR pit1$ = bat1$ OR pit1$ = bat2$
        pit1$ = RND(20) + 1
    WEND
    pit2$ = player$
    WHILE pit2$ = player$ OR pit2$ = wumpus$ OR pit2$ = bat1$ OR pit2$ = bat2$ OR pit2$ = pit1$
        pit2$ = RND(20) + 1
    WEND

[main]
    IF player$ = wumpus$ THEN
        PRINT "You have been eaten by the Wumpus!"
        GOTO [defeat]
    END IF
    IF player$ = pit1$ OR player$ = pit2$ THEN
        PRINT "Aaaaaaaaaaa! You have fallen into a bottomless pit."
        GOTO [defeat]
    END IF
    IF player$ = bat1$ OR player$ = bat2$ THEN GOTO [bats]

[look]
    t1$ = tunnel$(player$, 1)
    t2$ = tunnel$(player$, 2)
    t3$ = tunnel$(player$, 3)

    PRINT
    PRINT "You are in room "; player$; ". Tunnels lead to rooms "; t1$; ", "; t2$; " and "; t3$; "."
    IF FN Near$(wumpus$, t1$, t2$, t3$) THEN PRINT "You smell something terrible nearby."
    IF FN Near$(bat1$, t1$, t2$, t3$) OR FN Near$(bat2$, t1$, t2$, t3$) THEN PRINT "You hear a rustling."
    IF FN Near$(pit1$, t1$, t2$, t3$) OR FN Near$(pit2$, t1$, t2$, t3$) THEN PRINT "You feel a cold wind blowing from a nearby cavern."
    PRINT "You have "; arrows$; " arrows left."

    INPUT "Room number to move, or A to shoot: ", choice$
    IF UCASE(choice$) = "A" THEN GOTO [shoot]

    target$ = VAL(choice$)
    IF FN Near$(target$, t1$, t2$, t3$) THEN
        player$ = target$
        GOTO [main]
    END IF
    PRINT "You can't get there from here."
    GOTO [look]

[shoot]
    INPUT "Which room would you like to shoot into? ", choice$
    target$ = VAL(choice$)

    IF target$ = player$ THEN
        PRINT "You shot yourself. Why would you want to do such a thing?"
        GOTO [defeat]
    END IF
    IF FN Near$(target$, t1$, t2$, t3$) = FALSE THEN
        PRINT "You can't shoot into that room from here."
        GOTO [look]
    END IF
    IF target$ = wumpus$ THEN GOTO [victory]

    arrows$ -= 1
    PRINT "You missed. The Wumpus awakes!"
    IF RND(0) < 0.75 THEN
        PRINT "He moves to a nearby cavern."
        wumpus$ = tunnel$(wumpus$, RND(3) + 1)
    ELSE
        PRINT "He goes back to sleep."
    END IF

    IF arrows$ = 0 THEN
        PRINT "You have run out of arrows!"
        GOTO [defeat]
    END IF
    GOTO [main]

[bats]
    PRINT "A bat has carried you into another empty room."
    player$ = RND(20) + 1
    WHILE player$ = wumpus$ OR player$ = bat1$ OR player$ = bat2$ OR player$ = pit1$ OR player$ = pit2$
        player$ = RND(20) + 1
    WEND
    GOTO [look]

[defeat]
    PRINT "You lose! Better luck next time."
END

[victory]
    PRINT "You have slain the Wumpus!"
    SLEEP 250
    PRINT "You have won!"
END
