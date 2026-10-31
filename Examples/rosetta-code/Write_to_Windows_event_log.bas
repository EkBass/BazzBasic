' ============================================
' ROSETTA: https://rosettacode.org/wiki/Write_to_Windows_event_log
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Writes an entry to the Windows Application event log by running the EventCreate tool through SHELL, with level, id, source and description taken from four command-line arguments (needs administrator rights).
' CATEGORY: api
' TAGS: event log, shell, command-line arguments, windows
' MINVERSION: 1.5
' ============================================
' BazzBasic has no native Event Log API, so the Windows
' EventCreate tool is called through SHELL.
' Must be run from a console/IDE running as Administrator.

[inits]
    LET LEVELS#  = " ERROR WARNING INFORMATION SUCCESS "
    LET level$   = ""
    LET id$      = 0
    LET source$  = ""
    LET desc$    = ""
    LET cmd$     = ""
    LET result$  = ""

[main]
    IF ARGCOUNT <> 4 THEN
        PRINT "Usage: bazzbasic.exe eventlog.bas <level> <id> <source> <description>"
        PRINT "  level: ERROR, WARNING, INFORMATION or SUCCESS"
        PRINT "  id:    integer 1 - 1000"
        END
    END IF

    level$  = UCASE(ARGS(0))
    id$     = VAL(ARGS(1))
    source$ = ARGS(2)
    desc$   = ARGS(3)

    IF INSTR(LEVELS#, " " + level$ + " ") = 0 THEN
        PRINT "Invalid level: "; level$
        END
    END IF
    IF id$ <> INT(id$) OR NOT BETWEEN(id$, 1, 1000) THEN
        PRINT "Event id must be an integer between 1 and 1000."
        END
    END IF

    cmd$ = FSTRING("EventCreate /t {{-level$-}} /id {{-id$-}} /l APPLICATION /so \"{{-source$-}}\" /d \"{{-desc$-}}\" 2>&1")
    result$ = SHELL(cmd$)
    PRINT result$
END

' Output:
' > bazzbasic.exe eventlog.bas error 123 BazzBasic "Rosetta Code example"
' SUCCESS: An event of type 'ERROR' was created in the 'APPLICATION' log with 'BazzBasic' as the source.