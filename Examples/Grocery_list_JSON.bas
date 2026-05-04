' Grocery List - JSON Version
' BazzBasic version 1.4

[inits]
    LET LIST_FILE# = "list.json"
    
    ' Initialize the array
    DIM list$
    
    ' Variables for menu and items
    LET cmd$ = ""
    LET item$ = ""
    
    ' UI Colors
    LET COL_MENU# = 11  ' Cyan
    LET COL_WARN# = 12  ' Lt Red
    LET COL_TEXT# = 15  ' White
    
    ' Load existing data if file exists
    IF FILEEXISTS(LIST_FILE#) = 1 THEN
        LOADJSON list$, LIST_FILE#
    END IF

[main]
    WHILE TRUE
        COLOR COL_MENU#, 0
        PRINT "\nType '/' to know how to use this grocery list"
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
    PRINT "/delete -> Delete the entire list"
    PRINT "/add    -> Add an element in the list"
    PRINT "/list   -> Show the list"
    PRINT "/stop   -> Exit"
RETURN

[sub:add_element]
    LINE INPUT "New element of the list: ", item$
    
    ' LEN works with 1-dimension arrays, but fails instantly if more dimensions.
    ' LEN returns the full size of array
    ' ROWCOUNT the size of 1st dimension so it is safer here
    LET idx$ = ROWCOUNT(list$())
    list$(idx$) = item$
    
    ' Save the updated array to a formatted JSON file
    SAVEJSON list$, LIST_FILE#
    PRINT "Added: " + item$
RETURN

[sub:print_list]
    ' LEN() counts total elements across all dimensions
    ' Replaced LEN with more secure ROWCOUNT when 1st dimension size matters
    LET total$ = ROWCOUNT(list$())
    
    IF total$ = 0 THEN
        COLOR COL_WARN#, 0
        PRINT "List already empty"
    ELSE
        COLOR COL_TEXT#, 0
        PRINT "--- YOUR LIST (JSON) ---"
        ' Loop through numeric indices
        FOR i$ = 0 TO total$ - 1
            PRINT i$ + 1; ". "; list$(i$)
        NEXT
    END IF
RETURN

[sub:delete_list]
    ' LEN changed to ROWCOUNT here too
    IF ROWCOUNT(list$()) = 0 THEN
        COLOR COL_WARN#, 0
        PRINT "List already empty"
    ELSE
        ' Removes the entire array and all its elements
        DELARRAY list$
        ' Must re-initialize after DELARRAY
        DIM list$
        
        ' Update the file to be an empty JSON structure
        SAVEJSON list$, LIST_FILE#
        PRINT "List removed"
    END IF
RETURN


' list.json
' [
'   "milk",
'   "cow",
'   "fog"
' ]
