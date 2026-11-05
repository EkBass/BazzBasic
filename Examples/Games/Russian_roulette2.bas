' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Text game of chance: the revolver chamber is spun once and you
'              keep pulling the trigger. Survive five pulls and only the
'              loaded chamber is left, so you walk away a winner.
' CATEGORY: games
' TAGS: russian roulette, random chance, probability
' MINVERSION: 1.5
' ============================================
' Originally from CREATIVE COMPUTING
' Morristown, New Jersey

[inits]
    ' Console colors (palette 0-15)
    LET BLACK#   = 0
    LET RED#     = 4
    LET GREEN#   = 10
    LET CYAN#    = 11
    LET WHITE#   = 15

    ' Revolver
    LET CHAMBERS#  = 6                  ' slots in the cylinder
    LET MAX_PULLS# = CHAMBERS# - 1      ' a 6th pull would always hit the bullet

    ' Game state
    LET choice$       = 0
    LET playing$      = TRUE
    LET alive$        = TRUE
    LET bulletPos$    = 0               ' 1..CHAMBERS#, chosen once per game
    LET pulls$        = 0               ' trigger pulls survived so far
    LET chambersLeft$ = 0               ' chambers not yet fired

[main]
    WHILE playing$
        GOSUB [sub:title]
        GOSUB [sub:spin]
        WHILE playing$ AND alive$ AND pulls$ < MAX_PULLS#
            GOSUB [sub:menu]
        WEND
        IF alive$ AND pulls$ = MAX_PULLS# THEN GOSUB [sub:survived]
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

' Load one bullet and spin the cylinder. Happens once per game.
[sub:spin]
    bulletPos$ = RND(CHAMBERS#) + 1     ' RND(6) gives 0..5, so +1 gives 1..6
    pulls$     = 0
    alive$     = TRUE
    PRINT " HERE IS A REVOLVER. ONE BULLET IS LOADED"
    PRINT " AND THE CHAMBER HAS BEEN SPUN."
    PRINT FSTRING(" Survive {{-MAX_PULLS#-}} pulls and you walk out alive.")
    PRINT ""
RETURN

[sub:menu]
    chambersLeft$ = CHAMBERS# - pulls$
    PRINT FSTRING(" Pulls survived: {{-pulls$-}} of {{-MAX_PULLS#-}}")
    PRINT FSTRING(" Chance the next chamber is loaded: 1 in {{-chambersLeft$-}}")
    PRINT ""
    PRINT " 1 — Pull the trigger."
    PRINT " 2 — Walk away.\n"
    choice$ = WAITKEY(KEY_1#, KEY_2#)
    PRINT " "; CHR(choice$); "\n"
    IF choice$ = KEY_2# THEN
        playing$ = FALSE
    ELSE
        GOSUB [sub:shoot]
    END IF
RETURN

' The cylinder advances one chamber per pull; no re-spinning.
[sub:shoot]
    pulls$ += 1
    IF pulls$ = bulletPos$ THEN
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

[sub:survived]
    COLOR GREEN#, BLACK#
    PRINT " *** YOU MADE IT! ***\n"
    COLOR WHITE#, BLACK#
    PRINT FSTRING(" {{-MAX_PULLS#-}} empty chambers in a row. The bullet was in chamber {{-bulletPos$-}}.")
    PRINT " Nobody is foolish enough to pull the trigger again.\n"
    SLEEP 4000
RETURN

' Example session (the bullet position is random):
' HERE IS A REVOLVER. ONE BULLET IS LOADED
' AND THE CHAMBER HAS BEEN SPUN.
' Survive 5 pulls and you walk out alive.
'
' Pulls survived: 0 of 5
' Chance the next chamber is loaded: 1 in 6
'
' 1 — Pull the trigger.
' 2 — Walk away.
'
' 1
'
' *click*
' You survived — this time.
'
' Pulls survived: 1 of 5
' Chance the next chamber is loaded: 1 in 5
' ...
