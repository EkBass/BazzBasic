' ============================================
' ROSETTA: https://rosettacode.org/wiki/Reverse_words_in_a_string
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Reverses the order of the words on each line of a poem while keeping the lines in their original order and blank lines blank, using SPLIT and string concatenation.
' CATEGORY: strings
' TAGS: reverse words, split, words, text lines
' MINVERSION: 1.5
' ============================================
' Reverse the order of the words on each line, keeping the
' lines themselves in their original order. Blank lines stay blank.

[inits]
    DIM lines$
        lines$(0) = "---------- Ice and Fire ------------"
        lines$(1) = ""
        lines$(2) = "fire, in end will world the say Some"
        lines$(3) = "ice. in say Some"
        lines$(4) = "desire of tasted I've what From"
        lines$(5) = "fire. favor who those with hold I"
        lines$(6) = ""
        lines$(7) = "... elided paragraph last ..."
        lines$(8) = ""
        lines$(9) = "Frost Robert -----------------------"

    DIM words$
    LET count$    = 0
    LET reversed$ = ""

[main]
    FOR i$ = 0 TO ROWCOUNT(lines$()) - 1
        count$    = SPLIT(words$, lines$(i$), " ")
        reversed$ = ""
        FOR j$ = count$ - 1 TO 0 STEP -1
            ' Skip empty pieces left by blank lines or repeated spaces
            IF words$(j$) <> "" THEN
                IF reversed$ <> "" THEN reversed$ += " "
                reversed$ += words$(j$)
            END IF
        NEXT
        PRINT reversed$
    NEXT
    SLEEP 10000
END

' Output:
' ------------ Fire and Ice ----------
'
' Some say the world will end in fire,
' Some say in ice.
' From what I've tasted of desire
' I hold with those who favor fire.
'
' ... last paragraph elided ...
'
' ----------------------- Robert Frost