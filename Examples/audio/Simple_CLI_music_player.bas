' BazzBasic version 1.4c
' https://ekbass.github.io/BazzBasic/

' Simple CLI music player

' If no args, we can close immediately
IF ARGCOUNT = 0 THEN
    PRINT "Missing arguments. Closing..."
    END
END IF

[inits]
    LET SONG# = ARGS(0)
    ' UCASE once here so the comparison below is straightforward
    LET SUFFIX# = UCASE(RIGHT(SONG#, 3))

[pre-checks]
    ' String contents are case-sensitive, so compare against UPPERCASE literals
    IF SUFFIX# <> "WAV" AND SUFFIX# <> "MP3" THEN
        PRINT "Invalid audio format: " + SUFFIX# + "\nClosing..."
        END
    END IF

    IF FILEEXISTS(SONG#) = FALSE THEN
        PRINT "File: " + SONG# + " not found.\nClosing..."
        END
    END IF

[main]
    PRINT "playing audio: " + SONG#
    PRINT "\nCTRL+C to exit."
    ' Fire-and-forget: handle is used once, program ends right after
    SOUNDONCEWAIT(LOADSOUND(SONG#))
END

' Output:
' PS C:\Users\ekvir\source\repos\BazzBasic\bin\Release\net10.0-windows\win-x64\publish> .\BazzBasic.exe .\test.bas temp/R2D2.mp3
' playing audio: temp/R2D2.mp3
' 
' CTRL+C to exit.