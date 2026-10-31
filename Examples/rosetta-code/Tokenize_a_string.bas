' ============================================
' ROSETTA: https://rosettacode.org/wiki/Tokenize_a_string
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Splits the string Hello,How,Are,You,Today at the commas with SPLIT and prints the tokens separated by periods.
' CATEGORY: strings
' TAGS: tokenize, split string, delimiter
' MINVERSION: 1.5
' ============================================

[inits]
    DIM tokens$

    LET SEP#    = ","
    LET list$   = "Hello,How,Are,You,Today"
    LET count$

[main]
    ' SPLIT() is handy, since fills the array (tokens$) and returns the amount at same call.
    LET count$ = SPLIT(tokens$, list$, SEP#)

[out]
    FOR i$ = 0 TO count$ - 1
        PRINT tokens$(i$); ".";
    NEXT
END

' Output:
' Hello.How.Are.You.Today.
