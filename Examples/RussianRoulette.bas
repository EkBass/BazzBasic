' Russian Roulette 
' CREATIVE COMPUTING
' MORRISTOWN, NEW JERSEY
'
' BazzBasic version by https://github.com/EkBass/BazzBasic

[start]
    COLOR 11, 0
    CLS
    
    PRINT " "; REPEAT("*", 21)
    PRINT " *"; REPEAT(" ", 19); "*"
    PRINT " *  RUSSIAN ROULETTE *"
    PRINT " *"; REPEAT(" ", 19); "*"
    PRINT " "; REPEAT("*", 21)
    PRINT "\n CREATIVE COMPUTING\n MORRISTOWN, NEW JERSEY"
    
    COLOR 15, 0

[menu]
    LET a$ = 0 : LET chamber$
    
    WHILE a$ <> 2
        chamber$ = RND(6)
        PRINT " HERE IS A REVOLVER."
        PRINT " Choose '1' to spin the chamber and pull the trigger."
        PRINT " Choose '2', to be a loser who gives up."
        INPUT "\n Your choice?", a$
        IF a$ = 2 THEN
            PRINT " Oh, such a loser!"
            GOTO [end]
        ELSEIF a$ = 1 THEN
            PRINT " Thats my boy!"
            GOTO [shoot]
        ENDIF
        PRINT "1 or 2 you chicken.\n\n"
    WEND
    END

[shoot]
    LET shot$ = RND(6)
    IF shot$ = chamber$ THEN
        COLOR 4, 0
        PRINT "\n *** BANG!!! ***"
        COLOR 15, 0
        PRINT " You're dead!"
        PRINT " Condolences will be sent to your relatives."
        PRINT "\nNext victim please..."
        SLEEP 3000
        GOTO [start]
    ENDIF
    
    PRINT " *** YOU WIN!!!!!"
    PRINT " Maybe let someone else blow their brains out?"
    SLEEP 3000
    GOTO [start]

[end]
    PRINT "\n Bye..."
    END