' =============================================================
' Guess the basic dialect: mini guessing game
' BazzBasic version. Public domain
' =============================================================

DEF FN Scramble$(text$)
    LET scrambled$

    FOR I$ = 1 TO LEN(text$)
        IF BETWEEN(RND(100) + 1, 1, 50) THEN
            scrambled$ = scrambled$ + MID(text$, i$, 1)
        ELSE
            scrambled$ = MID(text$, i$, 1) + scrambled$
        END IF
    NEXT

    RETURN scrambled$
END DEF


[inits]
    DIM basics$
        basics$(0) = "BazzBasic"
        basics$(1) = "FreeBasic"
        basics$(2) = "QB64"
        basics$(3) = "GB Basic"
        basics$(4) = "BBCSDL"
        basics$(5) = "BlitzMax"
        basics$(6) = "Blitz3D"
        basics$(7) = "ugBasic"
        basics$(8) = "Sprite Basic"
        basics$(9) = "BasicC"
        basics$(10) = "MiniBasic"
        basics$(11) = "QBJS"
        basics$(12) = "RCBasic"
        basics$(13) = "Commando Basic"
        basics$(14) = "Craft Basic"
        basics$(15) = "PlayBASIC"
        basics$(16) = "ThinBasic"
        basics$(17) = "YaBasic"
        basics$(18) = "SmallBasic"
        basics$(19) = "TinyBasic"

    LET scrambled$
    LET correct$
    LET dummy$
    ' LET guess$

[main]
    CLS
    PRINT "I will show you names of "; LEN(basics$()); " different BASIC variations."
    PRINT "But only for "; LEN(basics$()); " seconds.\n"
    PRINT "Then I scramble the letters of one of them."
    PRINT "Your job is to figure out which of them it is."
    PRINT "You can response case-insensitive style: basic = BASIC."
    PRINT "\nPress key to start..."
    LET dummy$ = WAITKEY()

    GOSUB [sub:showThem]

    correct$ = basics$(RND(LEN(basics$())))
    scrambled$ = FN Scramble$(correct$)

    PRINT "Scrambled name of basic is: "; scrambled$
    PRINT

    ' INPUT can initialize variables itself. Not often used by me, but now I thought to let it do so
    INPUT "What is your guess?", guess$
    
    IF LCASE(guess$) = LCASE(correct$) THEN
        PRINT "Correct answer..."
    ELSE
        PRINT "Nah, you got it wrong."
        PRINT "Correct: "; correct$
        PRINT "Scrambled: "; scrambled$
    END IF
   
END

[sub:showThem]
    CLS
    FOR i$ = 0 TO LEN(basics$()) - 1
        PRINT basics$(i$)
    NEXT
    PRINT "\nPress any key to continue..."
    dummy$ = WAITKEY()
RETURN
