' ============================================
' XML & JSON demo: RSS / Atom feed reader
' BazzBasic: https://github.com/EkBass/BazzBasic
' Requires BazzBasic 1.7 (XML in ASARRAY, ASXML, LOADXML, SAVEXML)
' ============================================

' --------------------------------------------
' DEF FN section
' Arrays cannot be passed to a function directly. The caller sends
' ASJSON(arr$), and the function rebuilds a local copy with ASARRAY.
' --------------------------------------------
DEF FN GetName$(json$)
    DIM data$
    LET count$ = ASARRAY(data$, json$)
    RETURN data$("name")
END DEF

[inits]
    ' Input and output files, relative to the program folder
    LET FEED_RSS2#   = "feeds/01_rss2.xml"
    LET FEED_SINGLE# = "feeds/02_rss_single_item.xml"
    LET FEED_ATOM#   = "feeds/03_atom.xml"
    LET FEED_BOM#    = "feeds/06_bom_config.xml"
    LET CFG_FILE#    = "cfg.xml"

    ' Common key prefix of every RSS 2.0 <item>
    LET ITEM_ROOT# = "rss,channel,0,item,"

    ' Files that must exist before the demo can run
    DIM required$
    required$(0) = FEED_RSS2#
    required$(1) = FEED_SINGLE#
    required$(2) = FEED_ATOM#
    required$(3) = FEED_BOM#

    ' Arrays used by the demo sections
    DIM feed$, single$, atom$, again$, cfg$, cfg2$, bom$, player$

    ' Working variables
    LET xml$     = ""
    LET back$    = ""
    LET base$    = ""
    LET count$   = 0
    LET i$       = 0
    LET c$       = 0
    LET missing$ = 0

[main]
    GOSUB [sub:checkFiles]
    GOSUB [sub:readRss2]
    GOSUB [sub:readSingleItem]
    GOSUB [sub:readAtom]
    GOSUB [sub:roundTrip]
    GOSUB [sub:configFile]
    GOSUB [sub:bomFile]
    GOSUB [sub:jsonToXml]

    LET wk$ = WAITKEY()
END

' --------------------------------------------
' Stop early with a clear message if an input file is missing.
' ASARRAY on an empty string is an error, so check before reading.
' --------------------------------------------
[sub:checkFiles]
    FOR f$ = 0 TO LEN(required$()) - 1
        IF FILEEXISTS(required$(f$)) = FALSE THEN
            PRINT "Missing file: "; required$(f$)
            missing$ += 1
        END IF
    NEXT f$
    IF missing$ > 0 THEN END
RETURN

' --------------------------------------------
' RSS 2.0: channel title, every item with its categories,
' attributes (@name), element text (#text) and prefixes (dc:)
' --------------------------------------------
[sub:readRss2]
    PRINT "--- RSS 2.0 feed ---"
    xml$ = FILEREAD(FEED_RSS2#)
    count$ = ASARRAY(feed$, xml$)
    PRINT "Elements parsed: "; count$
    PRINT "Feed title:      "; feed$("rss,channel,0,title,0")

    ' Items are indexed 0, 1, 2... - loop until the next one is missing
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

    ' <guid isPermaLink="..."> has both an attribute and text
    base$ = ITEM_ROOT# + "0,"
    PRINT "guid @isPermaLink: "; feed$(base$ + "guid,0,@isPermaLink")
    PRINT "guid #text:        "; feed$(base$ + "guid,0,#text")

    ' Namespace prefixes are kept exactly as written
    PRINT "dc:creator:        "; feed$(base$ + "dc:creator,0")
    PRINT ""
RETURN

' --------------------------------------------
' Even a single <item> is indexed: item,0
' --------------------------------------------
[sub:readSingleItem]
    PRINT "--- RSS feed with a single item ---"
    xml$ = FILEREAD(FEED_SINGLE#)
    count$ = ASARRAY(single$, xml$)
    PRINT "Item 0 title: "; single$(ITEM_ROOT# + "0,title,0")
    PRINT ""
RETURN

' --------------------------------------------
' Atom: links are attributes, not element text
' --------------------------------------------
[sub:readAtom]
    PRINT "--- Atom feed ---"
    xml$ = FILEREAD(FEED_ATOM#)
    count$ = ASARRAY(atom$, xml$)
    PRINT "Entry 1 link href: "; atom$("feed,entry,1,link,0,@href")
    PRINT ""
RETURN

' --------------------------------------------
' Round trip: array -> XML string -> array
' --------------------------------------------
[sub:roundTrip]
    PRINT "--- Round trip ---"
    back$ = ASXML(single$)
    PRINT back$
    count$ = ASARRAY(again$, back$)
    PRINT "Title after round trip: "; again$(ITEM_ROOT# + "0,title,0")
    PRINT ""
RETURN

' --------------------------------------------
' Build an XML document in BASIC, save it and load it back
' --------------------------------------------
[sub:configFile]
    PRINT "--- Build, save and load ---"
    cfg$("config,player,0")        = "Krisu"
    cfg$("config,volume,0")        = 80
    cfg$("config,setting,0,@name") = "fullscreen"
    cfg$("config,setting,0,#text") = "on"

    SAVEXML cfg$, CFG_FILE#
    LOADXML cfg2$, CFG_FILE#

    ' Everything read from XML is a string - VAL() turns it back into a number
    PRINT "Player:  "; cfg2$("config,player,0")
    PRINT "Volume:  "; VAL(cfg2$("config,volume,0"))
    PRINT "Setting: "; cfg2$("config,setting,0,@name"); " = "; cfg2$("config,setting,0,#text")
    PRINT ""
RETURN

' --------------------------------------------
' A UTF-8 BOM and leading whitespace are skipped
' before ASARRAY decides between JSON and XML
' --------------------------------------------
[sub:bomFile]
    PRINT "--- File with BOM ---"
    xml$ = FILEREAD(FEED_BOM#)
    count$ = ASARRAY(bom$, xml$)
    PRINT "Setting 1 name: "; bom$("config,setting,1,@name")
    PRINT ""
RETURN

' --------------------------------------------
' JSON still works as before, including passing an array to DEF FN.
' The same array converted to XML: with two top-level keys
' there is no single root, so ASXML wraps them in <root>.
' --------------------------------------------
[sub:jsonToXml]
    PRINT "--- JSON and DEF FN ---"
    player$("name")  = "Krisu"
    player$("score") = 1200
    PRINT "Name via DEF FN: "; FN GetName$(ASJSON(player$))
    PRINT "Same array as XML:"
    PRINT ASXML(player$)
RETURN

' Output depends on the contents of the feeds/ folder.