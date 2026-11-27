' ============================================
' https://rosettacode.org/wiki/Magic_8-ball
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    ' The 20 classic answers: 10 positive, 5 non-committal, 5 negative.
    ' "|" is the separator because the answers contain commas and dashes.
    LET ANSWERS# = "It is certain.|It is decidedly so.|Without a doubt.|" +
                   "Yes - definitely.|You may rely on it.|As I see it, yes.|" +
                   "Most likely.|Outlook good.|Yes.|Signs point to yes.|" +
                   "Reply hazy, try again.|Ask again later.|" +
                   "Better not tell you now.|Cannot predict now.|" +
                   "Concentrate and ask again.|Don't count on it.|" +
                   "My reply is no.|My sources say no.|" +
                   "Outlook not so good.|Very doubtful."

    DIM answers$
    LET count$    = SPLIT(answers$, ANSWERS#, "|")
    LET question$ = ""

[main]
    CLS
    PRINT "*** MAGIC 8-BALL ***"
    PRINT "Ask a yes/no question. Press Enter on an empty line to quit."
    PRINT

[ask]
    LINE INPUT "What would you like to know? ", question$
    IF TRIM(question$) = "" THEN GOTO [goodbye]

    PRINT "  The 8-Ball says: "; answers$(RND(count$))
    PRINT
    GOTO [ask]

[goodbye]
    PRINT "The 8-Ball rests."
END

' Output (answers are random):
' *** MAGIC 8-BALL ***
' Ask a yes/no question. Press Enter on an empty line to quit.
'
' What would you like to know? Will it rain tomorrow?
'   The 8-Ball says: Outlook good.
'
' What would you like to know? Is BazzBasic fun?
'   The 8-Ball says: It is decidedly so.
'
' What would you like to know?
' The 8-Ball rests.