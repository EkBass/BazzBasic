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

    LET choice$ = 0

[title]
    COLOR CYAN#, BLACK#
    CLS
    PRINT " "; REPEAT("*", 21)
    PRINT " *"; REPEAT(" ", 19); "*"
    PRINT " *  RUSSIAN ROULETTE  *"
    PRINT " *"; REPEAT(" ", 19); "*"
    PRINT " "; REPEAT("*", 21)
    PRINT "\n CREATIVE COMPUTING\n MORRISTOWN, NEW JERSEY\n"
    COLOR WHITE#, BLACK#

[menu]
    PRINT " HERE IS A REVOLVER."
    PRINT " 1 — Spin the chamber and pull the trigger."
    PRINT " 2 — Walk away.\n"

    choice$ = WAITKEY(KEY_1#, KEY_2#)
    PRINT " "; CHR(choice$); "\n"

    IF choice$ = KEY_2# THEN GOTO [quit]

[shoot]
    IF RND(6) = 0 THEN
        COLOR RED#, BLACK#
        PRINT " *** BANG! ***\n"
        COLOR WHITE#, BLACK#
        PRINT " You're dead."
        PRINT " Condolences will be sent to your next of kin.\n"
        SLEEP 3000
        GOTO [title]
    END IF

    PRINT " *click*"
    PRINT " You survived — this time.\n"
    SLEEP 1500
    GOTO [menu]

[quit]
    PRINT " Smart move.\n"
END
