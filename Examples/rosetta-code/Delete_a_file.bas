' ============================================
' ROSETTA: https://rosettacode.org/wiki/Delete_a_file
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Deletes a file and a directory in the current directory and in the root of the current drive.
' CATEGORY: file-io
' TAGS: filedelete, delete file, delete directory, shell
' MINVERSION: 1.5
' ============================================
[inits]
    LET DRIVE_ROOT# = MID(SHELL("echo %CD%"), 1, 3)

[main]
    ' Delete in current directory
    FILEDELETE "input.txt"
    SHELL("rmdir /s /q docs")

    ' Delete in filesystem root
    ' Note: requires administrator privileges on Windows
    FILEDELETE DRIVE_ROOT# + "input.txt"
    SHELL("rmdir /s /q " + DRIVE_ROOT# + "docs")

    PRINT "Done."
END
