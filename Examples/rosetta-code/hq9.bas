' =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
' https://rosettacode.org/wiki/Execute_HQ9%2B
' BazzBasic: https://ekbass.github.io/BazzBasic/
' =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

[inits]
    LET text$
    LET accumulator$ = 0
    LET beer$ = 99 
    LET error# = "Error: HQ9+ invalid"
    LET hello$ = "World"
    LET world# = "Hello"
    LET i$
    LET ch$

[main]
    INPUT "Enter an HQ9+ Prog: ", text$

    FOR i$ = 1 TO LEN(text$)
        ch$ = UCASE(MID(text$, i$, 1))

        IF ch$ = "H" THEN
            PRINT world# + ", " + hello$ + "!"
        ELSEIF ch$ = "Q" THEN
            GOSUB [quine]
        ELSEIF ch$ = "9" THEN
            GOSUB [bottles99]
        ELSEIF ch$ = "+" THEN
            accumulator$ = accumulator$ + 1
            PRINT accumulator$
        ELSE
            PRINT error#
        END IF
    NEXT
END

[bottles99]
    DEF FN bots$(amount$)
        IF amount$ > 1 THEN
            RETURN amount$ + " bottles "
        ELSEIF amount$ = 1 THEN
            RETURN "1 bottle"
        ENDIF

        RETURN "No more bottles"
    END DEF

    LET  beer$ = 99
    WHILE beer$ > 0
        PRINT FN bots$(beer$); "of beer on the wall."
        PRINT FN bots$(beer$); "of beer."
        PRINT "Take one down, pass it around,"
        PRINT FN bots$(beer$ - 1); "of beer on the wall.\n"
        beer$ = beer$ - 1
    WEND
    PRINT "No more bottles of beer on the wall,\nno more bottles of beer.\nGo to the store and buy some more,\n99 bottles of beer on the wall.."
    RETURN

[quine]
' Cat the program
    LET source$ = FILEREAD("hq9.bas")
    PRINT source$
    RETURN
