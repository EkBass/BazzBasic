' ============================================
' ROSETTA: https://rosettacode.org/wiki/The_Twelve_Days_of_Christmas
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Prints the lyrics of the carol The Twelve Days of Christmas, verse by verse, listing the gifts from the newest down to the partridge in a pear tree.
' CATEGORY: basics
' TAGS: twelve days of christmas, nested loops, arrays, fstring
' MINVERSION: 1.5
' ============================================

[inits]
    DIM ordinal$
    DIM gift$

    ordinal$(1)  = "first"
    ordinal$(2)  = "second"
    ordinal$(3)  = "third"
    ordinal$(4)  = "fourth"
    ordinal$(5)  = "fifth"
    ordinal$(6)  = "sixth"
    ordinal$(7)  = "seventh"
    ordinal$(8)  = "eighth"
    ordinal$(9)  = "ninth"
    ordinal$(10) = "tenth"
    ordinal$(11) = "eleventh"
    ordinal$(12) = "twelfth"

    gift$(1)  = "A partridge in a pear tree."
    gift$(2)  = "Two turtle doves,"
    gift$(3)  = "Three french hens,"
    gift$(4)  = "Four calling birds,"
    gift$(5)  = "Five golden rings,"
    gift$(6)  = "Six geese a-laying,"
    gift$(7)  = "Seven swans a-swimming,"
    gift$(8)  = "Eight maids a-milking,"
    gift$(9)  = "Nine ladies dancing,"
    gift$(10) = "Ten lords a-leaping,"
    gift$(11) = "Eleven pipers piping,"
    gift$(12) = "Twelve drummers drumming,"

[main]
    FOR day$ = 1 TO ROWCOUNT(gift$())
        PRINT FSTRING("On the {{-ordinal$(day$)-}} day of Christmas")
        PRINT "My true love gave to me:"
        FOR g$ = day$ TO 1 STEP -1
            IF g$ = 1 AND day$ > 1 THEN
                PRINT "And a partridge in a pear tree."
            ELSE
                PRINT gift$(g$)
            END IF
        NEXT
        PRINT
    NEXT
END

' Output:
' On the first day of Christmas
' My true love gave to me:
' A partridge in a pear tree.
'
' On the second day of Christmas
' My true love gave to me:
' Two turtle doves,
' And a partridge in a pear tree.
'
' ...
'
' On the twelfth day of Christmas
' My true love gave to me:
' Twelve drummers drumming,
' Eleven pipers piping,
' Ten lords a-leaping,
' Nine ladies dancing,
' Eight maids a-milking,
' Seven swans a-swimming,
' Six geese a-laying,
' Five golden rings,
' Four calling birds,
' Three french hens,
' Two turtle doves,
' And a partridge in a pear tree.