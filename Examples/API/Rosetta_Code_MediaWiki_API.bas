' ============================================
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Queries the Rosetta Code MediaWiki API for the BASIC dialect categories and prints the top 15 ranked by number of solutions.
' CATEGORY: api
' TAGS: mediawiki, rosetta code, httpget, json, ranking
' MINVERSION: 1.5
' ============================================
'
' Rosetta Code runs on MediaWiki, and every MediaWiki site has a
' query API at /w/api.php. Instead of scraping the HTML page
'   https://rosettacode.org/wiki/Category:BASIC_Implementations
' we ask the API for the same data as JSON:
'
'   generator=categorymembers  - take the members of a category...
'   gcmtitle=Category:...      - ...of this category...
'   gcmtype=subcat             - ...but only its subcategories (the dialects)
'   gcmlimit=500               - up to 500 at once (anonymous maximum)
'   prop=categoryinfo          - and for each one, its member counts
'   format=json                - answer in JSON
'   formatversion=2            - "pages" as a JSON array (0, 1, 2, ...)
'                                instead of an object keyed by page id
'
' The answer looks like this (checked 22.10.2026):
'
'   {"batchcomplete":true,"query":{"pages":[
'     {"pageid":170,"ns":14,"title":"Category:QuickBASIC",
'      "categoryinfo":{"size":77,"pages":76,"files":0,"subcats":1,...}},
'     ...]}}
'
' ASARRAY flattens nested JSON into comma-separated keys, so the
' values we need are:
'   data$("query,pages,0,title")               -> "Category:QuickBASIC"
'   data$("query,pages,0,categoryinfo,pages")  -> 76
'
' "pages" in categoryinfo counts only ordinary pages (the task
' solutions), not subcategories or files - the same number as the
' "P" on the HTML page.

' ---- DEF FN section ----

' 1786 -> "1 786" when sep$ is " " (Finnish style)
DEF FN Thousands$(n$, sep$)
    LET digits$ = STR(INT(n$))
    LET out$ = ""
    WHILE LEN(digits$) > 3
        out$ = sep$ + RIGHT(digits$, 3) + out$
        digits$ = LEFT(digits$, LEN(digits$) - 3)
    WEND
    RETURN digits$ + out$
END DEF

' Pad with spaces to width w$ - text on the left / on the right
DEF FN PadRight$(s$, w$)
    RETURN s$ + REPEAT(" ", MAX(0, w$ - LEN(s$)))
END DEF

DEF FN PadLeft$(s$, w$)
    RETURN REPEAT(" ", MAX(0, w$ - LEN(s$))) + s$
END DEF

[inits]
    LET API#        = "https://rosettacode.org/w/api.php"
    LET CATEGORY#   = "Category:BASIC_Implementations"
    LET CAT_PREFIX# = "Category:"
    LET TOP_N#      = 15
    LET SEP#        = " "                       ' thousands separator

    ' The query string, built piece by piece so each part is readable.
    ' A line ending in "+" continues on the next line.
    LET URL# = API# + "?action=query" +
               "&generator=categorymembers" +
               "&gcmtitle=" + CATEGORY# +
               "&gcmtype=subcat" +
               "&gcmlimit=500" +
               "&prop=categoryinfo" +
               "&format=json" +
               "&formatversion=2"

    ' MediaWiki asks API clients to identify themselves. The leading
    ' "Mozilla/5.0" keeps CDN filters happy; the rest says who we are.
    DIM headers$
    headers$("User-Agent") = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) " +
                             "BazzBasic (+https://github.com/EkBass/BazzBasic)"

    DIM data$                       ' the parsed JSON answer
    DIM names$                      ' names$(i)  = dialect name
    DIM pages$                      ' pages$(i)  = number of solutions

    LET raw$ = "", jsonCount$ = 0
    LET base$ = "", title$ = "", count$ = 0, skipped$ = 0
    LET idx$ = 0
    LET shown$ = 0, best$ = 0, tmp$ = 0
    LET rank$ = "", col1$ = "", col2$ = "", col3$ = ""

