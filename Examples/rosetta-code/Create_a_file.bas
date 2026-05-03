' ============================================
' https://rosettacode.org/wiki/Create_a_file
' BazzBasic: https://github.com/EkBass/BazzBasic
' ============================================

[inits]
    ' No filesystem root built-in BazzBasic, so I use creative way to get it
    LET DRIVE_ROOT# = MID(SHELL("echo %CD%"), 1, 3) ' "C:\" or "D:\" or...

[main]
    ' Create in current directory
    FILEWRITE "output.txt", ""
    FILEWRITE "docs\\placeholder.txt", ""   ' FILEWRITE auto-creates the directory


    ' Create in filesystem root
    FILEWRITE DRIVE_ROOT# + "\\output.txt", ""
    FILEWRITE DRIVE_ROOT# + "\\docs\\placeholder.txt", ""

    PRINT "Done."
END
