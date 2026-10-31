' ============================================
' ROSETTA: https://rosettacode.org/wiki/XML/Input
' BazzBasic: https://github.com/EkBass/BazzBasic
' --------------------------------------------
' DESCRIPTION: Extracts the list of student names from an XML fragment held in a string, by scanning for Student tags and their Name attributes with INSTR and decoding numeric character references such as &#x00C9; (BazzBasic has no XML parser).
' CATEGORY: data
' TAGS: xml, xml parsing, character references, instr
' MINVERSION: 1.5
' ============================================

' Hexadecimal string to number, e.g. "00C9" -> 201
DEF FN HexToDec$(hex$)
    LET value$ = 0
    FOR i$ = 1 TO LEN(hex$)
        value$ = value$ * 16 + INSTR("0123456789ABCDEF", UCASE(MID(hex$, i$, 1))) - 1
    NEXT
    RETURN value$
END DEF

' Replace &#xHHHH; and &#DDD; references with the characters they stand for
DEF FN DecodeRefs$(s$)
    LET result$ = ""
    LET p$      = 1
    LET semi$   = 0
    LET ref$    = ""
    WHILE p$ <= LEN(s$)
        semi$ = INSTR(p$, s$, ";")
        IF MID(s$, p$, 2) = "&#" AND semi$ > 0 THEN
            ref$ = MID(s$, p$ + 2, semi$ - p$ - 2)
            IF LCASE(LEFT(ref$, 1)) = "x" THEN
                result$ += CHR(FN HexToDec$(MID(ref$, 2)))
            ELSE
                result$ += CHR(VAL(ref$))
            END IF
            p$ = semi$ + 1
        ELSE
            result$ += MID(s$, p$, 1)
            p$ += 1
        END IF
    WEND
    RETURN result$
END DEF

[inits]
    LET xml$ = "<Students>\n" +
        "  <Student Name=\"April\" Gender=\"F\" DateOfBirth=\"1989-01-02\" />\n" +
        "  <Student Name=\"Bob\" Gender=\"M\"  DateOfBirth=\"1990-03-04\" />\n" +
        "  <Student Name=\"Chad\" Gender=\"M\"  DateOfBirth=\"1991-05-06\" />\n" +
        "  <Student Name=\"Dave\" Gender=\"M\"  DateOfBirth=\"1992-07-08\">\n" +
        "    <Pet Type=\"dog\" Name=\"Rover\" />\n" +
        "  </Student>\n" +
        "  <Student DateOfBirth=\"1993-09-10\" Gender=\"F\" Name=\"&#x00C9;mily\" />\n" +
        "</Students>\n"

    LET TAG_OPEN# = "<Student "     ' trailing space: skips <Students>
    LET ATTR#     = " Name=\""      ' leading space: whole attribute name only

    LET p$      = 0     ' start of current <Student tag
    LET tagEnd$ = 0     ' its closing >
    LET tag$    = ""    ' the tag text itself
    LET a$      = 0     ' start of the Name value
    LET b$      = 0     ' closing quote of the Name value

[main]
    p$ = INSTR(xml$, TAG_OPEN#)
    WHILE p$ > 0
        tagEnd$ = INSTR(p$, xml$, ">")
        tag$    = MID(xml$, p$, tagEnd$ - p$ + 1)
        a$      = INSTR(tag$, ATTR#)
        IF a$ > 0 THEN
            a$ += LEN(ATTR#)
            b$ = INSTR(a$, tag$, "\"")
            PRINT FN DecodeRefs$(MID(tag$, a$, b$ - a$))
        END IF
        p$ = INSTR(tagEnd$, xml$, TAG_OPEN#)
    WEND
END

' Output:
' April
' Bob
' Chad
' Dave
' Émily