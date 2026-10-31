' ============================================
' ROSETTA: https://rosettacode.org/wiki/Literals/String
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Demonstrates BazzBasic string literals: double-quoted strings, character literals, escape sequences, embedded quotes, multi-line text built with \n and a trailing +, and the absence of variable expansion.
' CATEGORY: strings
' TAGS: string literals, escape sequences, fstring
' MINVERSION: 1.5
' ============================================
' BazzBasic has a single string literal form: "double quotes".
' There is no separate character type; a character is simply a
' string of length 1 (see ASC / CHR).
'
' Backslash escapes are always active inside a literal:
'   \"  quote     \n  newline     \t  tab     \\  backslash
'
' Verbatim strings: not supported. Every backslash is an escape,
'   so a literal backslash must be written as \\.
' Here-strings: not supported. Multi-line text is built with \n,
'   and a trailing + lets the expression continue on the next line.
' Variable expansion: string literals NEVER expand variables.
'   Interpolation is explicit, via FSTRING() and {{-name$-}} markers.

[inits]
    LET name$  = "Forrest"
    LET quote$ = "Momma says stupid is as stupid does."
    LET multi$ = ""

[main]
    ' Character literals: just one-character strings
    PRINT "A"; " has code "; ASC("A"); ", and CHR(66) is "; CHR(66)

    ' Embedding double quotes
    PRINT "\"" + quote$ + "\" - Forrest Gump"
    PRINT CHR(34) + quote$ + CHR(34) + " - Forrest Gump"

    ' Other escape sequences
    PRINT "Column1\tColumn2"
    PRINT "Path: C:\\BazzBasic\\Examples"

    ' Closest thing to a here-string
    multi$ = "Line one\n" +
             "Line two\n" +
             "Line three"
    PRINT multi$

    ' Variable expansion
    PRINT "Hello, name$"                    ' printed as-is, no expansion
    PRINT FSTRING("Hello, {{-name$-}}")     ' explicit interpolation
END

' Output:
' A has code 65, and CHR(66) is B
' "Momma says stupid is as stupid does." - Forrest Gump
' "Momma says stupid is as stupid does." - Forrest Gump
' Column1 Column2
' Path: C:\BazzBasic\Examples
' Line one
' Line two
' Line three
' Hello, name$
' Hello, Forrest