' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Text game of chance: spin the revolver chamber and pull the trigger, with a one-in-six chance of losing each time.
' CATEGORY: games
' TAGS: russian roulette, random chance
' MINVERSION: 1.5
' ============================================
' Originally from CREATIVE COMPUTING
' Morristown, New Jersey
[inits]
    LET C_BLACK#   = 0
    LET C_RED#     = 4
    LET C_CYAN#    = 11
    LET C_WHITE#   = 15
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
    COLOR C_CYAN#, C_BLACK#
    CLS
    PRINT " "; REPEAT("*", 21)
    PRINT " *"; REPEAT(" ", 19); "*"
    PRINT " *  RUSSIAN ROULETTE  *"
    PRINT " *"; REPEAT(" ", 19); "*"
    PRINT " "; REPEAT("*", 21)
    PRINT "\n CREATIVE COMPUTING\n MORRISTOWN, NEW JERSEY\n"
    COLOR C_WHITE#, C_BLACK#
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
        COLOR C_RED#, C_BLACK#
        PRINT " *** BANG! ***\n"
        COLOR C_WHITE#, C_BLACK#
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