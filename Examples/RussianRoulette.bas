' ==========================================
' Russian Roulette
' Originally from CREATIVE COMPUTING
' Morristown, New Jersey
'
' BazzBasic version
' https://github.com/EkBass/BazzBasic
' ==========================================
[inits]
    LET BLACK#   = 0
    LET RED#     = 4
    LET CYAN#    = 11
    LET WHITE#   = 15
    LET choice$  = 0
    LET playing$ = TRUE
    LET alive$   = TRUE

[main]
    WHILE playing$
        GOSUB [sub:title]
        alive$ = TRUE
        WHILE playing$ AND alive$
            GOSUB [sub:menu]
        WEND
    WEND
    PRINT " Smart move.\n"
END

[sub:title]
    COLOR CYAN#, BLACK#
    CLS
    PRINT " "; REPEAT("*", 21)
    PRINT " *"; REPEAT(" ", 19); "*"
    PRINT " *  RUSSIAN ROULETTE  *"
    PRINT " *"; REPEAT(" ", 19); "*"
    PRINT " "; REPEAT("*", 21)
    PRINT "\n CREATIVE COMPUTING\n MORRISTOWN, NEW JERSEY\n"
    COLOR WHITE#, BLACK#
RETURN

[sub:menu]
    PRINT " HERE IS A REVOLVER."
    PRINT " 1 — Spin the chamber and pull the trigger."
    PRINT " 2 — Walk away.\n"
    choice$ = WAITKEY(KEY_1#, KEY_2#)
    PRINT " "; CHR(choice$); "\n"
    IF choice$ = KEY_2# THEN
        playing$ = FALSE
    ELSE
        GOSUB [sub:shoot]
    END IF
RETURN

[sub:shoot]
    IF RND(6) = 0 THEN
        COLOR RED#, BLACK#
        PRINT " *** BANG! ***\n"
        COLOR WHITE#, BLACK#
        PRINT " You're dead."
        PRINT " Condolences will be sent to your next of kin.\n"
        SLEEP 3000
        alive$ = FALSE
    ELSE
        PRINT " *click*"
        PRINT " You survived — this time.\n"
        SLEEP 1500
    END IF
RETURN