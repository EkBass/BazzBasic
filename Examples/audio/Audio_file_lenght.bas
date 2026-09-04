' ============================================
' BazzBasic version 1.4c
' https://ekbass.github.io/BazzBasic/

' Audio length in seconds
' ============================================

IF ARGCOUNT = 0 THEN
    PRINT "Usage: bazzbasic.exe audiolen.bas <file.wav|file.mp3>"
    END
END IF

[inits]
    ' System.Media.Duration is reported in 100-ns ticks -> 1 s = 10,000,000.
    ' Verify locally; the friendly 'Duration' property returns "hh:mm:ss" instead.
    LET TICKS#  = 10000000
    LET AUDIO#  = ARGS(0)
    LET SUFFIX# = UCASE(RIGHT(AUDIO#, 3))

[pre-checks]
    IF SUFFIX# <> "WAV" AND SUFFIX# <> "MP3" THEN
        PRINT "Unsupported format: " + SUFFIX# + "\nClosing..."
        END
    END IF
    IF FILEEXISTS(AUDIO#) = FALSE THEN
        PRINT "File not found: " + AUDIO# + "\nClosing..."
        END
    END IF

[main]
    ' Get-Item splits the path; .DirectoryName + .Name feed the Shell COM call.
    LET CMD#   = "powershell -NoProfile -Command \"$f = Get-Item -LiteralPath '" + AUDIO# + "'; (New-Object -ComObject Shell.Application).NameSpace($f.DirectoryName).ParseName($f.Name).ExtendedProperty('System.Media.Duration')\""
    LET raw$   = SHELL(CMD#, 10000)
    LET secs$  = VAL(TRIM(raw$)) / TICKS#

    IF secs$ <= 0 THEN
        PRINT "Could not read duration of " + AUDIO#
        END
    END IF

    PRINT FSTRING("{{-AUDIO#-}} is {{-secs$-}} seconds")
END

' Output:
' C:\temp\R2D2.mp3 is 2.6 seconds