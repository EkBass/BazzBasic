' =================================================================================================
'
' FILE: BB_Version_checking_from_source.bas
'
' A tiny BazzBasic snippet for version checking.
' It reads file "Version.cs" from the GitHub source and parses it.
' It reports depending of is user current BBVER# is little or more behind of current source version.
'
' It works, if author (thats me) just remembers to update the version to the file.
' =================================================================================================

[inits]
    LET VER_URL# = "https://raw.githubusercontent.com/EkBass/BazzBasic/main/src/Version.cs"
    LET raw$          = ""
    LET marker$       = ""
    LET pos$          = 0
    LET startPos$        = 0
    LET stopPos$         = 0
    LET remoteVer$    = ""
    LET remoteCount$  = 0
    LET localCount$   = 0
    LET remoteMajor$  = 0
    LET remoteMinor$  = 0
    LET localMajor$   = 0
    LET localMinor$   = 0
    DIM remote$
    DIM local$

    LET key$  ' for WAITKEY return

[main]
    PRINT "Checking version..."
    raw$ = HTTPGET(VER_URL#)

    marker$ = "Version = \""
    pos$    = INSTR(raw$, marker$)

    IF pos$ = 0 THEN
        PRINT "Could not locate version in remote file."
        key$ = WAITKEY()
        END
    END IF

    startPos$     = pos$ + LEN(marker$)
    stopPos$      = INSTR(startPos$, raw$, "\"")
    remoteVer$ = MID(raw$, startPos$, stopPos$ - startPos$)

    remoteCount$ = SPLIT(remote$, remoteVer$, ".")
    localCount$  = SPLIT(local$,  BBVER#,     ".")

    IF remoteCount$ < 2 OR localCount$ < 2 THEN
        PRINT "Version format unexpected: '" + remoteVer$ + "'"
        LET key$ = WAITKEY()
        END
    END IF

    remoteMajor$ = VAL(remote$(0))
    remoteMinor$ = VAL(remote$(1))
    localMajor$  = VAL(local$(0))
    localMinor$  = VAL(local$(1))

    PRINT "Local  : " + BBVER#
    PRINT "Remote : " + remoteVer$

    IF remoteMajor$ > localMajor$ THEN
        PRINT "Major update available!"
    ELSEIF remoteMajor$ = localMajor$ AND remoteMinor$ > localMinor$ THEN
        PRINT "Minor update available."
    ELSE
        PRINT "You are up to date."
    END IF
    key$ = WAITKEY()
END