' ============================================
' https://rosettacode.org/wiki/Simple_database
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' A tiny command-line diary/organizer. Data is kept as JSON.
'
' Usage:
'   bazzbasic Simple_database.bas add "<title>" "<category>" [yyyy-mm-dd] ["notes"]
'   bazzbasic Simple_database.bas latest
'   bazzbasic Simple_database.bas categories
'   bazzbasic Simple_database.bas list
'
' If no date is given, today's date is used.

' "2026-10-15" -> 20261015, a number that sorts like the date
DEF FN DateKey$(d$)
    RETURN VAL(REPLACE(d$, "-", ""))
END DEF

' Light sanity check for yyyy-mm-dd
DEF FN IsDate$(d$)
    IF LEN(d$) <> 10 THEN RETURN FALSE
    IF MID(d$, 5, 1) <> "-" OR MID(d$, 8, 1) <> "-" THEN RETURN FALSE
    IF VAL(LEFT(d$, 4)) < 1 THEN RETURN FALSE
    IF NOT BETWEEN(VAL(MID(d$, 6, 2)), 1, 12) THEN RETURN FALSE
    RETURN BETWEEN(VAL(MID(d$, 9, 2)), 1, 31)
END DEF

[inits]
    LET DB_FILE# = PRG_ROOT# + "Simple_database.json"

    DIM db$             ' db$(n, "title" / "category" / "date" / "notes")
    DIM seen$           ' categories already printed
    DIM order$          ' entry indexes, sorted by date
    DIM dk$             ' numeric date keys per entry

    LET cmd$      = ""
    LET count$    = 0
    LET idx$      = 0
    LET j$        = 0
    LET cur$      = 0
    LET curKey$   = 0
    LET done$     = FALSE
    LET title$    = ""
    LET category$ = ""
    LET date$     = ""
    LET notes$    = ""

[main]
    IF ARGCOUNT = 0 THEN GOTO [usage]
    cmd$ = LCASE(ARGS(0))

    IF FILEEXISTS(DB_FILE#) THEN LOADJSON db$, DB_FILE#
    count$ = ROWCOUNT(db$())

    IF cmd$ = "add" THEN
        GOSUB [sub:add]
    ELSEIF cmd$ = "latest" THEN
        GOSUB [sub:latest]
    ELSEIF cmd$ = "categories" THEN
        GOSUB [sub:categories]
    ELSEIF cmd$ = "list" THEN
        GOSUB [sub:list]
    ELSE
        GOTO [usage]
    END IF
END

[usage]
    PRINT "Usage:"
    PRINT "  add \"title\" \"category\" [yyyy-mm-dd] [\"notes\"]"
    PRINT "  latest       - print the latest entry"
    PRINT "  categories   - print the latest entry of each category"
    PRINT "  list         - print all entries sorted by date"
END

[sub:add]
    IF ARGCOUNT < 3 THEN GOTO [usage]
    title$    = ARGS(1)
    category$ = ARGS(2)
    date$     = TIME("yyyy-MM-dd")
    IF ARGCOUNT > 3 THEN date$ = ARGS(3)
    IF ARGCOUNT > 4 THEN notes$ = ARGS(4)

    IF NOT FN IsDate$(date$) THEN
        PRINT "Bad date '"; date$; "', use yyyy-mm-dd."
        RETURN
    END IF

    db$(count$, "title")    = title$
    db$(count$, "category") = category$
    db$(count$, "date")     = date$
    db$(count$, "notes")    = notes$
    SAVEJSON db$, DB_FILE#

    idx$ = count$
    PRINT "Added: ";
    GOSUB [sub:printEntry]
RETURN

[sub:latest]
    IF count$ = 0 THEN
        PRINT "The database is empty."
        RETURN
    END IF
    idx$ = count$ - 1
    GOSUB [sub:printEntry]
RETURN

[sub:categories]
    IF count$ = 0 THEN
        PRINT "The database is empty."
        RETURN
    END IF
    ' Walk from newest to oldest; first hit per category is its latest
    FOR idx$ = count$ - 1 TO 0 STEP -1
        category$ = db$(idx$, "category")
        IF NOT HASKEY(seen$(category$)) THEN
            seen$(category$) = TRUE
            GOSUB [sub:printEntry]
        END IF
    NEXT
RETURN

[sub:list]
    IF count$ = 0 THEN
        PRINT "The database is empty."
        RETURN
    END IF
    FOR idx$ = 0 TO count$ - 1
        order$(idx$) = idx$
        dk$(idx$) = FN DateKey$(db$(idx$, "date"))
    NEXT

    ' Insertion sort on date keys (stable: same date keeps entry order)
    FOR idx$ = 1 TO count$ - 1
        cur$    = order$(idx$)
        curKey$ = dk$(cur$)
        j$      = idx$ - 1
        done$   = FALSE
        WHILE j$ >= 0 AND done$ = FALSE
            IF dk$(order$(j$)) > curKey$ THEN
                order$(j$ + 1) = order$(j$)
                j$ -= 1
            ELSE
                done$ = TRUE
            END IF
        WEND
        order$(j$ + 1) = cur$
    NEXT

    FOR j$ = 0 TO count$ - 1
        idx$ = order$(j$)
        GOSUB [sub:printEntry]
    NEXT
RETURN

' Prints db$(idx$)
[sub:printEntry]
    PRINT FSTRING("{{-db$(idx$, date)-}}  {{-db$(idx$, category)-}}: {{-db$(idx$, title)-}}");
    IF db$(idx$, "notes") <> "" THEN PRINT "  ("; db$(idx$, "notes"); ")";
    PRINT
RETURN

' Output:
' > bazzbasic Simple_database.bas latest
' The database is empty.
' > bazzbasic Simple_database.bas add "Matti Meikalainen" "Friend" 1975-03-02 "matti@example.com"
' Added: 1975-03-02  Friend: Matti Meikalainen  (matti@example.com)
' > bazzbasic Simple_database.bas add "Aunt Liisa" "Family" 1948-07-21
' Added: 1948-07-21  Family: Aunt Liisa
' > bazzbasic Simple_database.bas add "Fender Jazz Bass" "Gear" 2024-05-10 "sunburst"
' Added: 2024-05-10  Gear: Fender Jazz Bass  (sunburst)
' > bazzbasic Simple_database.bas add "Teppo Testaaja" "Friend" 1990-11-30
' Added: 1990-11-30  Friend: Teppo Testaaja
' > bazzbasic Simple_database.bas add "Bought strings" "Gear"
' Added: 2026-10-15  Gear: Bought strings
'
' > bazzbasic Simple_database.bas latest
' 2026-10-15  Gear: Bought strings
'
' > bazzbasic Simple_database.bas categories
' 2026-10-15  Gear: Bought strings
' 1990-11-30  Friend: Teppo Testaaja
' 1948-07-21  Family: Aunt Liisa
'
' > bazzbasic Simple_database.bas list
' 1948-07-21  Family: Aunt Liisa
' 1975-03-02  Friend: Matti Meikalainen  (matti@example.com)
' 1990-11-30  Friend: Teppo Testaaja
' 2024-05-10  Gear: Fender Jazz Bass  (sunburst)
' 2026-10-15  Gear: Bought strings
'
' Simple_database.json:
' [
'   {
'     "title": "Matti Meikalainen",
'     "category": "Friend",
'     "date": "1975-03-02",
'     "notes": "matti@example.com"
'   },
'   ...
' ]