' ============================================
' ROSETTA: https://rosettacode.org/wiki/Create_a_file
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Creates an empty file and a directory (with a placeholder file in it) both in the current directory and in the root of the current drive.
' CATEGORY: file-io
' TAGS: filewrite, create file, create directory, drive root
' MINVERSION: 1.5
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
