' ============================================
' ROSETTA: https://rosettacode.org/wiki/Generate_lower_case_ASCII_alphabet
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Builds the lower-case ASCII alphabet from the character codes of a to z, prints it, and prints its fifth letter.
' CATEGORY: strings
' TAGS: alphabet, ascii, character codes, asc, chr
' MINVERSION: 1.5
' ============================================
' Task point: build the alphabet from ASC('a')..ASC('z') rather than
' typing the letters out — a hand-written list is bug-prone on review.

[inits]
    LET alphabet$ = ""

[main]
    FOR i$ = ASC("a") TO ASC("z")
        alphabet$ += CHR(i$)
    NEXT

    PRINT alphabet$               ' abcdefghijklmnopqrstuvwxyz
    PRINT MID(alphabet$, 5, 1)    ' "e" — string is indexable (1-based)
END

' Output:
' abcdefghijklmnopqrstuvwxyz
' e