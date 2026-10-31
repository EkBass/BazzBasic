' ============================================
' ROSETTA: https://rosettacode.org/wiki/Read_entire_file
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Reads the whole text file test.txt into a string with FILEREAD if it exists and prints its content, otherwise prints a message that the file does not exist.
' CATEGORY: file-io
' TAGS: read file, fileread, fileexists
' REQUIRES: test.txt
' MINVERSION: 1.5
' ============================================

[inits]
    LET inputFile$ = "test.txt"
    LET content$

[main]
    ' Check if exists and if so, read it
    IF FILEEXISTS(inputFile$) = TRUE THEN

        ' FILEREAD() returns whole .txt file as string
        content$ = FILEREAD(inputFile$)
        PRINT "Content:\n"; content$
    ELSE
        PRINT "File: "; inputFile$; " do not exist."
    END IF
END

' OUTPUT:
' Content:
' The quick brown fox jumps over the lazy dog.
' Empty vessels make most noise.
' Too many chefs spoil the broth.
' A rolling stone gathers no moss.
