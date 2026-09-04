' Simple logger via CLI arguments
' public domain
' BazzBasic version 1.4c
' https://ekbass.github.io/BazzBasic/


' If no args, we can close immediately
IF ARGCOUNT = 0 THEN
    PRINT "Missing arguments. Closing..."
    END
END IF

' Generate timestamp
DEF FN TimeStamp$()
    LET front$ = "[timestamp: '"
    LET back$ = "' /]"
    ' MM = month (mm would be minutes), HH = 24-hour (hh would be 12-hour)
    LET stamp$ = TIME("dd-MM-yyyy HH:mm")
    RETURN front$ + stamp$ + back$
END DEF

[inits]
    LET LOG_FILE# = "sl_log.txt"
    LET MSG# = ARGS(0)
    LET EXISTS# = FILEEXISTS(LOG_FILE#)

' Generate new log file if does not exists yet
[pre:check_log_file]
    IF EXISTS# = FALSE THEN
        GOSUB [sub:generate_log_file]
    END IF

[main]
    FILEAPPEND LOG_FILE#, "> " + FN TimeStamp$() + " : " + MSG# + "\n"
    PRINT "Entry saved to file: " + LOG_FILE#
END

' FIRST_ENTRY# only declared/initialized if new log created.
' IMO: ok to do this way, not inside [inits]
[sub:generate_log_file]
    LET FIRST_ENTRY# = "New log file started at " + FN TimeStamp$() + "\n" + REPEAT("=", 30) + "\n\n"
    FILEWRITE LOG_FILE#, FIRST_ENTRY#
RETURN