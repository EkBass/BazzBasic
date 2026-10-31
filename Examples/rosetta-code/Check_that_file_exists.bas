' ============================================
' ROSETTA: https://rosettacode.org/wiki/Check_that_file_exists
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Checks whether a file and a directory exist in the current directory and in the program root, including a zero-length file and a file with an unusual name.
' CATEGORY: file-io
' TAGS: fileexists, directory check, shell, prg_root
' MINVERSION: 1.5
' ============================================

DEF FN DirExists$(path$)
    LET result$ = TRIM(SHELL("if exist \"" + path$ + "\\\" (echo 1) else (echo 0)"))
    RETURN result$
END DEF

[main]
    ' Check in current directory
    PRINT "Current directory:"
    PRINT "  input.txt:      "; FileExists("input.txt")
    PRINT "  docs:           "; FN DirExists$("docs")

    ' Check in program root
    PRINT "Program root:"
    PRINT "  input.txt:      "; FileExists(PRG_ROOT# + "input.txt")
    PRINT "  docs:           "; FN DirExists$(PRG_ROOT# + "docs")

    ' Optional: zero-length file
    PRINT "Optional:"
    PRINT "  zero-length:    "; FileExists("zero.txt")

    ' Unusual filename
    PRINT "  Abdu'l-Baha.txt: "; FileExists("Abdu'l-Baha.txt")
END

' Output (example):
' Current directory:
'   input.txt:      1
'   docs:           1
' Program root:
'   input.txt:      0
'   docs:           0
' Optional:
'   zero-length:    0
'   Abdu'l-Baha.txt: 0