[fetch]
    PRINT "Asking the Rosetta Code API ..."
    raw$ = HTTPGET(URL#, headers$)

    ' ASARRAY halts the program on text that is not JSON, and there is
    ' no TRY/CATCH in BazzBasic. So check first that the answer at
    ' least starts like a JSON object - an HTML error page from a
    ' proxy or CDN would start with "<".
    IF LEFT(TRIM(raw$), 1) <> "{" THEN
        PRINT "The answer was not JSON. Received "; LEN(raw$); " bytes:"
        PRINT LEFT(raw$, 300)
        END
    END IF

    jsonCount$ = ASARRAY(data$, raw$)

    ' The API reports its own problems inside valid JSON.
    IF HASKEY(data$("error,info")) THEN
        PRINT "API error: " + data$("error,info")
        END
    END IF

    IF HASKEY(data$("query,pages,0,title")) = FALSE THEN
        PRINT "The answer contained no subcategories."
        END
    END IF

[collect]
    ' formatversion=2 makes "pages" an array, so its items are numbered
    ' 0, 1, 2, ... with no gaps. We read them until a number is missing.
    ' The keys are written as one string ("query,pages,3,title"), which
    ' is exactly how ASARRAY stores them.
    idx$ = 0
    base$ = "query,pages,0,"
    WHILE HASKEY(data$(base$ + "title"))
        GOSUB [sub:readItem]
        idx$ += 1
        base$ = "query,pages," + idx$ + ","
    WEND

    ' gcmlimit=500 covers the 58 dialects of 22.10.2026 many times over.
    ' Should the list ever outgrow it, the API adds a "continue" block
    ' and we say so rather than silently printing a partial ranking.
    IF HASKEY(data$("continue,gcmcontinue")) THEN
        PRINT "Note: the API returned only part of the list (over 500 dialects)."
    END IF

    IF count$ = 0 THEN
        PRINT "No dialects could be read from the answer."
        END
    END IF

[sort]
    ' Partial selection sort: only the first TOP_N# places are
    ' needed, so we stop after them.
    shown$ = MIN(TOP_N#, count$)
    FOR i$ = 0 TO shown$ - 1
        best$ = i$
        FOR j$ = i$ + 1 TO count$ - 1
            IF pages$(j$) > pages$(best$) THEN best$ = j$
        NEXT j$
        IF best$ <> i$ THEN
            tmp$ = names$(i$) : names$(i$) = names$(best$) : names$(best$) = tmp$
            tmp$ = pages$(i$) : pages$(i$) = pages$(best$) : pages$(best$) = tmp$
        END IF
    NEXT i$

[report]
    PRINT ""
    ' In .NET date formats ":" means "the culture's time separator",
    ' which is "." on a Finnish Windows. Quoting it as ':' makes it a
    ' literal colon on every system.
    PRINT "Timestamp: " + TIME("dddd dd.MM.yyyy HH':'mm")
    PRINT FSTRING("Dialects found: {{-count$-}}   Skipped: {{-skipped$-}}")
    PRINT ""
    PRINT "  #  BASIC dialect             Solutions"
    PRINT "---  --------------------  -----------"
    FOR i$ = 0 TO shown$ - 1
        rank$ = i$ + 1
        col1$ = FN PadLeft$(rank$, 3)
        col2$ = FN PadRight$(names$(i$), 20)
        col3$ = FN PadLeft$(FN Thousands$(pages$(i$), SEP#), 11)
        PRINT col1$; "  "; col2$; "  "; col3$
    NEXT i$

    INPUT "Press Enter to quit.", quit$
END

' ---- Subroutines ----

' In:  base$ = "query,pages,<idx>,"  (key prefix of one dialect)
' Out: adds one row to names$/pages$, or increments skipped$
[sub:readItem]
    ' A category with no members at all may come without categoryinfo.
    IF HASKEY(data$(base$ + "categoryinfo,pages")) = FALSE THEN
        skipped$ += 1
        RETURN
    END IF

    ' "Category:FreeBASIC" -> "FreeBASIC"
    title$ = data$(base$ + "title")
    IF LEFT(title$, LEN(CAT_PREFIX#)) = CAT_PREFIX# THEN
        title$ = MID(title$, LEN(CAT_PREFIX#) + 1)
    END IF

    names$(count$) = title$
    pages$(count$) = VAL(data$(base$ + "categoryinfo,pages"))
    count$ += 1
RETURN

' Output (22.10.2026):
' Asking the Rosetta Code API ...
'
' Timestamp: Thursday 22.10.2026 21:50
' Dialects found: 58   Skipped: 0
'
'   #  BASIC dialect             Solutions
' ---  --------------------  -----------
'   1  FreeBASIC                   1 786
'   2  FutureBasic                   984
'   3  PureBasic                     767
'   4  Yabasic                       592
'   5  BBC BASIC                     591
'   6  BASIC256                      513
'   7  Run BASIC                     406
'   8  Liberty BASIC                 370
'   9  Applesoft BASIC               355
'  10  QBasic                        275
'  11  True BASIC                    272
'  12  BazzBasic                     246
'  13  GW-BASIC                      242
'  14  Chipmunk Basic                233
'  15  UBasic/4tH                    223
