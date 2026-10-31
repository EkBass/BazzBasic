' ============================================
' ROSETTA: https://rosettacode.org/wiki/Write_entire_file
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Writes the string Mickey Mouse to the file output.txt with FILEWRITE, creating or overwriting the file.
' CATEGORY: file-io
' TAGS: write file, filewrite, text file
' MINVERSION: 1.5
' ============================================

[inits]
    LET FILENAME# = "output.txt"
    LET output$ = "Mickey Mouse"

[main]
    FILEWRITE FILENAME#, output$
END

' Output: 
' file: "output.txt" containing "Mickey Mouse"