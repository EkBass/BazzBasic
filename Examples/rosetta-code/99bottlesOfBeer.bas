' ============================================
' ROSETTA: https://rosettacode.org/wiki/99_Bottles_of_Beer/Basic
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the complete 99 Bottles of Beer song, counting down from 99 bottles with correct singular and plural wording.
' CATEGORY: basics
' TAGS: loops, def fn, text output
' MINVERSION: 1.5
' ============================================
DEF FN Bottles$(amount$)
    IF amount$ > 1 THEN
        RETURN amount$ + " bottles "
    ELSEIF amount$ = 1 THEN
        RETURN "1 bottle "
    ENDIF
    
    RETURN "No more bottles "
END DEF

LET beers$ = 99
WHILE beers$ > 0
    PRINT FN Bottles$(beers$); "of beer on the wall."
    PRINT FN Bottles$(beers$); "of beer."
    PRINT "Take one down, pass it around,"
    PRINT FN Bottles$(beers$ - 1); "of beer on the wall.\n"
    beers$ = beers$ - 1
WEND
PRINT "No more bottles of beer on the wall,\nno more bottles of beer.\nGo to the store and buy some more,\n99 bottles of beer on the wall..."
END