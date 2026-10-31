' ============================================
' ROSETTA: https://rosettacode.org/wiki/Make_directory_path
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Creates a nested directory path (test\sub\deeper) with all missing parent directories through the Windows md command called with SHELL, without an error if it already exists.
' CATEGORY: file-io
' TAGS: make directory, mkdir, shell, fstring
' MINVERSION: 1.5
' ============================================
' Create a directory and any missing parents, like "mkdir -p".
' Running it again when the path already exists is not an error.
' BazzBasic has no built-in for this, so the Windows shell does the
' work: "md" creates intermediate directories, and "if not exist"
' skips the call when the path is already there.

[inits]
    LET path$   = "test\\sub\\deeper"
    LET result$ = ""

[main]
    result$ = SHELL(FSTRING("if not exist \"{{-path$-}}\" md \"{{-path$-}}\" 2>&1"))
    IF result$ <> "" THEN
        PRINT "Error: "; result$
    ELSE
        PRINT "Directory ready: "; path$
    END IF
END

' Output (first and second run alike):
' Directory ready: test\sub\deeper