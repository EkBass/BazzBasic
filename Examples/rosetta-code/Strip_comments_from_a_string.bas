' ============================================
' ROSETTA: https://rosettacode.org/wiki/Strip_comments_from_a_string
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Strips everything from the first comment marker (# or ;) to the end of a line and trims the remaining whitespace, shown on three test lines.
' CATEGORY: strings
' TAGS: strip comments, instr, trim, parsing
' MINVERSION: 1.5
' ============================================

DEF FN StripComment$(line$, markers$)
    FOR i$ = 1 TO LEN(markers$)
        LET pos$ = INSTR(line$, MID(markers$, i$, 1))
        IF pos$ > 0 THEN line$ = LEFT(line$, pos$ - 1)
    NEXT
    RETURN TRIM(line$)
END DEF

[inits]
    LET MARKERS# = "#;"
    LET wkv$ ' WAITKEY return value

[main]
    PRINT FN StripComment$("apples, pears # and bananas", MARKERS#)
    PRINT FN StripComment$("apples, pears ; and bananas", MARKERS#)
    PRINT FN StripComment$("   apples, pears   ", MARKERS#)
    wkv$ = WAITKEY()
END

' Output:
' apples, pears
' apples, pears
' apples, pears