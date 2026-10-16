' ============================================
' Guess the BASIC dialect - scrambled-name memory game
' BazzBasic: https://github.com/EkBass/BazzBasic
' Public domain
' ============================================

' Returns text$ with its characters in random order.
' It repeatedly removes one random character from what is left and
' appends it to the result (a Fisher-Yates shuffle done on a string),
' so every arrangement is equally likely.
DEF FN Scramble$(text$)
    LET remaining$ = text$
    LET result$ = ""
    LET pick$ = 0

    WHILE LEN(remaining$) > 0
        pick$ = RND(LEN(remaining$)) + 1
        result$ = result$ + MID(remaining$, pick$, 1)
        remaining$ = LEFT(remaining$, pick$ - 1) + RIGHT(remaining$, LEN(remaining$) - pick$)
    WEND

    RETURN result$
END DEF

' Makes two names comparable: trims the ends and removes inner spaces,
' so "gb basic", "GBBasic" and " GB Basic " all match "GB Basic".
' (Case needs no handling: string "=" is case-insensitive in BazzBasic.)
DEF FN Normalize$(text$)
    RETURN REPLACE(TRIM(text$), " ", "")
END DEF

[inits]
    LET SHOW_SECONDS# = 15

    DIM basics$
        basics$(0)  = "BazzBasic"
        basics$(1)  = "FreeBasic"
        basics$(2)  = "QB64"
        basics$(3)  = "GB Basic"
        basics$(4)  = "BBCSDL"
        basics$(5)  = "BlitzMax"
        basics$(6)  = "Blitz3D"
        basics$(7)  = "ugBasic"
        basics$(8)  = "Sprite Basic"
        basics$(9)  = "BasicC"
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

    LET nameCount$  = ROWCOUNT(basics$())
    LET correct$    = ""
    LET scrambled$  = ""
    LET guess$      = ""
    LET again$      = ""
    LET key$        = 0

[main]
    CLS
    PRINT "I will show you the names of "; nameCount$; " different BASIC dialects,"
    PRINT "but only for "; SHOW_SECONDS#; " seconds."
    PRINT
    PRINT "Then I scramble the letters of one of them,"
    PRINT "and your job is to figure out which one it was."
    PRINT "Case and spaces don't matter: 'gb basic' = 'GBBasic' = 'GB Basic'."
    PRINT
    PRINT "Press any key to start..."
    key$ = WAITKEY()

    GOSUB [sub:showNames]

    ' RND(n) returns 0..n-1, which is exactly the valid index range
    correct$ = basics$(RND(nameCount$))

    ' A shuffle can land on the original order (QB64 has only 24
    ' arrangements), so reshuffle until the word really is scrambled.
    scrambled$ = correct$
    WHILE scrambled$ = correct$
        scrambled$ = FN Scramble$(correct$)
    WEND

    ' Quotes make leading/trailing spaces visible
    PRINT "Scrambled name: \""; scrambled$; "\""
    PRINT
    LINE INPUT "Your guess: ", guess$

    IF FN Normalize$(guess$) = FN Normalize$(correct$) THEN
        PRINT "Correct! It was "; correct$; "."
    ELSE
        PRINT "Nah, not this time. It was "; correct$; "."
    END IF

    PRINT
    LINE INPUT "Play again (y/n)? ", again$
    IF LEFT(TRIM(again$), 1) = "y" THEN GOTO [main]
END

' Shows all names, counts down SHOW_SECONDS#, then wipes the screen
[sub:showNames]
    CLS
    FOR i$ = 0 TO nameCount$ - 1
        PRINT basics$(i$)
    NEXT
    PRINT

    FOR secondsLeft$ = SHOW_SECONDS# TO 1 STEP -1
        LOCATE nameCount$ + 2, 1
        PRINT "Memorize! "; secondsLeft$; " s left   "
        SLEEP 1000
    NEXT

    CLS
RETURN

' Output (example run - names and scramble are random):
' Scrambled name: "acftr saiBC"
'
' Your guess: craft basic
' Correct! It was Craft Basic.
'
' Play again (y/n)? n