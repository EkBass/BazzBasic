' ============================================
' https://rosettacode.org/wiki/Rename_a_file
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================
' BazzBasic has no built-in rename command, so the job is
' handed to the Windows command interpreter's REN via SHELL.
' REN accepts a path for the source, but only a bare name
' for the target. REN works for files and directories alike.
' "2>&1" routes error messages into SHELL's return value.

[inits]
    LET out$ = ""

[main]
    ' Here, in the current working directory
    out$ = SHELL("ren input.txt output.txt 2>&1")
    IF out$ <> "" THEN PRINT "input.txt: "; out$
    out$ = SHELL("ren docs mydocs 2>&1")
    IF out$ <> "" THEN PRINT "docs: "; out$

    ' In the root of the current drive ("\\" is a single \)
    out$ = SHELL("ren \\input.txt output.txt 2>&1")
    IF out$ <> "" THEN PRINT "\\input.txt: "; out$
    out$ = SHELL("ren \\docs mydocs 2>&1")
    IF out$ <> "" THEN PRINT "\\docs: "; out$
END