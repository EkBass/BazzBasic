' Grocery List - SQLite Version
' BazzBasic version 1.4

[inits]
    LET DB_FILE# = "grocery.db"
    LET cmd$ = ""
    LET item$ = ""
    LET res$ = ""
    
    ' UI Colors
    LET COL_MENU# = 11  ' Cyan
    LET COL_WARN# = 12  ' Lt Red
    LET COL_TEXT# = 15  ' White

    ' Initialize Database: Create table if it doesn't exist
    ' Note the use of \" to escape quotes and 2>&1 to capture errors
    LET initSql$ = "CREATE TABLE IF NOT EXISTS grocery (item TEXT)"
    LET res$ = SHELL("sqlite3 " + DB_FILE# + " \"" + initSql$ + "\" 2>&1")

[main]
    WHILE TRUE
        COLOR COL_MENU#, 0
        PRINT "\nType '/' to know how to use this grocery list (SQL)"
        COLOR COL_TEXT#, 0
        LINE INPUT "Command: ", cmd$
        
        IF cmd$ = "/" THEN
            GOSUB [sub:print_commands]
        ELSEIF cmd$ = "/list" THEN
            GOSUB [sub:print_list]
        ELSEIF cmd$ = "/add" THEN
            GOSUB [sub:add_element]
        ELSEIF cmd$ = "/delete" THEN
            GOSUB [sub:delete_list]
        ELSEIF cmd$ = "/stop" THEN
            PRINT "Goodbye!"
            END
        ELSE
            COLOR COL_WARN#, 0
            PRINT "Wrong command"
        END IF
    WEND

' ---- SUBROUTINES ----

[sub:print_commands]
    PRINT "/       -> Show the list of commands"
    PRINT "/delete -> Delete the entire list (Wipe Table)"
    PRINT "/add    -> Add an element to the list"
    PRINT "/list   -> Show the list"
    PRINT "/stop   -> Exit"
RETURN

[sub:add_element]
    LINE INPUT "New element of the list: ", item$
    
    ' SQL Insert
    LET sql$ = "INSERT INTO grocery (item) VALUES ('" + item$ + "')"
    res$ = SHELL("sqlite3 " + DB_FILE# + " \"" + sql$ + "\" 2>&1")
    
    PRINT "Added to database: " + item$
RETURN

[sub:print_list]
    ' SQL Select
    LET sql$ = "SELECT item FROM grocery"
    res$ = SHELL("sqlite3 " + DB_FILE# + " \"" + sql$ + "\" 2>&1")
    
    ' SHELL returns the output as a string
    IF LEN(TRIM(res$)) = 0 THEN
        COLOR COL_WARN#, 0
        PRINT "List already empty"
    ELSE
        COLOR COL_TEXT#, 0
        PRINT "--- YOUR LIST (SQL) ---"
        PRINT res$
    END IF
RETURN

[sub:delete_list]
    ' SQL Delete[cite: 2]
    LET sql$ = "DELETE FROM grocery"
    res$ = SHELL("sqlite3 " + DB_FILE# + " \"" + sql$ + "\" 2>&1")
    PRINT "Database table wiped"
RETURN

' Output
' Type '/' to know how to use this grocery list (SQL)
' Command: /add
' New element of the list: milk
' Added to database: milk
' 
' Type '/' to know how to use this grocery list (SQL)
' Command: /add
' New element of the list: cow
' Added to database: cow
' 
' Type '/' to know how to use this grocery list (SQL)
' Command: /list
' --- YOUR LIST (SQL) ---
' milk
' cow
' 
' 
' Type '/' to know how to use this grocery list (SQL)
' Command: /delete
' Database table wiped
' 
' Type '/' to know how to use this grocery list (SQL)
' Command: /stop
' Goodbye!
