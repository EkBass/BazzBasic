' ============================================
' RSS feed reader
' BazzBasic: https://github.com/EkBass/BazzBasic
' Requires BazzBasic 1.7 (XML support in ASARRAY)
' ============================================

[inits]
    ' Feed file, relative to the program folder
    LET FEED_FILE# = "feeds/syndication.rss"

    ' Common key prefixes in the parsed feed
    LET CHANNEL_ROOT# = "rss,channel,0,"
    LET ITEM_ROOT#    = "rss,channel,0,item,"

    DIM feed$

    LET xml$   = ""
    LET base$  = ""
    LET count$ = 0
    LET i$     = 0
    LET c$     = 0
    LET key$   = 0

[main]
    GOSUB [sub:loadFeed]
    GOSUB [sub:printItems]
    GOSUB [sub:printDetails]

    PRINT ""
    PRINT "Press any key to exit."
    key$ = WAITKEY()
END

' --------------------------------------------
' Read the feed file and parse it into feed$.
' ASARRAY on an empty string is an error, so check the file first.
' --------------------------------------------
[sub:loadFeed]
    IF FILEEXISTS(FEED_FILE#) = FALSE THEN
        PRINT "Feed file not found: "; FEED_FILE#
        END
    END IF

    xml$ = FILEREAD(FEED_FILE#)
    count$ = ASARRAY(feed$, xml$)

    PRINT "Elements parsed: "; count$
    PRINT "Feed title:      "; feed$(CHANNEL_ROOT# + "title,0")
    PRINT ""
RETURN

' --------------------------------------------
' List every item with its date and categories.
' Items are indexed 0, 1, 2... - loop until the next one is missing.
' --------------------------------------------
[sub:printItems]
    i$ = 0
    WHILE HASKEY(feed$(ITEM_ROOT# + i$ + ",title,0"))
        base$ = ITEM_ROOT# + i$ + ","
        PRINT i$; ": "; feed$(base$ + "title,0"); "  ["; feed$(base$ + "pubDate,0"); "]"

        ' An item may have any number of <category> elements
        c$ = 0
        WHILE HASKEY(feed$(base$ + "category," + c$))
            PRINT "     category: "; feed$(base$ + "category," + c$)
            c$ += 1
        WEND

        i$ += 1
    WEND
RETURN

' --------------------------------------------
' Details of the first item: an attribute (@name),
' the text of an element that has attributes (#text),
' and a namespace prefix kept as written (dc:)
' --------------------------------------------
[sub:printDetails]
    base$ = ITEM_ROOT# + "0,"
    PRINT ""
    PRINT "First item details"
    PRINT "  guid @isPermaLink: "; feed$(base$ + "guid,0,@isPermaLink")
    PRINT "  guid #text:        "; feed$(base$ + "guid,0,#text")
    PRINT "  dc:creator:        "; feed$(base$ + "dc:creator,0")
RETURN

' Output depends on the contents of feeds/syndication.rss.