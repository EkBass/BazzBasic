' ============================================
' ROSETTA: https://rosettacode.org/wiki/Input_loop
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Reads the whole text file assets/input_loop.txt with FILEREAD, splits it into lines with SPLIT and prints the lines one by one.
' CATEGORY: file-io
' TAGS: read file, fileread, split, line by line
' REQUIRES: assets/input_loop.txt
' MINVERSION: 1.5
' ============================================
' BazzBasic reads files in one shot with FileRead().
' Splitting with SPLIT gives us the lines to iterate.

[inits]
    LET raw$
    LET count$
    LET i$
    DIM lines$

[main]
    raw$ = FileRead("assets/input_loop.txt")
    LET count$ = SPLIT(lines$, raw$, CHR(13) + CHR(10))

    FOR i$ = 0 TO count$ - 1
        PRINT lines$(i$)
    NEXT
END